//
//  ShootModeView.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct ShootModeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var game: Game
    @State var isSimulated: Bool
    @State private var teams: [Team] = []
    
    // MARK: Display variables
    @State private var currentTeam: String?
    @State private var shotType: String?
    @State private var hand: String?
    @State private var grid: [[Bool]] = Array(repeating: Array(repeating: false, count: 5), count: 2)
    @State private var madeShots: Int16 = 0

    // MARK: Other variables
    @State private var teamFlag = true // True = Team 1 shooting, False = Team 2 shooting
    @State private var overtimeFlag = false
    @State private var isFinished = false
    @State private var scoreMultiplier: Int16 = 1 // Increment by 1 per shot type
    @State private var shootModeController: ShootModeController!
    let overtimeShots: Int16 = 10 // hard-coded number of shots per OT

    var body: some View {
        VStack {
            VStack(spacing: 10) {
                Text(currentTeam ?? "")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
                Text(shotType ?? "").font(.title)
                Text(hand ?? "").font(.title2)
            }
            
            VStack {
                ForEach(0..<2) { row in
                    HStack {
                        ForEach(0..<5) { column in
                            Button(action: {
                                grid[row][column].toggle()
                                madeShots += grid[row][column] ? 1 : -1
                            }) {
                                let num = column + (5 * row) + 1
                                ZStack {
                                    Image(grid[row][column] ? "basketball" : "basketball-gray")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                    Text("\(num)").foregroundColor(.primary).fontWeight(.bold).font(.system(size: getBasketballFontSize()))
                                }
                            }
                        }
                    }
                }
            }
            
            Button("Finished", action: { finishedButtonPressed() })
                .buttonStyle(PrimaryButtonFullWidthStyle()).padding()
            NavigationLink(
                "",
                destination: GameScoreView(game: game),
                isActive: $isFinished
            )
        }
        .onAppear {
            prepView()
        }
    }
    
    // MARK: View-related functions
    func getBasketballFontSize() -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return UIFont.preferredFont(forTextStyle: .largeTitle).pointSize
        }
        return UIFont.preferredFont(forTextStyle: .title3).pointSize
    }
    
    func prepView() {
        teams = GameHelper.getOrderedTeams(game)
        shootModeController = ShootModeController(context: viewContext)

        // Make sure score and OT stats zeroed out
        shootModeController.resetStatistics(game)
        
        // Add game date
        game.datePlayed = Date()
        
        // Simulate or play game
        if isSimulated {
            // Simulate the game
            simGame()
        } else {
            // Get shooting hand for each team based on historical results
            shootModeController.getShootingHands(game)
            // Start the gameplay round
            playRound()
        }
        
        messageAtStart()
    }
    
    func messageAtStart() {
        // Notify user of hand selections
        if !game.completion {
            let handMessage = "\(teams[0].name!) shoots " +
                "\(GameHelper.getHandSideString(game.team1Hand))-handed, " +
                "\(teams[1].name!) shoots " +
            "\(GameHelper.getHandSideString(game.team2Hand))-handed."
            let title = "Shooting Hand"
            alertUser(title: title, message: handMessage, endGame: false)
        }
    }
    
    func finishedButtonPressed() {
        // Either continue game or finish to game score
        if overtimeFlag {
            endOvertimeRound()
        } else if !teamFlag && scoreMultiplier == 4 { // main game is over
            endRound(continueGame: false)
            // Check whether game needs to continue for overtime
            overtimeFlag = shootModeController.overtimeCheck(game)
            if overtimeFlag {
                alertUser(title: "Overtime", message: "Tied Up! Going to OT.", endGame: false)
                playOvertime()
            } else { // full game is over
                completeGame()
            }
        } else {
            endRound(continueGame: true)
        }
    }
    
    func resetGrid() {
        for i in 0..<grid.count {
            for j in 0..<grid[i].count {
                grid[i][j] = false
            }
        }
    }
    
    // MARK: Play-related functions
    func playRound() {
        // Make sure all basketballs are unselected
        madeShots = 0
        resetGrid()
        // Set other display information
        if teamFlag { // first team is playing
            currentTeam = teams[0].name
            hand = GameHelper.getHandSideString(game.team1Hand)
        } else {
            currentTeam = teams[1].name
            hand = GameHelper.getHandSideString(game.team2Hand)
        }
        // Set shot type text based on which point shot is being done
        if overtimeFlag {
            shotType = "Overtime"
        } else if scoreMultiplier == 1 {
            shotType = "\(scoreMultiplier)-point"
        } else {
            shotType = "\(scoreMultiplier)-points"
        }
    }
    
    func endRound(continueGame: Bool) {
        // Add `count` into related team stat
        shootModeController.saveRoundScore(game: game, teamFlag: teamFlag, count: madeShots, scoreMultiplier: scoreMultiplier)
        // Continue game if not finished
        if continueGame {
            // Increment the scoreMultiplier if both teams have gone
            if !teamFlag { // team2 just finished
                scoreMultiplier += 1
            }
            // Flip the team flag
            teamFlag = !teamFlag
            // Play the next round
            playRound()
        }
    }
    
    func saveData() {
        SaveHelper.saveData(viewContext, "ShootModeView")
    }
    
    func playOvertime() {
        // Flip teamFlag
        teamFlag = !teamFlag
        // Play a round
        playRound()
    }
    
    func endOvertimeRound() {
        // Add round points directly to score and update OT stats
        if teamFlag {
            game.team1Score += madeShots
            game.team1OTMade += madeShots
            game.team1OTTaken += overtimeShots
        } else {
            game.team2Score += madeShots
            game.team2OTMade += madeShots
            game.team2OTTaken += overtimeShots
            if !shootModeController.overtimeCheck(game) { // End the game if no longer tied
                saveData()
                completeGame()
            } else {
                alertUser(title: "More OT", message: "Still Tied! More OT coming.", endGame: false)
            }
        }
        // Play another round if segue wasn't called (i.e. still tied)
        playOvertime()
    }
    
    func alertUser(title: String, message: String, endGame: Bool) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if endGame { // Segue after alert view closed
            
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                isFinished = true
            }))
        } else {
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }
        
        let viewController = UIApplication.shared.windows.first!.rootViewController!
        viewController.present(alertVC, animated: true, completion: nil)
    }
    
    func endGameAlert(_ winner: Team) {
        // Set default title and message
        var title = "Game Complete"
        var message = "\(winner.name!) wins the game!"
        // Change the title and message if end of a tournament
        if let tournament = game.tournament {
            if tournament.completion {
                title = "Tournament Complete"
                message = "\(winner.name!) wins the tournament!"
            }
        }
        // Add an addendum if simulated
        if isSimulated {
            message += " (Sim)"
        }
        alertUser(title: title, message: message, endGame: true)
    }
    
    func simGame() {
        SimHelper.simSingleGame(game, teams[0], teams[1])
        saveData()
        completeGame()
    }
    
    func completeGame() {
        let winner = GameHelper.completeGame(viewContext, game, teams[0], teams[1])
        // Let the user know the winner
        endGameAlert(winner)
    }
}

struct ShootModeView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PreviewDataController.shared.container.viewContext
        let games = TourneyHelper.fetchDataFromContext(viewContext, nil, "Game", []) as! [Game]
        return NavigationView {
            ShootModeView(game: games[0], isSimulated: false).environment(\.managedObjectContext, viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
