//
//  APIClient.swift
//  foam-madness
//
//  Created by Michael Virgo on 9/13/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import Foundation

class APIClient {
    // MARK: API Endpoints
    enum Endpoints {
        static let base = "https://site.api.espn.com/apis/site/v2/sports"
        static let nbaBase = "/basketball/nba"
        static let ncaaBase = "/basketball/mens-college-basketball"
        static let scoresBase = "/scoreboard"
        
        case getNBAScores
        case getNCAAScores
        
        var stringValue: String {
            switch self {
            case .getNBAScores: return Endpoints.base + Endpoints.nbaBase + Endpoints.scoresBase
            case .getNCAAScores: return Endpoints.base + Endpoints.ncaaBase + Endpoints.scoresBase
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    // MARK: General JSON response handling
    // Handle responses or errors for any request type
    class func handleResponseOrError<ResponseType: Decodable>(_ data: Data?, _ response: URLResponse?, _ error: Error?, _ completion: @escaping (ResponseType?, Error?) -> Void) {
        guard let data = data else {
            DispatchQueue.main.async {
                completion(nil, error)
            }
            return
        }
        
        let decoder = JSONDecoder()
        
        do {
            let responseObject = try decoder.decode(ResponseType.self, from: data)
            DispatchQueue.main.async {
                completion(responseObject, nil)
            }
        } catch {
            do {
                let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(nil, errorResponse)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    // MARK: General Request Types
    // Send GET Requests
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            handleResponseOrError(data, response, error, completion)
        }
        task.resume()
    }
    
    // MARK: Specific API requests
    class func getScores(url: URL, completion: @escaping (LiveGamesResponse?, Error?) -> Void) {
        taskForGETRequest(url: url, responseType: LiveGamesResponse.self) { response, error in
            if let response = response {
                completion(response.self, nil)
            } else {
                completion(nil, error)
            }
        }
    }
}
