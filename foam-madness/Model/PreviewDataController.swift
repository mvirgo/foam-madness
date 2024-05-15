//
//  PreviewDataController.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/23/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import CoreData

struct PreviewDataController {
    static let shared = PreviewDataController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "foam-madness")
        container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }

        loadMockData()
    }
    
    private func makeMockGame(isComplete: Bool) {
        let context = container.viewContext
        let team1 = Team(context: context)
        let team2 = Team(context: context)
        let game = Game(context: context)
        team1.name = "Kansas"
        team1.abbreviation = "KU"
        team1.id = 1
        team2.name = "Duke"
        team2.abbreviation = "DUKE"
        team2.id = 2
        game.teams = [team1, team2]
        game.team1Id = team1.id
        game.team2Id = team2.id
        if (isComplete) {
            game.team1Ones = 1
            game.team1Twos = 0
            game.team1Threes = 0
            game.team1Fours = 0
            game.team1OTTaken = 0
            game.team1OTMade = 0
            game.team1Score = 1
            game.team2Ones = 0
            game.team2Twos = 0
            game.team2Threes = 0
            game.team2Fours = 0
            game.team2OTTaken = 0
            game.team2OTMade = 0
            game.team2Score = 0
            game.completion = true
        }
    }
    
    private func makeMockTournaments() {
        let context = container.viewContext
        let _ = BracketCreationController(context: context)
            .createBracketFromFile(
                bracketLocation: "mensBracket2023",
                tournamentName: "Example Tournament 1",
                isSimulated: false,
                useLeft: false,
                shotsPerRound: AppConstants.defaultShotsPerRound
            )
    }

    private func loadMockData() {
        let context = container.viewContext
        makeMockGame(isComplete: false)
        makeMockGame(isComplete: true)
        makeMockTournaments()
        do {
            try context.save()
        } catch {
            print("Failed to save preview mock data.")
        }
    }
}
