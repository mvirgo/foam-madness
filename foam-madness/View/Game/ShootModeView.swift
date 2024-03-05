//
//  ShootModeView.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct ShootModeView: View {
    @State var game: Game
    @State var teams: [Team]
    @State var currentTeam: String?
    @State var shotType: String?
    @State var hand: String?
    @State var isSimulated: Bool
    @State private var grid: [[Bool]] = Array(repeating: Array(repeating: false, count: 5), count: 2)
    @State private var counter = 0

    var body: some View {
        VStack {
            VStack(spacing: 10) {
                Text(currentTeam ?? "").font(.largeTitle).fontWeight(.bold)            .minimumScaleFactor(0.5)
                Text(shotType ?? "").font(.title)
                Text(hand ?? "").font(.title2)
            }
            
            VStack {
                ForEach(0..<2) { row in
                    HStack {
                        ForEach(0..<5) { column in
                            Button(action: {
                                grid[row][column].toggle()
                                counter += grid[row][column] ? 1 : -1
                            }) {
                                let num = column + (5 * row) + 1
                                ZStack {
                                    Image(grid[row][column] ? "basketball" : "basketball-gray")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                    Text("\(num)").foregroundColor(.primary).fontWeight(.bold).font(.system(size: getBasketballFontSize()))
                                }
                            }
                        }
                    }
                }
            }
            
            // TODO: This should instead save game by round, and at end have an alert that segues instead
            NavigationLink(destination: GameScoreView(game: game)) {
                Text("Finished")
            }.buttonStyle(PrimaryButtonFullWidthStyle()).padding()
        }
        .onAppear {
            currentTeam = teams[0].name
        }
    }
    
    func getBasketballFontSize() -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return UIFont.preferredFont(forTextStyle: .largeTitle).pointSize
        }
        return UIFont.preferredFont(forTextStyle: .title3).pointSize
    }
}

struct ShootModeView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PreviewDataController.shared.container.viewContext
        let games = TourneyHelper.fetchDataFromContext(viewContext, nil, "Game", []) as! [Game]
        let game = games[0]
        let teams = game.teams?.allObjects as! [Team]
        return NavigationView {
            ShootModeView(game: game, teams: teams, currentTeam: "Kansas", shotType: "1-point", hand: "Left", isSimulated: false).environment(\.managedObjectContext, viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
