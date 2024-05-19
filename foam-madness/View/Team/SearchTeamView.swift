//
//  SearchTeamView.swift
//  foam-madness
//
//  Created by Michael Virgo on 3/12/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct SearchTeamView: View {
    @State private var searchText = ""
    @State private var shownTeamName = ""
    @Binding var isTyping: Bool
    @Binding var teamName: String
    @Binding var showParentButton: Bool
    var label: String
    var teams: [String]
    
    
    var searchResults: [String] {
        searchText.isEmpty ? [] : teams.filter{$0.localizedCaseInsensitiveContains(searchText)}
    }
        
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 10) {
                Text(label).fontWeight(.bold)
                SearchBar(text: $searchText, filteredData: teams)
            }.padding([.leading])
            
            if (searchResults.count > 0 && shownTeamName == "") {
                List {
                    ForEach(searchResults, id: \.self) { team in
                        Button(team, action: { setFields(team) })
                            .tag(String?.some(team))
                    }
                }
                .listStyle(.plain)
            }
        }
        .onAppear {
            // Custom games selector may have an existing team
            if teamName != "" {
                searchText = teamName
                shownTeamName = teamName
            }
        }
        .onChange(of: searchText) { _ in
            if searchText == "" {
                // Cleared the search bar
                clearFields()
            } else if shownTeamName != "" && shownTeamName != searchText {
                // Backspaced, clear out
                clearFields()
            }
        }
        .onChange(of: searchResults + [shownTeamName, searchText]) { _ in
            if searchResults.count > 0 && shownTeamName != searchText {
                isTyping = true
            } else {
                isTyping = false
            }
        }
    }
    
    func clearFields() {
        shownTeamName = "" // allow list to show again
        teamName = "" // update for parent
        showParentButton = false // update for parent
    }
    
    func setFields(_ team: String) {
        teamName = team // update for parent
        showParentButton = true // update for parent
        shownTeamName = team // hide the list
        searchText = team // show user the selected team
        UIApplication.shared.endEditing()
    }
}

// Hide the keyboard
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct SearchTeamView_Previews: PreviewProvider {
    static var viewContext = PreviewDataController.shared.container.viewContext

    static var previews: some View {
        let teams = TeamHelper.loadTeams().teams
        return SearchTeamView(
            isTyping: .constant(false),
            teamName: .constant(""),
            showParentButton: .constant(false),
            label: "Team 1",
            teams: teams
        ).environment(\.managedObjectContext, viewContext)
    }
}
