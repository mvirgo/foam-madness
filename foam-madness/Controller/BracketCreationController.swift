//
//  BracketCreationController.swift
//  foam-madness
//
//  Created by Michael Virgo on 3/5/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import CoreData
import SwiftUI

struct LoadedBracketOutput {
    var hasFirstFour: Bool
    var isWomens: Bool
    var regionOrder: [String]
    var regionSeedTeams: [String: [String: Int16]]
    var firstFour: [String: [String: String]]
}

let startingRoundByNumTeams = [
    68: 0,
    64: 1,
    32: 2,
    16: 3,
    8: 4,
    4: 5
]

class BracketCreationController {
    @AppStorage("useBracketView") var useBracketView = AppConstants.defaultUseBracketView
    
    var context: NSManagedObjectContext!
    
    init(context: NSManagedObjectContext!) {
        self.context = context
    }
    
    // MARK: Public methods
    func createBracketFromFile(bracketLocation: String, tournamentName: String, isSimulated: Bool, useLeft: Bool, shotsPerRound: Int) -> Tournament {
        // Load the bracket
        let loadedBracket = loadBracket(bracketLocation: bracketLocation)
        // Create any teams that aren't created yet
        createAnyNewTeams()
        // Create the tournament
        let tournament = createTournamentObject(
            tournamentName: tournamentName,
            isSimulated: isSimulated,
            isWomens: loadedBracket.isWomens,
            shotsPerRound: shotsPerRound
        )
        // Create all games and add to tourney
        let hasFirstFour = loadedBracket.hasFirstFour
        let startingRound = hasFirstFour ? 0 : 1
        createTournamentGames(loadedBracket: loadedBracket, tournament: tournament, useLeft: useLeft, startingRound: startingRound)
        tournament.ready = true
        
        return tournament
    }
    
    func createCustomBracket(numTeams: Int, isWomens: Bool, tournamentName: String, isSimulated: Bool, useLeft: Bool, shotsPerRound: Int) -> Tournament {
        // Mock the bracket
        let hasFirstFour = numTeams == 68
        let mockBracket = mockBracket(isWomens: isWomens, hasFirstFour: hasFirstFour)
        // Create any teams that aren't created yet
        createAnyNewTeams()
        // Create the tournament
        let tournament = createTournamentObject(
            tournamentName: tournamentName,
            isSimulated: isSimulated,
            isWomens: isWomens,
            shotsPerRound: shotsPerRound
        )
        // Create all games and add to tourney
        createTournamentGames(loadedBracket: mockBracket, tournament: tournament, useLeft: useLeft, startingRound: startingRoundByNumTeams[numTeams]!)
        tournament.ready = false
        
        return tournament
    }
    
    func checkExistingNames(_ name: String) -> Bool {
        // Return true if no other tournaments named the same
        let predicate = NSPredicate(format: "name == %@", name)
        return TourneyHelper.fetchDataFromContext(context, predicate, "Tournament", []).count == 0
    }
    
    func simulateTournament(tournament: Tournament) -> String {
        var winner: String = ""
        // Get correct starting id (minimum tourneyGameId)
        var id = (tournament.games as! Set<Game>).min(by: { $0.tourneyGameId < $1.tourneyGameId })?.tourneyGameId ?? 0
        // Loop through and simulate all games
        while true {
            let game = tournament.games?.filtered(using: NSPredicate(format: "tourneyGameId == %@", NSNumber(value: id))).first as! Game
            let gameTeams = game.teams?.allObjects as! [Team]
            // Ensure proper order of teams
            let team1, team2 : Team
            if gameTeams[0].id == game.team1Id {
                team1 = gameTeams[0]
                team2 = gameTeams[1]
            } else {
                team1 = gameTeams[1]
                team2 = gameTeams[0]
            }
            // Simulate the game
            SimHelper.simSingleGame(game, team1, team2)
            // Complete the game
            winner = GameHelper.completeGame(context, game, team1, team2).name!
            id += 1
            // Break if done with tournament
            if tournament.completion {
                break
            }
        }
        // Make sure all is saved
        saveData()
        
        return winner
    }
    
