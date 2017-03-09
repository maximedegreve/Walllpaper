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
    
    static func bulkUsersUpdate(users: [User]) throws -> Response{
        
        var items = [JSON]()
        
        for user in users{
            
            if let userId = user.id?.string{
                
                let userJSON = try generateUserJSON(userId: userId, name: user.name, avatarUrl: user.dribbbleAvatarUrl)
                let dataJSON = try JSON(node: [
                    "method": "post",
                    "data_type": "user",
                    "data": userJSON
                    ])
                items.append(dataJSON)
            }
            
        }
        
        let dataJSON = try JSON(node: [
            "items": items.makeNode(),
            ])
        
        let jsonBytes = try dataJSON.makeBytes()
        return try drop.client.post("\(self.apiURL)bulk/users/", headers: ["Accept" : "application/json", "Content-Type": "application/json", "Authorization": "Bearer \(access_token)"], query: [:], body: Body.data(jsonBytes))
        
        
    }

    static func saveUser(userId: String, name: String, avatarUrl: String?) throws -> Response{
        
        let userJSON = try generateUserJSON(userId: userId, name: name, avatarUrl: avatarUrl)
        let jsonBytes = try userJSON.makeBytes()
        return try drop.client.post("\(self.apiURL)users/", headers: ["Accept" : "application/json", "Content-Type": "application/json", "Authorization": "Bearer \(access_token)"], query: [:], body: Body.data(jsonBytes))
        
    }
    
    
    private static func generateUserJSON(userId: String, name: String, avatarUrl: String?) throws -> JSON{
        
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
        
        return dataJSON
        
    }
    
    
}
