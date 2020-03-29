//
//  GameHelper.swift
//  foam-madness
//
//  Created by Michael Virgo on 3/29/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import Foundation

class GameHelper {
    static func getHandSideString(_ hand: Bool) -> String {
        let out: String
        if hand {
            out = "Right"
        } else {
            out = "Left"
        }
        return out
    }
    
    static func getRoundString(_ round: Int16) -> String {
        let out: String
        switch round {
        case 0:
            out = "First Four"
        case 1:
            out = "First Round"
        case 2:
            out = "Second Round"
        case 3:
            out = "Sweet Sixteen"
        case 4:
            out = "Elite Eight"
        default:
            out = ""
        }
        return out
    }
}
