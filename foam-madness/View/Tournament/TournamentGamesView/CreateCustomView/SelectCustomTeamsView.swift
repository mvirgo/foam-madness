//
//  SelectCustomTeamsView.swift
//  foam-madness
//
//  Created by Michael Virgo on 5/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct SelectCustomTeamsView: View {
    @State var tournament: Tournament
    
    var body: some View {
        // TODO: Logic to verify when can continue
        // TODO: Logic to update to ready & save; check this changes view
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct SelectCustomTeamsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PreviewDataController.shared.container.viewContext
        let predicate = NSPredicate(format: "ready == NO")
        let tournaments = TourneyHelper.fetchDataFromContext(viewContext, predicate, "Tournament", []) as! [Tournament]
        return NavigationView {
            SelectCustomTeamsView(tournament: tournaments[0]).environment(\.managedObjectContext, viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
