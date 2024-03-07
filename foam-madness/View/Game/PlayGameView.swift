//
//  PlayGameView.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct PlayGameView: View {
    @State var game: Game
    @State var teams: [Team] = []
    @State var team1: String?
    @State var team2: String?

    var body: some View {
        VStack {
            VStack(spacing: 15) {
                Text(game.region ?? "").foregroundColor(commonBlue).font(.title).fontWeight(.bold)
                Text(GameHelper.getRoundString(game.round)).foregroundColor(commonBlue).font(.title2)
                Text(team1 ?? "")
                    .font(.largeTitle)
                    .minimumScaleFactor(0.5)
                Text("VS")
                Text(team2 ?? "")
                    .font(.largeTitle)
                    .minimumScaleFactor(0.5)
            }
            
            NavigationLink(destination: ShootModeView(game: game, isSimulated: false)) {
                Text("Play Game")
            }.buttonStyle(PrimaryButtonFullWidthStyle()).padding()
            
            NavigationLink(destination: ShootModeView(game: game, isSimulated: true)) {
                Text("Sim Game")
            }.buttonStyle(PrimaryButtonFullWidthStyle()).padding()
        }
        .onAppear {
            setTeamNames()
        }
    }
    
    func setTeamNames() {
        let gameTeams = game.teams?.allObjects as! [Team]
        // Ensure proper order of teams
        if gameTeams[0].id == game.team1Id {
            teams = gameTeams
        } else {
            teams = [gameTeams[1], gameTeams[0]]
        }
        // Show seed depending on if game is in a tourney
        if let _ = game.tournament {
            team1 = String(game.team1Seed) + " - " + teams[0].name!
            team2 = String(game.team2Seed) + " - " + teams[1].name!
        } else {
            team1 = teams[0].name!
            team2 = teams[1].name!
        }
    }
}

struct PlayGameView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PreviewDataController.shared.container.viewContext
        let games = TourneyHelper.fetchDataFromContext(viewContext, nil, "Game", []) as! [Game]
        return NavigationView {
            PlayGameView(game: games[0]).environment(\.managedObjectContext, viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
