//
//  SelectYearView.swift
//  foam-madness
//
//  Created by Michael Virgo on 5/17/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct SelectYearView: View {
    @Binding var chosenYear: String?
    @Binding var brackets: [BracketItem]
    @State private var yearsArray: [String] = []
    let gridPadding = 10.0
    
    var body: some View {
        VStack {
            Text("Choose a Year").font(.title2)
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: gridPadding) {
                ForEach(yearsArray, id: \.self) { year in
                    Button(action: {
                        chosenYear = year
                    }) {
                        Text(year)
                            .lineLimit(1)
                            .font(.headline)
                            .foregroundColor(chosenYear == year ? Color.white : Color.primary)
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .background(chosenYear == year ? commonBlue : Color.secondary)
                    .cornerRadius(5.0)
                }
            }.padding(gridPadding)
        }
        .onAppear {
            getYears()
        }
        .onChange(of: brackets.count) { _ in
            getYears()
        }
    }
    
    private func getYears() {
        let initialYearsArray = brackets.map { $0.year }
        let uniqueYears = Set(initialYearsArray)
        // sort descending
        let sortedYears = uniqueYears.sorted(by: >)
        yearsArray = sortedYears.map { String($0) }
        if !yearsArray.isEmpty {
            chosenYear = yearsArray[0]
        }
    }
}

struct SelectYearView_Previews: PreviewProvider {
    static var previews: some View {
        let brackets = BracketHelper.loadBrackets()
        
        NavigationView {
            SelectYearView(
                chosenYear: .constant(String(brackets[0].year)),
                brackets: .constant(brackets)
            ).environment(\.managedObjectContext, PreviewDataController.shared.container.viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
