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
}
