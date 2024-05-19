//
//  SelectNumTeamsView.swift
//  foam-madness
//
//  Created by Michael Virgo on 5/17/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

let numTeamsArray = [64, 32, 16, 8, 4]

struct SelectNumTeamsView: View {
    @Binding var numTeams: Int
    let gridPadding = 10.0
    
    var body: some View {
        VStack {
            Text("Number of Teams").font(.title2)
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: gridPadding) {
                ForEach(numTeamsArray, id: \.self) { teams in
                    Button(action: {
                        numTeams = teams
                    }) {
                        Text("\(teams)")
                            .lineLimit(1)
                            .font(.headline)
                            .foregroundColor(numTeams == teams ? Color.white : Color.primary)
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .background(numTeams == teams ? commonBlue : Color.secondary)
                    .cornerRadius(5.0)
                }
            }.padding(gridPadding)
        }
    }
}

struct SelectNumTeamsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SelectNumTeamsView(numTeams: .constant(64)).environment(\.managedObjectContext, PreviewDataController.shared.container.viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
