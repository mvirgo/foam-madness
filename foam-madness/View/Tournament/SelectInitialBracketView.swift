//
//  SelectInitialBracketView.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct SelectInitialBracketView: View {
    @State var isSimulated: Bool
    @State var chosenBracketFile: String?

    let brackets = BracketHelper.loadBrackets()

    var body: some View {
        List {
            ForEach(brackets.reversed(), id: \.self) { bracket in
                NavigationLink(
                    destination:
                        BracketCreationView(
                            isSimulated: isSimulated,
                            chosenBracketFile: chosenBracketFile ?? ""
                        )
                ) {
                    Text(bracket.first?.value ?? "")
                }
                .buttonStyle(.plain)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
             ToolbarItem(placement: .principal) {
                 Text("Choose a Starting Bracket")
                     .fontWeight(.bold)
            }
        }
    }
}

struct SelectInitialBracketView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SelectInitialBracketView(isSimulated: false).environment(\.managedObjectContext, PreviewDataController.shared.container.viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
