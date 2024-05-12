//
//  TournamentGamesView.swift
//  foam-madness
//
//  Created by Michael Virgo on 5/12/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct TournamentGamesView: View {
    @State private var showBracketView = false
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
            // TODO: Get the view preferences from the tournament
        }
        .onDisappear {
            // TODO: Store the view preferences on the tournament
        }
        .tag("TournamentGames")
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
