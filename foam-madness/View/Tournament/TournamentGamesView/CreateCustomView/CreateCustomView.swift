//
//  CreateCustomView.swift
//  foam-madness
//
//  Created by Michael Virgo on 5/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct CreateCustomView: View {
    @State var tournament: Tournament
    @State var showGames: Bool = false
    
    var body: some View {
        VStack {
            if !showGames {
                CustomTypeView(tournament: tournament, showGames: $showGames)
            } else {
                ListCustomTeamsView(tournament: tournament)
            }
        }
        .onAppear {
            // Move past selection screen if already added any teams
            let games = tournament.games?.allObjects as! [Game]
            let gamesWithTeams = games.filter({ $0.teams?.count ?? 0 > 0 })
            if gamesWithTeams.count > 0 {
                showGames = true
            }
        }
    }
}

struct CreateCustomView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PreviewDataController.shared.container.viewContext
        let predicate = NSPredicate(format: "ready == NO")
        let tournaments = TourneyHelper.fetchDataFromContext(viewContext, predicate, "Tournament", []) as! [Tournament]
        return NavigationView {
            CreateCustomView(tournament: tournaments[0]).environment(\.managedObjectContext, viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
