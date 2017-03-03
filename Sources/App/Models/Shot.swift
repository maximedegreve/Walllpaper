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
import Foundation

final class Shot: Model {
    
    var id: Node?
    var user_id: Node
    var dribbbleId: Int
    var title: String
    var description: String?
    var imageRetina: String
    var image: String
    var imageOverriden: String?
    var viewsCount: Int
    var likesCount: Int
    var createdAt: String
    var exists: Bool = false
    
    init(user: Node, dribbbleId: Int, title: String, description: String?, imageRetina: String, image: String, imageOverriden: String?, viewsCount: Int, likesCount: Int) {
        self.user_id = user
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
        user_id = try node.extract("user_id")
        dribbbleId = try node.extract("dribbble_id")
        title = try node.extract("title")
        description = try node.extract("description")
        imageRetina = try node.extract("image_retina")
        image = try node.extract("image")
        imageOverriden = try node.extract("image_overriden")
        viewsCount = try node.extract("views_count")
        likesCount = try node.extract("likes_count")
        createdAt = try node.extract("created_at")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "user_id": user_id,
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
    
    func makeJSON() throws -> JSON {
        
        return try JSON(node: [
            "id": self.id,
            "title": self.title,
            "description": self.description,
            "image_retina": self.imageRetina,
            "image": self.image,
            "image_overriden": self.imageOverriden,
            "views_count": self.viewsCount,
            "likes_count": self.likesCount,
            "categories": try self.categories().all().makeJSON(),
            "user":  try self.user().get()?.makeJSON(),
            "created_at": self.createdAt.makeNode()
            ])
        
    }
    
    func makeJSON(user: User) throws -> JSON{
        
        var normalJSON = try makeJSON()
        let liked = try likedByUser(user: user).makeNode()
        normalJSON["liked"] = JSON(liked)
        return normalJSON
        
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
            shot.text("description", optional: true, unique: false, default: nil)
            shot.string("image_retina", length: 250, optional: false, unique: false)
            shot.string("image", length: 250, optional: false, unique: false)
            shot.string("image_overriden", optional: true, unique: false, default: 0)
            shot.int("views_count", optional: false, unique: false, default: nil)
            shot.int("likes_count", optional: false, unique: false, default: 0)
            shot.date("created_at")
        }
        
    }
    
    public static func dribbbleData(data:[String: Polymorphic]) throws -> Shot{
        
        var user: User?

        guard let userId = data["user"]?.object?["id"]?.int else {
            throw Abort.badRequest
        }
        
        user = try User.findWith(dribbbleId: userId)
        
        if user == nil{
            
            guard let userData = data["user"]?.object else {
                throw Abort.badRequest
            }
            var newUser = try User.dribbbleData(data: userData)
            try newUser.save()
            
            user = newUser
            
        }
        
        guard let animated = data["animated"]?.bool else {
            throw Abort.badRequest
        }
        
        if animated == true{
            throw Abort.custom(status: .forbidden, message: "Animated gifs are not allowed")
        }
        
        guard let id = data["id"]?.int,
            let title = data["title"]?.string,
            let imageHiDPI = data["images"]?.object?["hidpi"]?.string,
            let imageNormal = data["images"]?.object?["normal"]?.string,
            let viewsCount = data["views_count"]?.int,
            let likesCount = data["likes_count"]?.int,
            let userNode = user?.id else {
                throw Abort.badRequest
        }
        let description = data["description"]?.string

        let shot = Shot(user: userNode, dribbbleId: id, title: title, description: description, imageRetina: imageHiDPI, image: imageNormal, imageOverriden: nil, viewsCount: viewsCount, likesCount: likesCount)
        
        return shot
        
    }
    
}

extension Shot {
    func categories() throws -> Siblings<Category> {
        return try siblings()
    }
    func user() throws -> Parent<User> {
        return try parent(self.user_id)
    }
    func likedByUser(user: User) throws -> Bool {
        
        guard let shotId = self.id, let userId = user.id else {
            return false
        }
        
        let liked = try Like.query().filter("user_id", userId).filter("shot_id", shotId).count()
        
        if liked > 0 {
            return true
        }
        
        return false
    }
}


extension Sequence where Iterator.Element: Shot {
    func makeJSON(user: User) throws -> JSON {
        return try JSON(node: self.map {
            try $0.makeJSON(user: user)
        })
    }
}


