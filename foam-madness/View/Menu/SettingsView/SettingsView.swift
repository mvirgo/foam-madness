//
//  SettingsView.swift
//  foam-madness
//
//  Created by Michael Virgo on 5/12/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            LazyVStack {
                    SettingBracketView()
            }
            .padding()
            .background(Color(UIColor.systemGroupedBackground))
            .cornerRadius(10)
            
            NavigationLink(destination: AboutView()) {
                Text("About This App")
                    .font(.headline)
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Spacer()
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
