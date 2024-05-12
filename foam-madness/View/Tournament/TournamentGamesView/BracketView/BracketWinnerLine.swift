//
//  BracketWinnerLine.swift
//  foam-madness
//
//  Created by Michael Virgo on 5/6/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct BracketWinnerLine: View {
    @Binding var winnerName: String
    @Binding var maxRoundForRegion: Int

    var body: some View {
        VStack {
            // Skip for First Four
            if maxRoundForRegion == 0 {
                EmptyView()
            } else {
                Text(winnerName == "" ? "Pending" : winnerName)
                    .frame(minWidth: 140, alignment: .leading)
                    .padding([.leading, .trailing])
                    .padding([.bottom], 5)
                    .border(width: 5, edges: [.bottom], color: commonBlue)
            }
        }
    }
}

struct BracketWinnerLine_Previews: PreviewProvider {
    static var previews: some View {
        return BracketWinnerLine(
            winnerName: .constant("KU"),
            maxRoundForRegion: .constant(1)
        )
    }
}
