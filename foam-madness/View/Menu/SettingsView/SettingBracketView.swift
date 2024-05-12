//
//  SettingBracketView.swift
//  foam-madness
//
//  Created by Michael Virgo on 5/12/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct SettingBracketView: View {
    @AppStorage("useBracketView") var useBracketView = AppConstants.defaultUseBracketView
    @State private var showHelper = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Tournament View Default")
                Button(action: onClickHelper) {
                    Image(systemName: "info.circle")
                        .foregroundColor(commonBlue)
                }
                Spacer()
                Button(action: onClickStyle) {
                    Text(useBracketView ? "Bracket" : "List")
                        .foregroundColor(.secondary)
                }.buttonStyle(.plain)
            }.padding(showHelper ? [.bottom] : [])
            if showHelper {
                Text("The default style when viewing a tournament. List style shows a list by round, while Bracket style shows brackets by region. This sets it when creating a new tournament, but existing tournaments will keep their existing style (which can be changed in the tournament itself).").font(.footnote)
            }
        }.padding([.leading, .trailing])
    }
    
    private func onClickHelper() {
        showHelper = !showHelper
    }
    
    private func onClickStyle() {
        useBracketView = !useBracketView
    }
}

#Preview {
    SettingBracketView()
}
