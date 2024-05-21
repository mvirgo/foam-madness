//
//  foam_madness_sim_existing_bracket_test.swift
//  foam-madness-tests
//
//  Created by Michael Virgo on 5/20/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import CoreData
import XCTest
@testable import foam_madness

final class foam_madness_sim_existing_bracket_test: XCTestCase {
    var bracketCreationController: BracketCreationController!
    var viewContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        viewContext = CoreDataTestStack.shared.context
        bracketCreationController = BracketCreationController(context: viewContext)
    }

    override func tearDownWithError() throws {
        viewContext = nil
    }

    func testCreateAndSimExistingBrackets() throws {
        let brackets = BracketHelper.loadBrackets()
        
        for bracket in brackets {
            let tournament = bracketCreationController.createBracketFromFile(
                bracketLocation: bracket.file,
                tournamentName: bracket.name,
                isSimulated: true,
                useLeft: false,
                shotsPerRound: AppConstants.defaultShotsPerRound
            )
            let winner = bracketCreationController.simulateTournament(tournament: tournament)
            
            XCTAssert(winner != "")
        }
    }
}
