//
//  MenuView.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct MenuView: View {
    @FetchRequest(entity: Tournament.entity(), sortDescriptors: [])
    private var tournaments: FetchedResults<Tournament>

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    Text("Tournament Mode")
                    
                    if (hasCurrentTournaments()) {
                        NavigationLink(destination: SelectTournamentView(completedTournaments: false, tournaments: Array(tournaments))) {
                            Text("Resume Tournament") }.buttonStyle(PrimaryButtonFullWidthStyle())
                    }
                    NavigationLink(destination: SelectInitialBracketView(isSimulated: false)) {
                        Text("New Tournament") }.buttonStyle(PrimaryButtonFullWidthStyle())
                    NavigationLink(destination: SelectInitialBracketView(isSimulated: true)) {
                        Text("Quick Sim Tournament") }.buttonStyle(PrimaryButtonFullWidthStyle())
                    if (hasCompletedTournaments()) {
                        NavigationLink(destination: SelectTournamentView(completedTournaments: true, tournaments: Array(tournaments))) {
                            Text("View Finished Tournament") }.buttonStyle(PrimaryButtonFullWidthStyle())
                    }
                }.fixedSize(horizontal: true, vertical: false)

                VStack(spacing: 10) {
                    Text("Single Game")
                    NavigationLink(destination: SelectTeamsView()) {
                        Text("Play Game")}.buttonStyle(PrimaryButtonStyle())
                }

                VStack(spacing: 10) {
                    Text("Live Scores")
                    NavigationLink(destination: LiveGamesView()) {
                        Text("View Live Scores")}.buttonStyle(PrimaryButtonStyle())
                }
            }
            .font(.system(size: 36))
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Main Menu").font(.system(size: 24)).fontWeight(.bold)
                }
                ToolbarItem(placement: .topBarTrailing) { NavigationLink("About", destination: AboutView()).font(.system(size: 24))
                }
            }
            .minimumScaleFactor(0.8)
            .padding([.bottom], 40)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func hasCurrentTournaments() -> Bool {
        return tournaments.filter({ $0.completion == false}).count > 0
    }
    
    private func hasCompletedTournaments() -> Bool {
        return tournaments.filter({ $0.completion == true}).count > 0
    }
}

struct MenuView_Previews: PreviewProvider {
    static var viewContext = PreviewDataController.shared.container.viewContext
    
    static var previews: some View {
        NavigationView {
            MenuView().environment(\.managedObjectContext, viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
