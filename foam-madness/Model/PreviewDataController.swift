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
    
    private func makeMockGame() {
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
    }
    
    private func makeMockTournaments() {
        let context = container.viewContext
        let exampleTournament1 = Tournament(context: context)
        let exampleTournament2 = Tournament(context: context)
        exampleTournament1.name = "Example Tournament 1"
        exampleTournament2.name = "Example Tournament 2"
    }

    private func loadMockData() {
        // TODO: Add mocks
        let context = container.viewContext
        makeMockGame()
        makeMockTournaments()
        do {
            try context.save()
        } catch {
            print("Failed to save preview mock data.")
        }
    }
}
