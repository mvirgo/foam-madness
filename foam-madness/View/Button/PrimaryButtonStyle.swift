//
//  PrimaryButtonStyle.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

let cornerRadius = CGFloat(5)
let fontSize = CGFloat(30)
let colorDivisor = CGFloat(255)
let red = CGFloat(23 / colorDivisor)
let green = CGFloat(64 / colorDivisor)
let blue = CGFloat(139 / colorDivisor)

let commonBlue = Color(red: red, green: green, blue: blue)

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(commonBlue)
            .foregroundColor(.white)
            .cornerRadius(cornerRadius)
            .font(.system(size: fontSize))
    }
}

struct PrimaryButtonFullWidthStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(commonBlue)
            .foregroundColor(.white)
            .cornerRadius(cornerRadius)
            .font(.system(size: fontSize))
    }
}
