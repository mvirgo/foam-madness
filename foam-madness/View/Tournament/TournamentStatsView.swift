//
//  TournamentStatsView.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

let titleText = ["Total", "Left Hand", "Right Hand"]

struct TournamentStatsView: View {
    // TODO: Import tournament
    @State private var selectedHand = 0

    var body: some View {
        VStack(spacing: 30) {
            Text("\(titleText[selectedHand]) Stats")
                .font(.largeTitle)

            HStack {
                labels
                Spacer()
                stats
            }
            .padding([.leading, .trailing], 20)
            .font(.title2)

            Picker("", selection: $selectedHand) {
                Text("Total").tag(0)
                Text("Left").tag(1)
                Text("Right").tag(2)
            }
            .pickerStyle(.segmented)
        }
        .padding([.leading, .trailing], 50)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Export", action: exportTournament)
            }
        }
    }
    
    var labels: some View {
        VStack(alignment: .leading) {
            if (selectedHand == 0) {
                Text("Games")
                Text("Upsets")
            } else {
                let hand = selectedHand == 1 ? "L" : "R"
                let oppHand = selectedHand == 1 ? "R" : "L"
                Text("Games vs \(oppHand)")
                Text("Upsets vs \(oppHand)")
                Text("Win % vs \(oppHand)")
                Text("Games vs \(hand)")
            }
            Text("Pts per Game")
            Text("Total FG%")
            Text("1 ptr FG%")
            Text("2 ptr FG%")
            Text("3 ptr FG%")
            Text("4 ptr FG%")
            // TODO: Conditionally show
            Text("OT FG%")
        }
    }
    
    var stats: some View {
        VStack(alignment: .trailing) {
            // TODO: Pull actual stats
            if (selectedHand == 0) {
                Text("20")
                Text("21")
            } else {
                Text("22")
                Text("23")
                Text("24")
                Text("25")
            }
            Text("26")
            Text("27")
            Text("28")
            Text("29")
            Text("30")
            Text("31")
            // TODO: Conditionally show
            Text("32")
        }
    }
    
    private func exportTournament() {
        // TODO: Implement
        print("Would export here.")
    }
}

struct TournamentStatsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TournamentStatsView().environment(\.managedObjectContext, PreviewDataController.shared.container.viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
