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

struct Event: Codable {
    let competitions: [Competition]
    let status: Status
}

struct Competition: Codable {
    let competitors: [Competitor]
}

struct Status: Codable {
    let displayClock: String
    let type: Type
}

struct Competitor: Codable {
    let team: RealTeam
    let score: String
}

struct Type: Codable {
    let completed: Bool
    let shortDetail: String
}

struct RealTeam: Codable {
    let abbreviation: String
}
