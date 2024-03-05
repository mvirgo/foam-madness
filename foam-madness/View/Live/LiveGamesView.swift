//
//  LiveGamesView.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct LiveGamesView: View {
    @State var liveGames = [Event]()
    @State var loading = false
    let cellPadding = 4.0
    let rowCells = 3.0

    var body: some View {
        GeometryReader { geometry in
            let maxWidth = (geometry.size.width - cellPadding * rowCells) / rowCells
            
            if (liveGames.count > 0) {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())], spacing: cellPadding) {
                        ForEach(liveGames)
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
        }.navigationTitle("Live Game Scores")
    }
}

struct LiveGamesView_Previews: PreviewProvider {
    static var previews: some View {
        var example: Event {
            let competitor1 = Competitor(team: RealTeam(abbreviation: "Team A"), score: "5")
            let competitor2 = Competitor(team: RealTeam(abbreviation: "Team B"), score: "3")
            let competition = Competition(competitors: [competitor1, competitor2])
            let status = Status(type: Type(shortDetail: "In Progress"))
            let league = "NCAAM"
            
            return Event(league: league, competitions: [competition], status: status)
        }
        LiveGamesView(liveGames: [example, example, example, example])
    }
}
