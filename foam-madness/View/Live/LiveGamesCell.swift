//
//  LiveGamesCell.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct LiveGamesCell: View {
    @State var game: Event

    var body: some View {
        Color(UIColor.secondarySystemBackground).overlay(
            VStack {
                let teams = game.competitions[0].competitors
                Text(game.league)
                    .padding(2)
                HStack() {
                    Text(teams[0].team.abbreviation)
                    Spacer()
                    Text(teams[0].score)
                }.padding([.leading, .trailing])
                HStack() {
                    Text(teams[1].team.abbreviation)
                    Spacer()
                    Text(teams[1].score)
                }.padding([.leading, .trailing])
                Text(game.status.type.shortDetail).lineLimit(1)
                    .padding(2)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }.minimumScaleFactor(0.5)
        )
    }
}

struct LiveGamesCellView_Previews: PreviewProvider {
    static var previews: some View {
        var example: Event {
            let competitor1 = Competitor(team: RealTeam(abbreviation: "Team A"), score: "5")
            let competitor2 = Competitor(team: RealTeam(abbreviation: "Team B"), score: "3")
            let competition = Competition(competitors: [competitor1, competitor2])
            let status = Status(type: Type(shortDetail: "In Progress"))
            let league = "NCAAM"
            
            return Event(league: league, competitions: [competition], status: status)
        }
        LiveGamesCell(game: example)
    }
}