    // For randomly filling custom brackets
    func fillTournamentWithRandomTeams(_ tournament: Tournament) {
        let games = tournament.games?.allObjects as! [Game]
        let initialRound = games.min(by: { $0.round < $1.round })!.round
        let gamesInInitialRound = games.filter({ $0.round == initialRound })
        
        // Load all teams
        let teams = TeamHelper.loadTeams()
        
        // Add teams to each game, avoiding duplicates
        var teamIds: Set<Int16> = []
        for game in gamesInInitialRound {
            while game.teams?.count != 2 {
                let teamId = Int16(getRandomTeamId(teams))!
                if !teamIds.contains(teamId) {
                    teamIds.insert(teamId)
                    if game.teams?.count == 0 {
                        game.team1Id = teamId
                    } else {
                        game.team2Id = teamId
                    }
                    let team = TeamHelper.fetchTeamById([teamId], context).first as! Team
                    team.addToGames(game)
                }
            }
        }
        
        saveData()
    }
    
    // For filling custom bracket from existing base
    func fillTournamentFromExistingCustom(_ tournament: Tournament, _ bracketLocation: String) {
        // Load the bracket
        let loadedBracket = loadBracket(bracketLocation: bracketLocation)
        let regionSeedTeams = loadedBracket.regionSeedTeams
        let games = tournament.games?.allObjects as! [Game]
        
        // Replace region names
        for game in games {
            useRegionNameExistingCustom(game, loadedBracket.regionOrder)
        }
        
        // Fill in teams
        let minRound = games.min(by: { $0.round < $1.round })?.round ?? 0
        let initialRoundGames = games.filter({ $0.round == minRound })
        for game in initialRoundGames {
            game.team1Id = regionSeedTeams[game.region ?? ""]![String(game.team1Seed)] ?? -1
            game.team2Id = regionSeedTeams[game.region ?? ""]![String(game.team2Seed)] ?? -1
            if (game.team2Id == -1) {
                // Team 2 may not actually exist yet due to First Four, randomly pull one
                let team2Seed = String(game.team2Seed)
                var firstFourTeams: [Int16] = []
                firstFourTeams.append(regionSeedTeams[game.region ?? ""]![team2Seed + "1"]!)
                firstFourTeams.append(regionSeedTeams[game.region ?? ""]![team2Seed + "2"]!)
                game.team2Id = firstFourTeams.randomElement() ?? -1
            }
            // Fetch the teams by id
            let results = TeamHelper.fetchTeamById([game.team1Id, game.team2Id], context)
            // Add teams to the game
            for team in results {
                (team as! Team).addToGames(game)
            }
        }
        
        saveData()
    }
    
    // MARK: Private methods
    private func loadBracket(bracketLocation: String) -> LoadedBracketOutput {
        // Load in bracket
        let path = Bundle.main.path(forResource: bracketLocation, ofType: "plist")!
        let bracketDict = NSDictionary(contentsOfFile: path)!
        let regionSeedTeams = bracketDict.value(forKey: "Regions") as! Dictionary<String, [String: Int16]>
        // Set up regions in order
        let regionIDs = bracketDict.value(forKey: "RegionIDs") as! Dictionary<String, String>
        let regionOrder = [regionIDs["0"], regionIDs["1"], regionIDs["2"], regionIDs["3"]] as! [String]
        // Check if it's a Women's tournament for using correct probabilities
        let isWomens = bracketDict.value(forKey: "IsWomens") as! Bool
        let year = bracketDict.value(forKey: "Year") as! Int
        let hasFirstFour = !isWomens || year >= 2022
        // Get First Four data (if men's or women's 2022 or later)
        var firstFour = [String: [String: String]]()
        if (hasFirstFour) {
            firstFour = bracketDict.value(forKey: "FirstFour") as! Dictionary<String, [String: String]>
        }
        
        return LoadedBracketOutput(
            hasFirstFour: hasFirstFour,
            isWomens: isWomens,
            regionOrder: regionOrder,
            regionSeedTeams: regionSeedTeams,
            firstFour: firstFour
        )
    }
    
    // For mocking custom loaded bracket
    private func mockBracket(isWomens: Bool, hasFirstFour: Bool) -> LoadedBracketOutput {
        return LoadedBracketOutput(
            hasFirstFour: hasFirstFour,
            isWomens: isWomens,
            regionOrder: ["Region 1", "Region 2", "Region 3", "Region 4"],
            regionSeedTeams: [:],
            firstFour: [:]
        )
    }
    
