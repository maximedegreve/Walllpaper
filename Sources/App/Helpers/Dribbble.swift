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
    
    public let string: Token
    
    public init(string: Token) {
        self.string = string
    }
    
}

final class Dribbble {
    
    static let client_id = drop.config["dribbble", "client_id"]?.string ?? ""
    static let client_secret = drop.config["dribbble", "client_secret"]?.string ?? ""
    static let access_token = drop.config["dribbble", "access_token"]?.string ?? ""
    static let tokenURL = "https://dribbble.com/oauth/token"
    static let apiURL = "https://api.dribbble.com/v1/"
    
    static func getToken(code: String) throws -> String?{
        
        let result = try drop.client.post(self.tokenURL, query: ["client_id": self.client_id, "client_secret": self.client_secret, "code": code])
        
        guard let token = result.data["access_token"]?.string else {
            return nil
        }
        
        return token
        
    }
    
    static func loginLink() -> String{
        let redirect_url = drop.config["dribbble", "redirect_link"]?.string ?? ""
        return "https://dribbble.com/oauth/authorize?redirect_uri=\(redirect_url)&client_id=\(self.client_id)&scope=write public"
    }
    
    static func user(token: String, id: Int) throws -> Response{
        
        return try drop.client.get("\(self.apiURL)users/\(id)?access_token=\(token)");
        
    }
    
    static func myUser(token: String) throws -> Response{
        
        return try drop.client.get("\(self.apiURL)user?access_token=\(token)");
        
    }
    
    static func followUser(token: String, id: Int) throws -> Response{
        
        return try drop.client.put("\(self.apiURL)users/\(id)/follow?access_token=\(token)")
        
    }
    
    static func isFollowingUser(token: String, id: Int) throws -> Bool{
        
        let statusCode =  try drop.client.get("\(self.apiURL)user/following/\(id)?access_token=\(token)").status.statusCode
        
        if statusCode == 204{
            return true
        } else {
            return false
        }
        
    }
    
    static func likeShot(token: String, id: Int) throws -> Response{
        
        return try drop.client.post("\(self.apiURL)shots/\(id)/like?access_token=\(token)")
        
    }
    
    static func unlikeShot(token: String, id: Int) throws -> Response{
        
        return try drop.client.delete("\(self.apiURL)shots/\(id)/like?access_token=\(token)")
        
    }
    
    static func shot(token: String, id: Int) throws -> Response{
        
        return try drop.client.get("\(self.apiURL)shots/\(id)?access_token=\(token)")
        
    }
    
}
