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
        guard let json = json else { throw Abort.badRequest }
        return try Like(node: json)
    }
}
