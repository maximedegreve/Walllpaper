//
//  Dribbble.swift
//  Walllpaper
//
//  Created by Maxime De Greve on 19/02/2017.
//
//

import Vapor
import HTTP
import Turnstile

public class DribbbleAccessToken: Credentials {
    /// The token as a String
    public let string: Token
    
    /// Initializer for TokenCredentials
    public init(string: Token) {
        /// User-presentable error message
        self.string = string
    }
}

final class Dribbble {
    
    static let client_id = drop.config["dribbble", "client_id"]?.string ?? ""
    static let client_secret = drop.config["dribbble", "client_secret"]?.string ?? ""
    static let tokenURL = "https://dribbble.com/oauth/token"
    static let apiURL = "https://api.dribbble.com/v1/"
    
    static func getToken(code: String) throws -> String?{
        
        let result = try drop.client.post(self.tokenURL, query: ["client_id": self.client_id, "client_secret": self.client_secret, "code": code])
        
        guard let token = result.data["access_token"]?.string else {
            return nil
        }
        
        return token
        
    }
    
    static func getUserData(token: String) throws -> Response{
        
        return try drop.client.get("\(self.apiURL)user?access_token=\(token)");
        
    }
    
}
