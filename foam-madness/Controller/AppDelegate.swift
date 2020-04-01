//
//  AppDelegate.swift
//  foam-madness
//
//  Created by Michael Virgo on 3/27/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let dataController = DataController(modelName: "foam-madness")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        dataController.load()
        let managedObjectContext = dataController.viewContext
        
        // TODO: Remove test data below from full app
        // Create a tournament
        let tournament = Tournament(context: managedObjectContext)
        // Configure tournament
        tournament.name = "Test Tourney"
        // Create two teams
        let team1 = Team(context: managedObjectContext)
        let team2 = Team(context: managedObjectContext)
        // Configure the teams
        team1.name = "Kansas"
        team1.abbreviation = "KU"
        team1.id = 1
        team2.name = "Duke"
        team2.abbreviation = "DU"
        team2.id = 2
        // Create a game
        let game = Game(context: managedObjectContext)
        // Configure the game
        game.round = 1
        game.region = "Midwest"
        game.team1Id = team1.id
        game.team2Id = team2.id
        game.team1Seed = 1
        game.team2Seed = 2
        game.addToTeams(team1)
        game.addToTeams(team2)
        team1.addToGames(game)
        team2.addToGames(game)
        // Add game to tournament
        tournament.addToGames(game)
        // Save everything
        do {
            try managedObjectContext.save()
        } catch {
            print("Failed to save.")
        }
        
        // TODO: Use appropriate root view controller for whole tournament
        let playGameViewController = window?.rootViewController as! PlayGameViewController
        playGameViewController.dataController = dataController
        playGameViewController.game = game
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        saveViewContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        saveViewContext()
    }
    
    // MARK: - Core Data Saving support
    func saveViewContext() {
        try? dataController.viewContext.save()
    }

}

