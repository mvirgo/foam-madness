//
//  TeamHelper.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/23/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import CoreData
import Foundation

struct LoadedTeams {
    var teams: [String]
    var reverseTeamDict: [String: [String: String]]
}

class TeamHelper {
    static func loadTeams() -> LoadedTeams {
        // Load in teams list
        let path = Bundle.main.path(forResource: "teams", ofType: "plist")!
        let dict = NSDictionary(contentsOfFile: path)!
        // Add team name to a temporary array
        var tempTeams: [String] = [String]()
        var reverseTeamDict = [String: [String: String]]()
        for key in dict.allKeys {
            let name = (dict.value(forKey: key as! String) as! NSDictionary).value(forKey: "name") as? String
            tempTeams.append(name!)
            // Add to reverseTeamDict for lookup of abbreviation/id later
            let abbreviation = (dict.value(forKey: key as! String) as! NSDictionary).value(forKey: "abbreviation") as? String
            reverseTeamDict[name!] = ["id": String(describing: key), "abbreviation": abbreviation!]
        }
        // Sort the temporary array for easy selection
        tempTeams.sort()
        
        let loadedTeams = LoadedTeams(teams: tempTeams, reverseTeamDict: reverseTeamDict)
        
        return loadedTeams
    }
    
    static func lookupOrCreateTeam(teamName: String, reverseTeamDict: [String: [String: String]], context: NSManagedObjectContext) -> Team {
        let teamId = Int16((reverseTeamDict[teamName]?["id"])!) ?? 0
        let team: Team
        // Use a fetch request to see if teamId already in data
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Team")
        let predicate = NSPredicate(format: "id == %@", NSNumber(value: teamId))
        fetchRequest.predicate = predicate
        // Fetch the results
        let results = try! context.fetch(fetchRequest)
        // If results contains anything, just set the team as the result
        if results.count > 0 {
            team = results[0] as! Team
        } else { // create the team
            team = Team(context: context)
            team.name = teamName
            team.abbreviation = reverseTeamDict[teamName]?["abbreviation"]
            team.id = teamId
        }
        
        return team
    }
}
