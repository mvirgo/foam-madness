//
//  BracketHelper.swift
//  foam-madness
//
//  Created by Michael Virgo on 2/9/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import Foundation

class BracketHelper {
    static func loadBrackets() -> [Dictionary<String, String>] {
        let path = Bundle.main.path(forResource: "bracketIndex", ofType: "plist")!
        return NSArray(contentsOfFile: path) as! [Dictionary<String, String>]
    }
}
