//
//  BracketIcon.swift
//  foam-madness
//
//  Created by Michael Virgo on 3/27/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

let lineWidth: CGFloat = 10

private struct BracketShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let shift: CGFloat = 100
        let lineAdj = lineWidth / 2 // connect end of lines
        let topY = rect.minY - shift * 1.5
        let bottomY = rect.maxY - (shift / 2)
        let leftX = rect.minX - (shift * 1.25)
        let midX = leftX + shift
        let rightX = midX + shift
        let farRightX = rightX + shift
        
        // Define the points of the bracket shape
        // Left side
        path.move(to: CGPoint(x: leftX, y: topY))
        path.addLine(to: CGPoint(x: midX, y: topY))
        path.move(to: CGPoint(x: leftX, y: bottomY))
        path.addLine(to: CGPoint(x: midX, y: bottomY))
        path.move(to: CGPoint(x: midX, y: topY - lineAdj))
        path.addLine(to: CGPoint(x: midX, y: bottomY + lineAdj))
        
        path.move(to: CGPoint(x: leftX, y: topY + shift * 2))
        path.addLine(to: CGPoint(x: midX, y: topY + shift * 2))
        path.move(to: CGPoint(x: leftX, y: bottomY + shift * 2))
        path.addLine(to: CGPoint(x: midX, y: bottomY + shift * 2))
        path.move(to: CGPoint(x: midX, y: topY - lineAdj + shift * 2))
        path.addLine(to: CGPoint(x: midX, y: bottomY + lineAdj + shift * 2))
        
        // Middle bracket
        path.move(to: CGPoint(x: midX, y: rect.midY - shift))
        path.addLine(to: CGPoint(x: rightX, y: rect.midY - shift))
        
        path.move(to: CGPoint(x: midX, y: rect.midY + shift))
        path.addLine(to: CGPoint(x: rightX, y: rect.midY + shift))
        
        path.move(to: CGPoint(x: rightX, y: rect.midY - shift - lineAdj))
        path.addLine(to: CGPoint(x: rightX, y: rect.midY + shift + lineAdj))
        
        // Final line
        path.move(to: CGPoint(x: rightX, y: rect.midY))
        path.addLine(to: CGPoint(x: farRightX, y: rect.midY))

        return path
    }
}

struct BracketIcon: View {
    var body: some View {
        VStack {
            BracketShape()
                .stroke(commonBlue, lineWidth: lineWidth)
                .frame(width: 50, height: 50)
        }
    }
}

#Preview {
    BracketIcon()
}