    private func createAnyNewTeams() {
        // Start by getting all existing team ids
        let existingIds = TeamHelper.getExistingTeams(context)
        // Load in all teams from teams dict
        let allTeams = TeamHelper.loadTeamsBasicDict()
        // Create any teams in bracket not in existingIds
        for key in allTeams.allKeys {
            let stringKey = String(describing: key)
            let teamId = Int16(stringKey)!
            if !existingIds.contains(teamId) {
                // Create the team
                let teamDict = allTeams.value(forKey: stringKey)! as! Dictionary<String, String>
                let team = Team(context: context)
                team.name = teamDict["name"]
                team.abbreviation = teamDict["abbreviation"]
                team.id = teamId
            }
        }
    }
    
    private func createTournamentObject(tournamentName: String, isSimulated: Bool, isWomens: Bool, shotsPerRound: Int) -> Tournament {
        // Create the tournament
        let tournament = Tournament(context: context)
        tournament.name = tournamentName
        tournament.createdDate = Date()
        tournament.isWomens = isWomens
        tournament.isSimulated = isSimulated
        tournament.shotsPerRound = Int16(shotsPerRound)
        tournament.useBracketView = useBracketView
        // Make sure it is saved
        saveData()
        
        return tournament
    }
    
    private func createTournamentGames(
        loadedBracket: LoadedBracketOutput,
        tournament: Tournament,
        useLeft: Bool,
        startingRound: Int
    ) {
        let regionOrder = loadedBracket.regionOrder
        let firstFour = loadedBracket.firstFour
        let regionSeedTeams = loadedBracket.regionSeedTeams
        let isWomens = loadedBracket.isWomens
        // Note: This function is essentially hard-coded for current bracket style
        if startingRound == 0 {
            // Create First Four if included
            createFirstFour(tournament: tournament, firstFour: firstFour, regionSeedTeams: regionSeedTeams, isWomens: isWomens, useLeft: useLeft)
        }
        if startingRound <= 1 {
            // Create Round 1 with initial teams
            createFirstRound(tournament: tournament, regionOrder: regionOrder, regionSeedTeams: regionSeedTeams, isWomens: isWomens, useLeft: useLeft)
        }
        // Create Round 2 (or higher) to Championship with no teams
        createLaterRounds(tournament: tournament, regionOrder: regionOrder, isWomens: isWomens, useLeft: useLeft, startingRound: startingRound)
        // Save the data
        saveData()
    }
    
    private func createFirstFour(tournament: Tournament, firstFour: [String: [String: String]], regionSeedTeams: [String: [String: Int16]], isWomens: Bool, useLeft: Bool) {
        // Create all First Four games
        for i in 0...firstFour.count - 1 {
            let game = Game(context: context)
            let gameInfo = firstFour[String(i)]!
            game.round = 0
            game.region = gameInfo["Region"]
            game.useLeft = useLeft
            game.isWomens = isWomens
            game.shotsPerRound = tournament.shotsPerRound
            // Add both team ids and seeds
            game.team1Seed = Int16(gameInfo["Seed"]!)!
            game.team2Seed = Int16(gameInfo["Seed"]!)!
            game.team1Id = regionSeedTeams[game.region!]![gameInfo["Seed"]! + "1"]!
            game.team2Id = regionSeedTeams[game.region!]![gameInfo["Seed"]! + "2"]!
            // Set tourney game id and next game
            game.tourneyGameId = Int16(i)
            game.nextGame = Int16(gameInfo["NextGame"]!)!
            // Fetch the teams by id
            let results = TeamHelper.fetchTeamById([game.team1Id, game.team2Id], context)
            // Add teams to the game
            for team in results {
                (team as! Team).addToGames(game)
            }
            // Add the game to the tournament
            tournament.addToGames(game)
            // Save the data
            saveData()
        }
    }
    
    private func createFirstRound(tournament: Tournament, regionOrder: [String], regionSeedTeams: [String: [String: Int16]], isWomens: Bool, useLeft: Bool) {
        // Hold top seeds in order of games to create (for use with ids)
        let topSeeds = [1, 8, 5, 4, 6, 3, 7, 2]
        // Make counter for tourney game id (start at 4 to avoid First Four)
        var gameId = 4
        // Create all 32 first round games, region by region & seed by seed
        for region in regionOrder {
            for i in topSeeds {
                let game = Game(context: context)
                game.round = 1
                game.region = region
                game.useLeft = useLeft
                game.isWomens = isWomens
                game.shotsPerRound = tournament.shotsPerRound
                game.team1Seed = Int16(i)
                game.team2Seed = Int16(17-i)
                if regionSeedTeams.count > 0 { // not a custom bracket, set teams
                    // Team 2 may not actually exist yet due to First Four
                    game.team1Id = regionSeedTeams[region]![String(i)] ?? -1
                    game.team2Id = regionSeedTeams[region]![String(17-i)] ?? -1
                    // Fetch the teams by id
                    let results = TeamHelper.fetchTeamById([game.team1Id, game.team2Id], context)
                    // Add teams to the game
                    for team in results {
                        (team as! Team).addToGames(game)
                    }
                }
                // Set tourney game id and next game
                game.tourneyGameId = Int16(gameId)
                game.nextGame = Int16((gameId / 2) + 34)
                gameId += 1
                // Add the game to the tournament
                tournament.addToGames(game)
                // Save the data
                saveData()
            }
        }
    }
    
