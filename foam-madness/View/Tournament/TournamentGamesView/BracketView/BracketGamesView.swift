//
//  BracketGamesView.swift
//  foam-madness
//
//  Created by Michael Virgo on 3/28/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct BracketGamesView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var tournament: Tournament
    @State private var chosenRegion = ""
    @State private var regionWinnerName = ""
    @State private var games: [Game] = []
    @State private var maxRoundForRegion: Int = 0
    @State private var minRoundForRegion: Int = 0
    @State private var regions: [String] = []
    @Binding var hideListView: Bool
    
    let gridPadding = 10.0
    let baseBracketSpacing: CGFloat = 20.0
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                Spacer()
                // Bracket itself
                ScrollView([.horizontal, .vertical]) {
                    LazyHStack(spacing: 0) {
                        ForEach(minRoundForRegion..<maxRoundForRegion + 1, id: \.self) { i in
                            // Size/position accordingly
                            LazyVStack(alignment: .leading) {
                                ForEach(games.filter({
                                    $0.round == Int16(i)
                                }), id: \.id) { game in
                                    BracketGameCell(
                                        game: game,
                                        spacing: getInnerSpacing(index: i)
                                    )
                                    .padding([.bottom], getOuterSpacing(index: i))
                                    .padding([.top], i == minRoundForRegion ? 0 : getOuterSpacing(index: i))
                                }
                            }
                        }
                        BracketWinnerLine(winnerName: $regionWinnerName, maxRoundForRegion: $maxRoundForRegion)
                    }.padding()
                }
                
                // Region chooser
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: gridPadding) {
                    ForEach(regions, id: \.self) { region in
                        Button(action: {
                            getSortedGames(region: region)
                        })
                        {
                            Text(region)
                                .lineLimit(1)
                                .font(.callout)
                                .foregroundColor(chosenRegion == region ? Color.white : Color.primary)
                                .padding([.top, .bottom])
                        }
                        .frame(maxWidth: .infinity)
                        .background(chosenRegion == region ? commonBlue : Color.secondary)
                        .cornerRadius(5)
                    }
                }
                .padding(gridPadding)
                .border(width: 2.0, edges: [.top], color: commonBlue)
            }

            // List View button, with spacing
            VStack(spacing: 0) {
                Text("")
                
                HStack(spacing: 10) {
                    Button("List", action: {
                        hideListView = false
                    })
                    .padding(gridPadding)
                    .foregroundColor(Color.white)
                    .background(commonBlue)
                    .cornerRadius(5)
                    
                    Text("")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationTitle(tournament.name ?? "Tournament Games")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Main Menu", action: {
                    NavigationUtil.popToRootView()
                })
            }
            ToolbarItem(placement: .topBarTrailing) {
                if !tournament.isSimulated {
                    NavigationLink("Stats", destination: TournamentStatsView(tournament: tournament))
                }
            }
        }
        .onAppear {
            setupView()
        }
        .onDisappear {
            tournament.lastRegionViewed = chosenRegion
        }
    }
    
    private func setupView() {
        getRegions()
        let lastRegionViewed = tournament.lastRegionViewed
        if lastRegionViewed == "" {
            chosenRegion = regions[0]
            tournament.lastRegionViewed = regions[0]
        } else {
            chosenRegion = lastRegionViewed ?? regions[0]
        }
        getSortedGames(region: chosenRegion)
    }
    
    private func getRegions() {
        let gamesArray = Array(tournament.games!) as! [Game]
        
        let tournamentRegions = gamesArray.compactMap { $0.region }
        let uniqueTournamentRegions = Array(Set(tournamentRegions))
        let filteredRegions = uniqueTournamentRegions.filter({
            $0 != "Final Four" && $0 != "Championship"
        }).sorted() { $0 < $1 }
        
        let minRound = gamesArray.min(by: { $0.round < $1.round })?.round ?? 0
        var tempRegions: [String] = filteredRegions + ["Final Four"]
        if minRound == 0 {
            tempRegions = ["First Four"] + tempRegions
        }
        
        regions = tempRegions
    }
    
    private func getSortedGames(region: String) {
        chosenRegion = region // Update selected box
        let gamesArray = Array(tournament.games!) as! [Game]
        let maxRound = gamesArray.max(by: { $0.round < $1.round })?.round ?? 6
        
        let filteredGames: [Game]
        if (region == "") {
            // Shouldn't happen, but just in case
            filteredGames = gamesArray
        } else if (region == "First Four") {
            filteredGames = gamesArray.filter({ $0.round == 0 })
        } else if (region == "Final Four") {
            filteredGames = gamesArray.filter({ $0.round == maxRound || $0.round == maxRound - 1 })
        } else {
            filteredGames = gamesArray.filter({ $0.region == region && !($0.round == maxRound || $0.round == maxRound - 1 || $0.round == 0) })
        }
        maxRoundForRegion = Int(filteredGames.max(by: { $0.round < $1.round })?.round ?? 6)
        minRoundForRegion = Int(filteredGames.min(by: { $0.round < $1.round })?.round ?? 0)
        games = filteredGames.sorted() { $0.tourneyGameId < $1.tourneyGameId }
        getWinnerName()
    }
    
    private func getWinnerName() {
        let finalGameForRegion = games.filter({ $0.round == Int16(maxRoundForRegion) }).first
        if (!(finalGameForRegion?.completion ?? false)) {
            regionWinnerName = ""
            return
        }
        
        regionWinnerName = GameHelper.getGameWinnerAbbreviation(finalGameForRegion!)
    }
    
    private func getInnerSpacing(index: Int) -> CGFloat {
        let multiplier = index == minRoundForRegion ? 1.0 : pow(CGFloat(index - minRoundForRegion), 1.33) * 3.5
        return baseBracketSpacing * multiplier
    }
    
    private func getOuterSpacing(index: Int) -> CGFloat {
        let multiplier = index == minRoundForRegion ? 1.0 : pow(CGFloat(index - minRoundForRegion), 1.1) * 1.6
        return baseBracketSpacing * multiplier
    }
}

struct BracketGamesView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PreviewDataController.shared.container.viewContext
        let tournaments = TourneyHelper.fetchDataFromContext(viewContext, nil, "Tournament", []) as! [Tournament]
        return NavigationView {
            BracketGamesView(tournament: tournaments[0], hideListView: .constant(true)).environment(\.managedObjectContext, viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
