//
//  UpdateRegionsView.swift
//  foam-madness
//
//  Created by Michael Virgo on 5/18/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct UpdateRegionsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var games: NSSet
    @State private var originalRegions: [String] = []
    @State private var currentRegions: [String] = []
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Update Region Names")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(commonBlue)
            
            LazyVStack(spacing: 20) {
                ForEach(currentRegions.indices, id: \.self) { index in
                    TextField(originalRegions[index], text: $currentRegions[index])
                        .disableAutocorrection(true)
                        .textFieldStyle(.roundedBorder)
                        .padding([.leading, .trailing], 20)
                }
            }
            .padding([.top, .bottom], 20)
            .background(commonBlue.opacity(0.2))
            
            Button("Confirm Names") {
                handleConfirmNames()
            }
            .buttonStyle(PrimaryButtonFullWidthStyle())
            .scaleEffect(0.8)
            
            Spacer()
        }
        .padding([.top])
        .onAppear {
            let gamesArray = Array(games) as! [Game]
            let sortedGames = gamesArray.sorted() { $0.tourneyGameId < $1.tourneyGameId }

            let tournamentRegions = sortedGames.compactMap { $0.region }
            let uniqueTournamentRegions = Array(Set(tournamentRegions))
            let filteredRegions = uniqueTournamentRegions.filter({
                $0 != "Final Four" && $0 != "Championship"
            }).sorted() { $0 < $1 }
            
            originalRegions = filteredRegions
            currentRegions = filteredRegions
        }
    }
    
    private func handleConfirmNames() {
        for region in currentRegions {
            if region == "" {
                alertUser(title: "Missing Name", message: "Please give a name to all regions.")
                return
            }
        }
        
        let uniqueRegions = Set(currentRegions)
        if uniqueRegions.count != currentRegions.count {
            alertUser(title: "Unique Regions", message: "All region names must be unique.")
            return
        }
        
        // Update all games for each updated region
        for (i, region) in currentRegions.enumerated() {
            if region != originalRegions[i] {
                BracketCreationController(context: viewContext)
                    .updateRegionNameForGames(
                        originalName: originalRegions[i], newName: region, gamesSet: games
                    )
            }
        }
        
        presentationMode.wrappedValue.dismiss()
    }
    
    private func alertUser(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        let viewController = UIApplication.shared.windows.first!.rootViewController!
        viewController.present(alertVC, animated: true, completion: nil)
    }
}

struct UpdateRegionsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PreviewDataController.shared.container.viewContext
        let predicate = NSPredicate(format: "ready == NO")
        let tournaments = TourneyHelper.fetchDataFromContext(viewContext, predicate, "Tournament", []) as! [Tournament]
        return NavigationView {
            UpdateRegionsView(games: tournaments[0].games!).environment(\.managedObjectContext, viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
