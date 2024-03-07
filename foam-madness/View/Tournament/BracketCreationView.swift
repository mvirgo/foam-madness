//
//  BracketCreationView.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct BracketCreationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    // Passed from previous
    @State var isSimulated: Bool
    @State var chosenBracketFile: String
    
    @State private var showProgress = false
    @State private var progress = 0.0
    @State private var tournamentName = ""
    @State private var rightHanded = true
    @State private var tournamentReady = false
    @State private var tournament: Tournament!
    
    var createTournament: Void {
        // TODO: Check if name already exists
        let tournamentOutput = BracketCreationController(context: viewContext)
            .createBracket(bracketLocation: chosenBracketFile, tournamentName: tournamentName, isSimulated: isSimulated, useLeft: !rightHanded)
        if (isSimulated) {
            // TODO: Use winner for alert
            let _ = BracketCreationController(context: viewContext)
                .simulateTournament(
                    tournament: tournamentOutput.tournament,
                    hasFirstFour: tournamentOutput.hasFirstFour
                )
        }
        tournament = tournamentOutput.tournament
        tournamentReady = true
        return
    }

    var body: some View {
        VStack(spacing: 20) {
            if (showProgress) {
                ProgressView()
            }
            
            Text("Enter Tournament Name").font(.title)
            TextField("Tournament Name", text: $tournamentName)
                .font(.title2)
                .border(Color(UIColor.secondarySystemBackground))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Toggle("\(rightHanded ? "Right" : "Left")-Hand Dominant", isOn: $rightHanded)
                .toggleStyle(SwitchToggleStyle(tint: commonBlue))
                .font(.title2)
            
            if (tournamentReady) {
                NavigationLink("", destination: TournamentGamesView(tournament: tournament), isActive: $tournamentReady)
            } else {
                Button("Create Tournament", action: { createTournament })
                    .buttonStyle(PrimaryButtonFullWidthStyle())
            }
            
            if (showProgress) {
                ProgressView(value: progress).padding(50)
            }
        }
        .padding()
    }
}

struct BracketCreationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BracketCreationView(
                isSimulated: true, chosenBracketFile: "mensBracket2023"
            ).environment(\.managedObjectContext, PreviewDataController.shared.container.viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
