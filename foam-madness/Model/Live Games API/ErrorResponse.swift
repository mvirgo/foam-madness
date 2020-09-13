//
//  ErrorResponse.swift
//  foam-madness
//
//  Created by Michael Virgo on 9/13/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import Foundation

struct ErrorResponse: Codable {
    let code: Int
}

extension ErrorResponse: LocalizedError {
    var errorDescription: String? {
        return "Error: " + String(code)
    }
}
