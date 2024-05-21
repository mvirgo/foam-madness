//
//  foam_madness_sim_custom_bracket_test.swift
//  foam-madness-tests
//
//  Created by Michael Virgo on 5/20/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import CoreData
import XCTest
@testable import foam_madness

final class foam_madness_sim_custom_bracket_test: XCTestCase {
    var bracketCreationController: BracketCreationController!
    var viewContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        viewContext = CoreDataTestStack.shared.context
        bracketCreationController = BracketCreationController(context: viewContext)
    }

    override func tearDownWithError() throws {
        viewContext = nil
    }
    
    func createCustomTournament(numTeams: Int, fillType: CustomType) -> Tournament {
        return bracketCreationController.createCustomBracket(
            numTeams: numTeams,
            isWomens: false,
            tournamentName: "\(fillType)\(numTeams)",
            isSimulated: true,
            useLeft: false,
            shotsPerRound: AppConstants.defaultShotsPerRound)
    }

    // Check all allowed custom bracket sizes with random fills
    func testCreateAndSimRandomFillCustomBracket() throws {
        for numTeams in numTeamsArray {
            let tournament = createCustomTournament(numTeams: numTeams, fillType: CustomType.random)
            bracketCreationController.fillTournamentWithRandomTeams(tournament)
            let winner = bracketCreationController.simulateTournament(tournament: tournament)
            
            XCTAssert(winner != "")
        }
    }
    
    // Check all allowed custom bracket sizes with an existing bracket fill
    func testCreateAndSimExistingFillCustomBracket() throws {
        let brackets = BracketHelper.loadBrackets()
        let fillBracket = brackets.randomElement()!
        
        for numTeams in numTeamsArray {
            if (numTeams == 4) {
                // Skip existing for 4 team bracket - not allowed
                continue
            }
            let tournament = createCustomTournament(numTeams: numTeams, fillType: CustomType.existing)
            bracketCreationController.fillTournamentFromExistingCustom(tournament, fillBracket.file)
            let winner = bracketCreationController.simulateTournament(tournament: tournament)
            
            XCTAssert(winner != "")
        }
    }
    
    // Check creation of custom brackets has no teams initially filled
    func testCreateCustomBracketHasNoTeams() throws {
        for numTeams in numTeamsArray {
            let tournament = createCustomTournament(numTeams: numTeams, fillType: CustomType.selectAll)
            let games = Array(tournament.games!) as! [Game]
            let minRound = games.min(by: { $0.round < $1.round })?.round ?? 0
            let gamesInMinRound = games.filter({ $0.round == minRound }).count
            
            XCTAssert(gamesInMinRound == numTeams / 2)
            
            for game in games {
                if game.teams?.count ?? 0 > 0 {
                    XCTFail("Improperly found set teams in selectAll custom tournament of size \(numTeams)")
                }
            }
        }
    }
}
