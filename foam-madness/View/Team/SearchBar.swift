//
//  SearchBar.swift
//  foam-madness
//
//  Created by Michael Virgo on 3/12/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

// Based on https://stackoverflow.com/a/57738103, since still on iOS 14
struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    var filteredData: [String]

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }
    
    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.autocapitalizationType = .none
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}