    private func createLaterRounds(tournament: Tournament, regionOrder: [String], isWomens: Bool, useLeft: Bool, startingRound: Int) {
        let gamesPerRoundPerRegion = [4, 2, 1, 2, 1]
        // Make counter for tourney game id (start at 36 to avoid early rounds)
        var gameId = 36
        // Start the loop at a min of round 2 for later rounds, or higher if input (e.g. 16 team tourney)
        let adjustedStartRound = startingRound < 2 ? 2 : startingRound
        // Loop through rounds
        for i in adjustedStartRound...6 {
            if i < 5 { // Before final four
                // Loop through regions
                for region in regionOrder {
                    for j in 1...gamesPerRoundPerRegion[i-2] {
                        let game = Game(context: context)
                        game.round = Int16(i)
                        game.region = region
                        game.useLeft = useLeft
                        game.isWomens = isWomens
                        game.shotsPerRound = tournament.shotsPerRound
                        if startingRound == i {
                            // Add seeds for custom bracket
                            setCustomSeeds(game: game, index: j, gamesPerRegion: gamesPerRoundPerRegion[i-2])
                        }
                        // Set tourney game id and next game
                        game.tourneyGameId = Int16(gameId)
                        game.nextGame = Int16((gameId / 2) + 34)
                        gameId += 1
                        // Add the game to the tournament
                        tournament.addToGames(game)
                        // Save the data
                        saveData()
                    }
                }
            } else { // Final Four or Championship
                for j in 1...gamesPerRoundPerRegion[i-2] {
                    let game = Game(context: context)
                    game.round = Int16(i)
                    game.useLeft = useLeft
                    game.isWomens = isWomens
                    game.shotsPerRound = tournament.shotsPerRound
                    if i == 5 {
                        game.region = "Final Four"
                        game.tourneyGameId = Int16(63 + j)
                        game.nextGame = 66
                        if startingRound == i {
                            // Add seeds for custom bracket
                            setCustomSeeds(game: game, index: j, gamesPerRegion: gamesPerRoundPerRegion[i-2])
                        }
                    } else {
                        game.region = "Championship"
                        game.tourneyGameId = 66
                    }
                    // Add the game to the tournament
                    tournament.addToGames(game)
                    // Save the data
                    saveData()
                }
            }
        }
    }
    
    // This could maybe be improved, but given at most 64 teams allowed,
    // and 350 teams, this should never get stuck too long
    private func getRandomTeamId(_ teams: LoadedTeams) -> String {
        let teamName = teams.teams.randomElement()!
        return teams.reverseTeamDict[teamName]!["id"]!
    }
    
    private func setCustomSeeds(game: Game, index: Int, gamesPerRegion: Int) {
        let seed1: Int16
        if game.round == 2 && (index == 2 || index == 4) {
            // Hard-coded for 32 team custom brackets
            // (Puts two seed at bottom of region)
            seed1 = index == 2 ? 4 : 2
        } else {
            seed1 = Int16(index)
        }
        
        let maxSeed = gamesPerRegion * 2
        game.team1Seed = seed1
        game.team2Seed = Int16(maxSeed) - seed1 + 1 // 1-indexed for w/e reason
    }
    
    // Replace the region name on a custom bracket using existing base (e.g. "Region 1" replaced by `regionOrder[0]`)
    private func useRegionNameExistingCustom(_ game: Game, _ regionOrder: [String]) {
        if let regionNumber = Int(game.region?.replacingOccurrences(of: "Region ", with: "") ?? "0"),
           regionNumber > 0, regionNumber <= regionOrder.count {
            game.region = regionOrder[regionNumber - 1]
        }
    }
    
    // MARK: Utility
    private func saveData() {
        SaveHelper.saveData(context, "BracketCreationController")
    }
}
