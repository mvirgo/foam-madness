//
//  TournamentGamesView.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct TournamentGamesView: View {
    @State private var round: Int16 = 0
    @State private var roundText = "ROUND"
    @State private var games: [Game] = []
    @State var tournament: Tournament
    
    var body: some View {
        VStack {
            Text(GameHelper.getRoundString(round))
                .foregroundColor(commonBlue)
                .font(.largeTitle)
                .fontWeight(.bold)

            List {
                ForEach(games.filter({ $0.round == round }), id: \.id) { game in
                    if game.teams?.count == 2 {
                        let text = getGameText(game: game)
                        if game.completion == false {
                            NavigationLink(text, destination: PlayGameView(game: game))
                        } else {
                            NavigationLink(text, destination: GameScoreView(game: game))
                                .background(Color.green.opacity(
                                    game.isSimulated ? 0.2 : 0.3
                                ))
                        }
                    } else {
                        Text("Pending participants").listRowBackground(Color.gray)
                    }
                }
            }
            Text("Change Round")
                .foregroundColor(commonBlue)
                .font(.title2)
                .fontWeight(.bold)
            Stepper(value: $round, in: 0...6) {
                Text("")
            }
                .labelsHidden()
                .padding([.bottom])
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationTitle(tournament.name ?? "Tournament Games")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Main Menu", action: {
                    NavigationUtil.popToRootView()
                })
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink("Stats", destination: TournamentStatsView(tournament: tournament))
            }
        }
        .onAppear {
            getSortedGames()
        }
        .tag("TournamentGames")
    }
    
    func getGameText(game: Game) -> String {
        let teams = GameHelper.getOrderedTeams(game)
        let team1 = teams[0]
        let team2 = teams[1]
        var gameText = ""
        if game.completion { // game over, show score
            // Make sure winner is shown first
            if game.team1Score > game.team2Score {
                gameText = "\(game.team1Seed) \(team1.name!):  \(game.team1Score), \(game.team2Seed) \(team2.name!):  \(game.team2Score)"
            } else {
                gameText = "\(game.team2Seed) \(team2.name!):  \(game.team2Score), \(game.team1Seed) \(team1.name!):  \(game.team1Score)"
            }
            // Add OT note, if applicable
            if game.team1OTTaken > 0 {
                gameText += " - OT"
            }
            // Add simulated note, if applicable
            if game.isSimulated {
                gameText += " (Sim)"
            }
        } else { // Game is ready to play
            gameText = "\(game.team1Seed) \(team1.name!) vs. \(game.team2Seed) \(team2.name!)"
        }
        
        return gameText
    }
    
    func getSortedGames() {
        games = Array(tournament.games!) as! [Game]
        games = games.sorted() { $0.tourneyGameId < $1.tourneyGameId }
    }
}

struct TournamentGamesView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PreviewDataController.shared.container.viewContext
        let tournaments = TourneyHelper.fetchDataFromContext(viewContext, nil, "Tournament", []) as! [Tournament]
        return NavigationView {
            TournamentGamesView(tournament: tournaments[0]).environment(\.managedObjectContext, viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
