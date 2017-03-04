//
//  Like.swift
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

final class Like: Model {
    
    var id: Node?
    var userId: Node
    var shotId: Node
    var createdAt: String
    var exists: Bool = false
    
    init(user: Node, shot: Node) {
        self.userId = user
        self.shotId = shot
        self.createdAt = Date().mysql
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        userId = try node.extract("user_id")
        shotId = try node.extract("shot_id")
        createdAt = try node.extract("created_at")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "user_id": userId,
            "shot_id": shotId,
            "created_at": createdAt
            ])
    }
    
    func makeJSON(request: Request) throws -> JSON {
        
        let user = try request.user()
        guard let json = try shot().get()?.makeJSON(user: user) else {
            return JSON([:])
        }
        
        return json
        
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete("likes")
    }
    
    public static func prepare(_ database: Database) throws {
        
        try database.create("likes") { like in
            like.id()
            like.parent(User.self, optional: false, unique: false)
            like.parent(Shot.self, optional: false, unique: false)
            like.date("created_at")
        }
        
    }
    
}

extension Like {
    func shot() throws -> Parent<Shot> {
        return try parent(shotId)
    }
    func user() throws -> Parent<User> {
        return try parent(userId)
    }
}

extension Sequence where Iterator.Element: Like {
    func makeJSON(request: Request) throws -> JSON {
        return try JSON(node: self.map {
            try $0.makeJSON(request: request)
        })
    }
}


