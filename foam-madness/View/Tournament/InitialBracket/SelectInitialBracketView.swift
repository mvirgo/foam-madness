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
    // Hide existing/custom when coming from later custom view
    @State var showCustomSelector = true
    @Binding var chosenBracketFile: String?
    @State private var chosenBracketName: String?
    @State private var chosenYear: String?
    @State private var isCustom = false
    @State private var isWomens = false
    @State private var numTeams = 64
    @State private var brackets: [BracketItem] = []
    let gridPadding = 10.0

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.height * 0.03) {
                if showCustomSelector {
                    Spacer()
                    
                    HStack {
                        Text("Existing/Custom")
                            .font(.title2)
                            .lineLimit(1)
                        Picker("", selection: $isCustom) {
                            Text("Existing").tag(false)
                            Text("Custom").tag(true)
                        }
                        .pickerStyle(.segmented)
                    }.padding([.leading, .trailing], 10)
                }
                
                HStack(spacing: 10) {
                    Text("Men's/Women's")
                        .font(.title2)
                        .lineLimit(1)
                    Picker("", selection: $isWomens) {
                        Text("Men").tag(false)
                        Text("Women").tag(true)
                    }
                    .pickerStyle(.segmented)
                }.padding([.leading, .trailing], 10)
                
                if isCustom {
                    SelectNumTeamsView(numTeams: $numTeams)
                } else {
                    SelectYearView(chosenYear: $chosenYear, brackets: $brackets)
                }
                
                VStack(spacing: 10) {
                    Text("Current Bracket Chosen")
                        .font(.title2)
                    Text(chosenBracketName ?? "")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                if showCustomSelector {
                    Spacer()
                    
                    NavigationLink(
                        "Continue",
                        destination:
                            BracketCreationView(
                                isCustom: isCustom,
                                isSimulated: isSimulated,
                                isWomens: isWomens,
                                numTeams: numTeams, // unused if not custom
                                chosenBracketFile: chosenBracketFile ?? ""
                            )
                    )
                    .buttonStyle(PrimaryButtonFullWidthStyle())
                    .padding([.leading, .trailing, .bottom])
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if showCustomSelector {
                        Text("Choose a Starting Bracket")
                            .fontWeight(.bold)
                    }
                }
            }
            .onAppear() {
                brackets = BracketHelper.loadBrackets()
            }
            .onChange(of: chosenYear) { _ in
                getChosenBracket()
            }
            .onChange(of: isCustom) { _ in
                getChosenBracket()
            }
            .onChange(of: isWomens) { _ in
                getChosenBracket()
            }
            .onChange(of: numTeams) { _ in
                getChosenBracket()
            }
        }
    }
    
    private func getBracketName() -> String {
        if brackets.count > 0 {
            return brackets.filter({ $0.year == Int(chosenYear ?? "") && $0.isWomens == isWomens})[0].name
        }
        return ""
    }
    
    private func getChosenBracket() {
        if (chosenYear != nil && brackets.count > 0 && !isCustom) {
            let chosenBracket = brackets.filter({ $0.year == Int(chosenYear ?? "") && $0.isWomens == isWomens})[0]
            chosenBracketFile = chosenBracket.file
            chosenBracketName = chosenBracket.name
        } else if (isCustom) {
            chosenBracketFile = "custom"
            chosenBracketName = "Custom Bracket - \(numTeams) teams \n(\(isWomens ? "Women's" : "Men's") probabilities)"
        }
    }
}

struct SelectInitialBracketView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SelectInitialBracketView(
                isSimulated: false,
                chosenBracketFile: .constant("")
            ).environment(\.managedObjectContext, PreviewDataController.shared.container.viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
