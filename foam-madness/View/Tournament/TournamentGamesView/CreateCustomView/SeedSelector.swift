//
//  SeedSelector.swift
//  foam-madness
//
//  Created by Michael Virgo on 5/18/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct SeedSelector: View {
    @State var teamNum: Int
    @Binding var selectedSeed: Int16
    
    var body: some View {
        HStack {
            Text("Team \(teamNum) Seed: \(selectedSeed)")
                .fontWeight(.bold)
            Spacer()
            Stepper("", value: $selectedSeed, in: 1...16)
                .labelsHidden()
        }.padding([.leading, .trailing])
    }
}

#Preview {
    SeedSelector(teamNum: 1, selectedSeed: .constant(1))
}
