//
//  LiveGamesResponse.swift
//  foam-madness
//
//  Created by Michael Virgo on 9/13/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import Foundation

struct LiveGamesResponse: Codable {
    let leagues: [League]
    let events: [Event]
}

struct League: Codable {
    let abbreviation: String
}

struct Event: Codable, Identifiable {
    var id = UUID()
    var league: String
    let competitions: [Competition]
    let status: Status
    
    init(league: String, competitions: [Competition], status: Status) {
        self.league = league
        self.competitions = competitions
        self.status = status
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        competitions = try container.decode([Competition].self, forKey: .competitions)
        status = try container.decode(Status.self, forKey: .status)
        league = "" // filled in separate request
    }
}

struct Competition: Codable {
    let competitors: [Competitor]
}

struct Status: Codable {
    let type: Type
}

struct Competitor: Codable {
    let team: RealTeam
    let score: String
}

struct Type: Codable {
    let shortDetail: String
}

struct RealTeam: Codable {
    let abbreviation: String
}
