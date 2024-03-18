//
//  BracketHelper.swift
//  foam-madness
//
//  Created by Michael Virgo on 2/9/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import Foundation

struct BracketItem {
    let file: String
    let name: String
    let isWomens: Bool
    let year: Int

    init?(dictionary: [String: Any]) {
        guard let file = dictionary["File"] as? String,
              let name = dictionary["Name"] as? String,
              let isWomens = dictionary["IsWomens"] as? Bool,
              let year = dictionary["Year"] as? Int else {
            return nil
        }
        self.file = file
        self.name = name
        self.isWomens = isWomens
        self.year = year
    }
}

class BracketHelper {
    static func loadBrackets() -> [BracketItem] {
        let path = Bundle.main.path(forResource: "bracketIndex", ofType: "plist")!
        let bracketArray = NSArray(contentsOfFile: path) as! [[String: Any]]
        
        var bracketItems = [BracketItem]()
        for dict in bracketArray {
            if let bracketItem = BracketItem(dictionary: dict) {
                bracketItems.append(bracketItem)
            }
        }
        
        return bracketItems
    }
}
