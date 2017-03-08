//
//  Intercom.swift
//  Walllpaper
//
//  Created by Maxime De Greve on 07/03/2017.
//
//

import Vapor
import HTTP
import Turnstile

final class Intercom {
    
    static let apiURL = "https://api.intercom.io/"
    static let access_token = drop.config["intercom", "access_token"]?.string ?? ""
    
    static func saveUser(userId: String, name: String, avatarUrl: String?) throws -> Response{
        
        var avatar: JSON?
        
        if let avatarUrlF = avatarUrl {
            avatar = try JSON(node: [
                "type": "avatar",
                "image_url": avatarUrlF
                ])
        }
        
        let dataJSON = try JSON(node: [
            "user_id": userId,
            "name": name,
            "avatar": avatar
            ])
        
        let jsonBytes = try dataJSON.makeBytes()
        return try drop.client.post("\(self.apiURL)users/", headers: ["Accept" : "application/json", "Content-Type": "application/json", "Authorization": "Bearer \(access_token)"], query: [:], body: Body.data(jsonBytes))
        
    }
    
}
