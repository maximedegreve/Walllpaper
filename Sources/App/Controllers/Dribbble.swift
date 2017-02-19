//
//  Dribbble.swift
//  Walllpaper
//
//  Created by Maxime De Greve on 19/02/2017.
//
//

import Vapor
import HTTP

final class Dribbble {
    
    let client_id = drop.config["dribbble", "client_id"]?.string ?? ""
    let client_secret = drop.config["dribbble", "client_secret"]?.string ?? ""
    let tokenURL = "https://dribbble.com/oauth/token"
    let apiURL = "https://api.dribbble.com/v1/"
    
    func getToken(code: String) throws -> String?{
        
        let result = try drop.client.post(tokenURL, query: ["client_id": client_id, "client_secret": client_secret, "code": code])
        
        guard let token = result.data["access_token"]?.string else {
            return nil
        }
        
        return token
        
    }
    
    func getUserData(token: String) throws -> Response{
        
        return try drop.client.get("\(apiURL)user?access_token=\(token)");
        
    }
    
}
