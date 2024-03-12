//
//  TournamentGameCell.swift
//  foam-madness
//
//  Created by Michael Virgo on 3/11/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct TournamentGameCell: View {
    @StateObject var game: Game
    
    var body: some View {
        if game.teams?.count == 2 {
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
            Text("Pending participants").listRowBackground(Color.gray)
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

struct TournamentGameCell_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PreviewDataController.shared.container.viewContext
        let predicate = NSPredicate(format: "completion == YES")
        let games = TourneyHelper.fetchDataFromContext(viewContext, predicate, "Game", []) as! [Game]
        return NavigationView {
            TournamentGameCell(game: games[0]).environment(\.managedObjectContext, PreviewDataController.shared.container.viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
