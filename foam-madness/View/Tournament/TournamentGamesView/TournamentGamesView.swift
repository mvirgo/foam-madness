//
//  TournamentGamesView.swift
//  foam-madness
//
//  Created by Michael Virgo on 5/12/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct TournamentGamesView: View {
    @State var showBracketView: Bool
    @State var tournament: Tournament
    
    var body: some View {
        Group {
            if showBracketView {
                BracketGamesView(tournament: tournament, hideListView: $showBracketView)
            } else {
                TournamentListGamesView(tournament: tournament, bracketView: $showBracketView)
            }
        }
        .onAppear {
            showBracketView = tournament.useBracketView
        }
        .onDisappear {
            tournament.useBracketView = showBracketView
        }
        .tag("TournamentGames")
    }
}

struct TournamentGamesView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PreviewDataController.shared.container.viewContext
        let tournaments = TourneyHelper.fetchDataFromContext(viewContext, nil, "Tournament", []) as! [Tournament]
        return NavigationView {
            TournamentGamesView(
                showBracketView: tournaments[0].useBracketView,
                tournament: tournaments[0]).environment(\.managedObjectContext, viewContext
                )
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
