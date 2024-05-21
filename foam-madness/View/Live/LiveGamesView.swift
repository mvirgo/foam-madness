//
//  LiveGamesView.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct LiveGamesView: View {
    @State var filter = ""
    @State var liveGames = [Event]()
    @State var loading = false
    let cellPadding = 4.0
    let rowCells = 3.0

    var body: some View {
        GeometryReader { geometry in
            let maxWidth = (geometry.size.width - cellPadding * rowCells) / rowCells
            let filteredGames = filter == "" ? liveGames : liveGames.filter({ $0.league == filter })
            
            VStack {
                Picker("", selection: $filter) {
                    Text("All Leagues").tag("")
                    Text("Mens's NCAA").tag("NCAAM")
                    Text("Women's NCAA").tag("NCAAW")
                    Text("NBA").tag("NBA")
                    Text("WNBA").tag("WNBA")
                }.accentColor(commonBlue)
                if (filteredGames.count > 0) {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())], spacing: cellPadding) {
                            ForEach(filteredGames)
                            { game in
                                LiveGamesCell(game: game)
                                    .frame(width: maxWidth, height: maxWidth)
                                    .cornerRadius(5)
                            }
                        }.padding(cellPadding)
                    }
                } else {
                    VStack {
                        Text(loading ? "Loading games..." : "No games found.").font(.largeTitle)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .navigationTitle("Live Game Scores")
        .onAppear {
            loadGames()
        }
    }
    
    private func loadGames() {
        loading = true
        APIClient.getScores(url: APIClient.Endpoints.getNCAAMScores.url, completion: handleLiveGameScores(response:error:))
        APIClient.getScores(url: APIClient.Endpoints.getNCAAWScores.url, completion: handleLiveGameScores(response:error:))
        APIClient.getScores(url: APIClient.Endpoints.getNBAScores.url, completion: handleLiveGameScores(response:error:))
        APIClient.getScores(url: APIClient.Endpoints.getWNBAScores.url, completion: handleLiveGameScores(response:error:))
    }
    
    private func handleLiveGameScores(response: LiveGamesResponse?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        } else if let response = response {
            // Add events to liveGames array
            for (_, var game) in response.events.enumerated() {
                // Note that there will only be one league in NCAA or (W)NBA APIs
                // Add game
                game.league = response.leagues[0].abbreviation
                liveGames.append(game)
            }
        }
        loading = false
    }
}

struct LiveGamesView_Previews: PreviewProvider {
    static var previews: some View {
        LiveGamesView()
    }
}
