//
//  SelectInitialBracketShellView.swift
//  foam-madness
//
//  Created by Michael Virgo on 5/17/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

// Shell view to allow use of chosenBracketFile outside of SelectInitialBracketView
struct SelectInitialBracketShellView: View {
    @State var isSimulated: Bool
    @State private var chosenBracketFile: String?
    
    var body: some View {
        SelectInitialBracketView(
            isSimulated: isSimulated,
            chosenBracketFile: $chosenBracketFile
        )
    }
}

struct SelectInitialBracketShellView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SelectInitialBracketShellView(isSimulated: false).environment(\.managedObjectContext, PreviewDataController.shared.container.viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
