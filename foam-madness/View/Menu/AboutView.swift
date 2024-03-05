//
//  AboutView.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct AboutView: View {
    @State private var aboutText: NSAttributedString?

    var body: some View {
        VStack {
            ScrollView {
                if let aboutText = aboutText {
                    Text(aboutText.string)
                        .font(.body)
                        .padding()
                } else {
                    Text("Loading...")
                        .font(.body)
                        .padding()
                }
            }
            .onAppear {
                if let url = Bundle.main.url(forResource: "ABOUT", withExtension: "rtf") {
                    do {
                        let data = try Data(contentsOf: url)
                        let attributedString = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                        self.aboutText = attributedString
                    } catch {
                        print("Error loading RTF file: \(error.localizedDescription)")
                        self.aboutText = nil
                    }
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                 ToolbarItem(placement: .principal) {
                    Text("About This App").font(.system(size: 24)).fontWeight(.bold)
                }
            }
        }
    }
}

#Preview {
    AboutView()
}
