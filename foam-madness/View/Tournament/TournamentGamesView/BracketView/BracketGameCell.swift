//
//  BracketGameCell.swift
//  foam-madness
//
//  Created by Michael Virgo on 5/3/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct BracketGameCell: View {
    @StateObject var game: Game
    @State var spacing: CGFloat
    @State private var team1Text: String = ""
    @State private var team2Text: String = ""

    var body: some View {
        Group {
            if game.teams?.count == 2 {
                if game.completion == false {
                    NavigationLink {
                        PlayGameView(game: game)
                    } label: {
                        getLinkLabel
                    }
                    .buttonStyle(.plain)
                } else {
                    NavigationLink {
                        GameScoreView(game: game)
                    } label: {
                        getLinkLabel
                    }
                    .buttonStyle(.plain)
                }
            } else {
                getLinkLabel
            }
        }
        .onAppear {
            let teamsText = TourneyHelper.getBracketGameText(game: game)
            team1Text = teamsText[0]
            team2Text = teamsText[1]
        }
    }
    
    var getLinkLabel: some View {
        return ZStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 1) {
                Text(team1Text)
                    .frame(minWidth: 140, alignment: .leading)
                    .padding([.leading, .trailing])
                Text(team2Text)
                    .frame(minWidth: 140, alignment: .leading)
                    .padding([.top], spacing)
                    .padding([.leading, .trailing])
                    .padding([.bottom], 5)
                    .border(width: 5, edges: [.top, .bottom, .trailing], color: commonBlue)
            }
            .contentShape(Rectangle()) // allow click on open space in bracket
            
            // List the region if First Four
            if (game.round == 0) {
                Text(game.region ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// 3-sided edge code below from: https://stackoverflow.com/a/58632759
extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}

struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        edges.map { edge -> Path in
            switch edge {
            case .top: return Path(.init(x: rect.minX, y: rect.minY, width: rect.width, height: width))
            case .bottom: return Path(.init(x: rect.minX, y: rect.maxY - width, width: rect.width, height: width))
            case .leading: return Path(.init(x: rect.minX, y: rect.minY, width: width, height: rect.height))
            case .trailing: return Path(.init(x: rect.maxX - width, y: rect.minY, width: width, height: rect.height))
            }
        }.reduce(into: Path()) { $0.addPath($1) }
    }
}

struct BracketGameCell_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PreviewDataController.shared.container.viewContext
        let predicate = NSPredicate(format: "completion == YES")
        let games = TourneyHelper.fetchDataFromContext(viewContext, predicate, "Game", []) as! [Game]
        return NavigationView {
            BracketGameCell(game: games[0], spacing: 15.0).environment(\.managedObjectContext, PreviewDataController.shared.container.viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
