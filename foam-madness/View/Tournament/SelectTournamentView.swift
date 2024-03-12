//
//  SelectTournamentView.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct SelectTournamentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    // Whether to display completed or incomplete tournaments
    @State var completedTournaments: Bool
    @State var tournaments: [Tournament]
    @State var shownTournaments: [Tournament] = []

    var body: some View {
        List {
            ForEach(shownTournaments, id: \.self) { tournament in
                NavigationLink(tournament.name ?? "", destination: TournamentGamesView(tournament: tournament))
            }
            .onDelete(perform: deleteItems)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(completedTournaments
            ? "Choose a Completed Tournament"
            : "Choose an Existing Tournament"
        )
        .onAppear {
            getShownTournaments()
        }
    }
    
    private func getShownTournaments() {
        shownTournaments = tournaments.filter({ $0.completion == completedTournaments}).sorted(by: { t1, t2 in
            t1.createdDate ?? Date() < t2.createdDate ?? Date()
        })
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { tournaments[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                print("Failed to save on tournament deletion.")
            }
        }
    }
}

struct SelectTournamentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PreviewDataController.shared.container.viewContext
        let tournaments = TourneyHelper.fetchDataFromContext(viewContext, nil, "Tournament", []) as! [Tournament]
        return NavigationView {
            SelectTournamentView(completedTournaments: false, tournaments: tournaments).environment(\.managedObjectContext, viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
