//
//  AdminControllerCreators.swift
//  Walllpaper
//
//  Created by Maxime De Greve on 25/02/2017.
//
//

import Vapor
import HTTP

final class AdminCreatorsController {

    func addRoutes(to drop: Droplet) {
        
        drop.group(AdminProtectMiddleware()) { secure in
            secure.get("admin","creators", handler: creators)
        }
        
    }
    
    func creators(_ request: Request) throws -> ResponseRepresentable {
        
        let users = try User.withShots().sorted(by: { (user, otherUser) -> Bool in
            return user.followersCount > otherUser.followersCount
        }) .makeNode()
        
        return try drop.view.make("admin-creator", [
            "users": users,
            ])
        
    }
    
}
