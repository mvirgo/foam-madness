//
//  SelectTeamsView.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct SelectTeamsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    let loadedTeams = TeamHelper.loadTeams()
    @State private var teams: [String] = []
    @State private var reverseTeamDict: [String: [String: String]] = [:]

    @State private var team1: String?
    @State private var team2: String?
    
    @State private var progressToGame = false
    @State private var createdGame: Game?

    var body: some View {
        VStack {
            Text("Select Teams").foregroundColor(commonBlue).font(.largeTitle).fontWeight(.bold)
            
            VStack {
                VStack {
                    Text("Team 1").font(.title2).fontWeight(.bold)
                    Picker("First Picker", selection: $team1) {
                        ForEach(teams, id: \.self) { team in
                            Text(team).tag(String?.some(team))
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                
                VStack {
                    Text("Team 2").font(.title2).fontWeight(.bold)
                    Picker("Second Picker", selection: $team2) {
                        ForEach(teams, id: \.self) { team in
                            Text(team).tag(String?.some(team))
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
            }.padding([.top, .bottom])
            
            if (progressToGame) {
                NavigationLink("", destination: PlayGameView(game: createdGame!), isActive: $progressToGame)
            } else {
                Button("Continue") {
                    createGame()
                }
                .buttonStyle(PrimaryButtonFullWidthStyle())
                .padding()
            }
        }
        .onAppear {
            teams = loadedTeams.teams
            reverseTeamDict = loadedTeams.reverseTeamDict
            team1 = teams[0]
            team2 = teams[0]
        }
    }
    
    private func createGame() -> Void {
        if $team1.wrappedValue == $team2.wrappedValue {
            alertUser(title: "Invalid Teams", message: "Selected teams must be different.")
            return
        }
        createdGame = GameHelper.prepareSingleGame(team1!, team2!, reverseTeamDict, viewContext)
        progressToGame = true
    }
    
    private func alertUser(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        let viewController = UIApplication.shared.windows.first!.rootViewController!
        viewController.present(alertVC, animated: true, completion: nil)
    }
}

struct SelectTeamsView_Previews: PreviewProvider {
    static var viewContext = PreviewDataController.shared.container.viewContext

    static var previews: some View {
        return NavigationView {
            SelectTeamsView().environment(\.managedObjectContext, viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
