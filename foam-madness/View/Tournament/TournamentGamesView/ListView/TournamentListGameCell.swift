//
//  TournamentListGameCell.swift
//  foam-madness
//
//  Created by Michael Virgo on 3/11/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct TournamentListGameCell: View {
    @StateObject var game: Game
    @State var allowSelection = false
    
    var body: some View {
        if game.teams?.count == 2 && !allowSelection {
            if game.completion == false {
                NavigationLink {
                    PlayGameView(game: game)
                } label: {
                    getLinkLabel
                }
            } else {
                NavigationLink {
                    GameScoreView(game: game)
                } label: {
                    getLinkLabel
                }.listRowBackground(Color.green.opacity(
                    game.isSimulated ? 0.2 : 0.3
                ))
            }
        } else {
            Group {
                if allowSelection {
                    HStack {
                        NavigationLink {
                            SelectCustomTeamsView(
                                game: game,
                                tournament: game.tournament!
                            )
                        } label: {
                            getLinkLabel
                        }
                    }
                } else {
                    getLinkLabel
                        .listRowBackground(Color.gray)
                }
            }
        }
    }
    
    var getLinkLabel: some View {
        let text = TourneyHelper.getTourneyGameText(game: game)
        return VStack(alignment: .leading) {
            Text(text)
            Text(game.region ?? "").font(.caption)
        }
    }
}

struct TournamentListGameCell_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PreviewDataController.shared.container.viewContext
        let predicate = NSPredicate(format: "completion == YES")
        let games = TourneyHelper.fetchDataFromContext(viewContext, predicate, "Game", []) as! [Game]
        return NavigationView {
            TournamentListGameCell(game: games[0]).environment(\.managedObjectContext, PreviewDataController.shared.container.viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
