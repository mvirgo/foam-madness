//
//  LiveGamesView.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct LiveGamesView: View {
    @StateObject private var liveGamesModel = LiveGamesModel()
    @State var filter = ""
    private let cellPadding = 4.0
    private let rowCells = 3.0

    var body: some View {
        GeometryReader { geometry in
            let maxWidth = (geometry.size.width - cellPadding * rowCells) / rowCells
            let filteredGames =
                filter == ""
                    ? liveGamesModel.liveGames
                    : liveGamesModel.liveGames.filter({ $0.league == filter })
            
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
                        Text(liveGamesModel.loading ? "Loading games..." : "No games found.").font(.largeTitle)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .navigationTitle("Live Game Scores")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { liveGamesModel.refreshData() }, label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                })
            }
        }
    }
}

struct LiveGamesView_Previews: PreviewProvider {
    static var previews: some View {
        LiveGamesView()
    }
}
