//
//  foam_madness_team_file_test.swift
//  foam-madness-tests
//
//  Created by Michael Virgo on 3/11/23.
//  Copyright © 2023 mvirgo. All rights reserved.
//

import XCTest

final class foam_madness_teams_file_test: XCTestCase {
    var teamsDict = NSDictionary()

    override func setUpWithError() throws {
        loadTeams()
    }

    override func tearDownWithError() throws {}
    
    func loadTeams() {
        let path = Bundle.main.path(forResource: "teams", ofType: "plist")!
        teamsDict = NSDictionary(contentsOfFile: path)!
    }
    
    func testEachTeamHasAbbreviationAndName() throws {
        for team in teamsDict.allKeys {
            let teamDict = teamsDict.value(forKey: team as! String) as! NSDictionary
            let abbreviation = teamDict.value(forKey: "abbreviation") as? String
            let name = teamDict.value(forKey: "name") as? String
            
            if ((abbreviation ?? "").isEmpty) {
                XCTFail("A team was missing an abbreviation")
            }
            if ((name ?? "").isEmpty) {
                XCTFail("A team was missing a name")
            }
        }
    }
    
    func testAllTeamsHaveDistinctNames() throws {
        // Abbreviations can overlap, but team names should not
        var teamNamesSet = Set<String>()
        for team in teamsDict.allKeys {
            let teamDict = teamsDict.value(forKey: team as! String) as! NSDictionary
            teamNamesSet.insert(teamDict.value(forKey: "name") as! String)
        }
        if (teamNamesSet.count != teamsDict.count) {
            XCTFail("Not all team names are unique")
        }
    }
}
