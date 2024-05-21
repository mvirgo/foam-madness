//
//  LiveGamesModel.swift
//  foam-madness
//
//  Created by Michael Virgo on 5/20/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

class LiveGamesModel: ObservableObject {
    @Published var liveGames: [Event] = []
    @Published var loading = false
    private var lastRefreshTime: Date?

    init() {
        refreshData()
    }

    func refreshData() {
        let now = Date()
        if let lastRefreshTime = lastRefreshTime, now.timeIntervalSince(lastRefreshTime) < AppConstants.refreshDebounceSeconds {
            // Skip if within the debounce delay
            return
        }
        lastRefreshTime = now
        loadGames()
    }

    private func loadGames() {
        loading = true
        liveGames = []
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
