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
    
    func clear(request: Request) throws -> ResponseRepresentable {
        let like = try request.like()
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
            clear: clear
        )
    }
    
}

extension Request {
    func like() throws -> Like {

        guard let userId = try self.user().id else {
            throw Abort.custom(status: .badRequest, message: "Something went wrong")
        }
        
        guard let shotId = self.data["shot-id"]?.int else {
            throw Abort.custom(status: .badRequest, message: "No shot-id was provided")
        }
        
        // Like already exists
        
        if let like = try Like.query().filter("shot_id", shotId).filter("user_id", userId).first(){
            return like
        }
        
        // Like doesn't exist
        return  Like(user: userId.makeNode(), shot: try shotId.makeNode())
        
    }
}
