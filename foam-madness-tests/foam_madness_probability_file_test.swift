//
//  foam_madness_probability_file_test.swift
//  foam-madness-tests
//
//  Created by Michael Virgo on 3/11/23.
//  Copyright © 2023 mvirgo. All rights reserved.
//

import XCTest

final class foam_madness_probability_file_test: XCTestCase {
    let mensProbabilitiesFile = "historicalProbabilities"
    let womensProbabilitiesFile = "historicalProbabilitiesWomen"
    
    var mensProbabilitiesDict = NSDictionary()
    var womensProbabilitiesDict = NSDictionary()

    override func setUpWithError() throws {
        loadProbabilities()
    }

    override func tearDownWithError() throws {}
    
    func loadProbabilities() {
        let mensPath = Bundle.main.path(forResource: mensProbabilitiesFile, ofType: "plist")!
        let womensPath = Bundle.main.path(forResource: womensProbabilitiesFile, ofType: "plist")!
        mensProbabilitiesDict = NSDictionary(contentsOfFile: mensPath)!
        womensProbabilitiesDict = NSDictionary(contentsOfFile: womensPath)!
    }
    
    func logFailureMessage(gender: String, message: String) {
        XCTFail(gender + message)
    }
    
    func haveProbabilitiesForEachMatchup(dict: NSDictionary) -> Bool {
        for i in 1...16 {
            let seedProbabilities = dict.object(forKey: "\(i)") as! Dictionary<String, NSNumber>
            // Set up is such that #1 seed has all 16 probabilties, #2 has all but against #1, etc (since duplicative)
            if (seedProbabilities.count != 16 - i + 1) {
                return false
            }
        }
        return true
    }
    
    func allProbabilitiesValid(dict: NSDictionary) -> Bool {
        for i in 1...16 {
            let seedProbabilities = dict.object(forKey: "\(i)") as! Dictionary<String, NSNumber>
            for prob in seedProbabilities {
                if prob.value.floatValue < 0.0 || prob.value.floatValue > 1.0 {
                    return false
                }
            }
        }
        return true
    }

    func testHaveProbabilitiesForEachMatchup() throws {
        let failMessage = " file had missing probabilities"
        if (!haveProbabilitiesForEachMatchup(dict: mensProbabilitiesDict)) {
            logFailureMessage(gender: "Men's", message: failMessage)
        }
        if (!haveProbabilitiesForEachMatchup(dict: womensProbabilitiesDict)) {
            logFailureMessage(gender: "Women's", message: failMessage)
        }
    }
    
    func testAllProbabilitiesValid() throws {
        let failMessage = " file had invalid probabilities"
        if (!allProbabilitiesValid(dict: mensProbabilitiesDict)) {
            logFailureMessage(gender: "Men's", message: failMessage)
        }
        if (!allProbabilitiesValid(dict: womensProbabilitiesDict)) {
            logFailureMessage(gender: "Women's", message: failMessage)
        }
    }
}
