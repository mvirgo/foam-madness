//
//  SelectInitialBracketView.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct SelectInitialBracketView: View {
    @State var isSimulated: Bool
    @State private var chosenBracketFile: String?
    @State private var chosenBracketName: String?
    @State private var chosenYear: String?
    @State private var isWomens = false
    @State private var yearsArray: [String] = []
    @State private var brackets: [BracketItem] = []
    let gridPadding = 10.0

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.height * 0.03) {
                Spacer()
                
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
                
                VStack {
                    Text("Men's or Women's?").font(.title2)
                    Picker("", selection: $isWomens) {
                        Text("Men's").tag(false)
                        Text("Women's").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .padding([.leading, .trailing], 30)
                }
                
                VStack(spacing: 10) {
                    Text("Current Bracket Chosen")
                        .font(.title2)
                    Text(chosenBracketName ?? "")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                NavigationLink(
                    "Continue",
                    destination:
                        BracketCreationView(
                            isSimulated: isSimulated,
                            chosenBracketFile: chosenBracketFile ?? ""
                        )
                )
                .buttonStyle(PrimaryButtonFullWidthStyle())
                .padding([.leading, .trailing, .bottom])
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Choose a Starting Bracket")
                        .fontWeight(.bold)
                }
            }
            .onAppear() {
                brackets = BracketHelper.loadBrackets()
                getYears()
            }
            .onChange(of: chosenYear) { _ in
                getChosenBracket()
            }
            .onChange(of: isWomens) { _ in
                getChosenBracket()
            }
        }
    }
    
    private func getYears() {
        let initialYearsArray = brackets.map { $0.year }
        let uniqueYears = Set(initialYearsArray)
        // sort descending
        let sortedYears = uniqueYears.sorted(by: >)
        yearsArray = sortedYears.map { String($0) }
        chosenYear = yearsArray[0]
    }
    
    private func getBracketName() -> String {
        if brackets.count > 0 {
            return brackets.filter({ $0.year == Int(chosenYear ?? "") && $0.isWomens == isWomens})[0].name
        }
        return ""
    }
    
    private func getChosenBracket() {
        if (chosenYear != nil && brackets.count > 0) {
            let chosenBracket = brackets.filter({ $0.year == Int(chosenYear ?? "") && $0.isWomens == isWomens})[0]
            chosenBracketFile = chosenBracket.file
            chosenBracketName = chosenBracket.name
        }
    }
}

struct SelectInitialBracketView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SelectInitialBracketView(isSimulated: false).environment(\.managedObjectContext, PreviewDataController.shared.container.viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
