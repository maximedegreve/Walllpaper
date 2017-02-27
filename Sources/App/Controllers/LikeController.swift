//
//  LikeController.swift
//  Walllpaper
//
//  Created by Maxime De Greve on 26/02/2017.
//
//

import Vapor
import HTTP

final class LikeController: ResourceRepresentable {
    
    func delete(request: Request, like: Like) throws -> ResponseRepresentable {
        try like.delete()
        return JSON([:])
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        var like = try request.like()
        try like.save()
        return like
    }
    
    func makeResource() -> Resource<Like> {
        return Resource(
            store: create,
            destroy: delete
        )
    }
    
}

extension Request {
    func like() throws -> Like {
        
        guard let userId = try self.auth.user().id?.int else{
            throw Abort.badRequest
        }
        guard let shotId = self.data["shot-id"]?.int else {
            throw Abort.badRequest
        }
        
        let like = Like(user: try userId.makeNode(), shot: try shotId.makeNode())
        
        return like
    }
}
