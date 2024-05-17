//
//  CustomTypeView.swift
//  foam-madness
//
//  Created by Michael Virgo on 5/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

enum CustomType {
    case random
    case existing
    case selectAll
}

struct CustomTypeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var tournament: Tournament
    @State var customType = CustomType.random
    @State private var numTeams: Int = 0
    @Binding var showGames: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("How do you want to fill your custom bracket?")
            
            Picker("", selection: $customType) {
                Text("Randomly").tag(CustomType.random)
                if numTeams >= 64 {
                    Text("Base on Existing").tag(CustomType.existing)
                }
                Text("Select All").tag(CustomType.selectAll)
            }
            .pickerStyle(.menu)
            .accentColor(commonBlue)
            .scaleEffect(1.4)
            
            descriptionLabel
                .foregroundColor(.secondary)
            
            if customType == CustomType.existing {
                // TODO: Show and handle year and M/F selection?
                Text("Would allow selecting bracket here")
            }
            
            Button(action: handleContinue, label: {
                Text("Continue")
            })
            .buttonStyle(PrimaryButtonFullWidthStyle())
        }
        .padding([.leading, .trailing], 20)
        .onAppear {
            numTeams = (tournament.games?.count ?? 0) + 1
        }
    }
    
    var descriptionLabel: some View {
        let standardEndText = ", and then you can edit teams and seeds from there."
        switch customType {
        case .random:
            return Text("The bracket will be initially filled with \(numTeams) random teams" + standardEndText)
        case .existing:
            return Text("You'll choose an existing bracket to fill the teams initially" + standardEndText)
        case .selectAll:
            return Text("You'll need to choose all \(numTeams) teams for the bracket, and can edit seeds as well.")
        }
    }
    
    func handleContinue() {
        if customType == CustomType.random {
            BracketCreationController(context: viewContext).fillTournamentWithRandomTeams(tournament)
        }
        // TODO: Logic to use existing bracket, if selected
        showGames = true
    }
}

struct CustomTypeView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PreviewDataController.shared.container.viewContext
        let predicate = NSPredicate(format: "ready == NO")
        let tournaments = TourneyHelper.fetchDataFromContext(viewContext, predicate, "Tournament", []) as! [Tournament]
        return NavigationView {
            CustomTypeView(tournament: tournaments[0], showGames: .constant(false)).environment(\.managedObjectContext, viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
