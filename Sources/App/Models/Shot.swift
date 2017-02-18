//
//  Shot.swift
//  Walllpaper
//
//  Created by Maxime De Greve on 18/02/2017.
//
//

import Vapor
import HTTP
import Fluent
import FluentMySQL

final class Shot: Model {
    
    var id: Node?
    var user: Node
    var dribbbleId: Int
    var title: String
    var description: String
    var imageRetina: String
    var image: String
    var imageOverriden: Bool = false
    var viewsCount: Int
    var likesCount: Int
    var createdAt: String
    
    init(user: Node, dribbbleId: Int, title: String, description: String, imageRetina: String, image: String, imageOverriden: Bool, viewsCount: Int, likesCount: Int) {
        self.user = user
        self.dribbbleId = dribbbleId
        self.title = title
        self.description = description
        self.imageRetina = imageRetina
        self.image = image
        self.imageOverriden = imageOverriden
        self.viewsCount = viewsCount
        self.likesCount = likesCount
        self.createdAt = Date().mysql
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        user = try node.extract("user")
        dribbbleId = try node.extract("dribbble_id")
        title = try node.extract("title")
        description = try node.extract("description")
        imageRetina = try node.extract("image_retina")
        image = try node.extract("image")
        imageOverriden = try node.extract("image_overriden")
        viewsCount = try node.extract("views_count")
        likesCount = try node.extract("liks_count")
        createdAt = try node.extract("created_at")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "user": user,
            "dribbble_id": dribbbleId,
            "title": title,
            "description": description,
            "image_retina": imageRetina,
            "image": image,
            "image_overriden": imageOverriden,
            "views_count": viewsCount,
            "likes_count": likesCount,
            "created_at": createdAt
            ])
    }
    
    func makeJSON(request: Request) throws -> JSON {
        
        var portString = ""
        if let port = request.uri.port {
            portString = ":" + String(port)
        }
        
        let imageURL = "https://\(request.uri.host)\(portString)/\(image)"
        let imageURLRetina = "https://\(request.uri.host)\(portString)/\(imageRetina)"
        
        return try JSON(node: [
            "image": imageURL,
            "image_retina": imageURLRetina,
            "title": title,
            ])
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete("shots")
    }
    
    public static func prepare(_ database: Database) throws {
        
        try database.create("shots") { shot in
            shot.id()
            shot.parent(User.self, optional: false, unique: false)
            shot.int("dribbble_id", optional: false, unique: true, default: 0)
            shot.string("title", length: 250, optional: false, unique: false)
            shot.string("description", length: 250, optional: false, unique: false)
            shot.string("image_retina", length: 250, optional: false, unique: false)
            shot.string("image", length: 250, optional: false, unique: false)
            shot.int("image_overriden", optional: false, unique: false, default: 0)
            shot.int("views_count", optional: false, unique: false, default: 0)
            shot.int("likes_count", optional: false, unique: false, default: 0)
            shot.string("created_at", length: 250, optional: false, unique: false)
        }
        
    }
    
    
}

extension Sequence where Iterator.Element == Shot {
    
    func makeJSON(request: Request) throws -> JSON {
        return try JSON(node: self.map {
            try $0.makeJSON(request: request)
        })
    }
    
}
