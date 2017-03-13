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
            secure.post("admin","contacted", handler: contactedPost)
            secure.delete("admin","contacted", handler: contactedDelete)
            secure.post("admin","status", handler: statusPost)
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
    
    func contactedPost(_ request: Request) throws -> ResponseRepresentable {
        
        guard let userID = request.data["id"]?.int else {
            throw Abort.badRequest
        }
        
        var user = try User.find(userID)
        user?.contacted = true
        try user?.save()

        return Response(status: .created, body: "Set to contacted...")
    }
    
    func contactedDelete(_ request: Request) throws -> ResponseRepresentable {
        
        guard let userID = request.data["id"]?.int else {
            throw Abort.badRequest
        }
        
        var user = try User.find(userID)
        user?.contacted = false
        try user?.save()
        
        return Response(status: .created, body: "Set to not contacted...")
    }
    
    func statusPost(_ request: Request) throws -> ResponseRepresentable {
        
        guard let userID = request.data["user_id"]?.int else {
            throw Abort.badRequest
        }
        
        guard let status = request.data["status"]?.int else {
            throw Abort.badRequest
        }
        
        var user = try User.find(userID)
        user?.consented = status
        try user?.save()
        
        return Response(status: .created, body: "Status set...")
    }
    
}
