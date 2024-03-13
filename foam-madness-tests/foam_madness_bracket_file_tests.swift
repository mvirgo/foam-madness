//
//  foam_madness_tests.swift
//  foam-madness-tests
//
//  Created by Michael Virgo on 3/11/23.
//  Copyright © 2023 mvirgo. All rights reserved.
//

import XCTest
@testable import foam_madness

final class foam_madness_bracket_file_tests: XCTestCase {
    let bracketIndexFile = "bracketIndex"
    
    var brackets: [BracketItem] = []
    var currentBracketName: String = ""
    var hasFirstFour = false
    var regions = [String: [String: Int16]]()

    override func setUpWithError() throws {
        loadBrackets();
    }

    override func tearDownWithError() throws {}
    
    func loadBrackets() {
        // Load the bracket index
        brackets = BracketHelper.loadBrackets()
    }
    
    func loadSingleBracket(bracket: BracketItem) {
        currentBracketName = bracket.name
        let bracketLocation = bracket.file
        // Load the given bracket
        let bracketPath = Bundle.main.path(forResource: bracketLocation, ofType: "plist")!
        let bracketDict = NSDictionary(contentsOfFile: bracketPath)!
        let isWomens = bracketDict.value(forKey: "IsWomens") as! Bool
        let year = bracketDict.value(forKey: "Year") as! Int
        hasFirstFour = !isWomens || year >= 2022
        regions = bracketDict.value(forKey: "Regions") as! Dictionary<String, [String: Int16]>
    }
    
    func hasValidTeamCount(count: Int) -> Bool {
        return (hasFirstFour && count == 68) || (!hasFirstFour && count == 64)
    }
    
    func testFourRegions() throws {
        brackets.forEach {
            loadSingleBracket(bracket: $0)
            if regions.count != 4 {
                XCTFail("Bracket \(currentBracketName) does not have four regions.")
            }
        }
    }
    
    func testNumberOfTeams() throws {
        brackets.forEach {
            var count = 0
            loadSingleBracket(bracket: $0)
            regions.forEach {
                count += $0.value.count
            }
            if (!hasValidTeamCount(count: count)) {
                XCTFail("Bracket \(currentBracketName) does not have the correct number of teams.")
            }
        }
    }

    func testNoDuplicateTeams() throws {
        brackets.forEach {
            var teamIdsSet = Set<Int16>()
            loadSingleBracket(bracket: $0)
            regions.forEach {
                $0.value.forEach {
                    teamIdsSet.insert($0.value)
                }
            }
            if (!hasValidTeamCount(count: teamIdsSet.count)) {
                XCTFail("Bracket \(currentBracketName) has a duplicate team.")
            }
        }
    }
}
