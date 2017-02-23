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
    var user: Node
    var shot: Node
    var createdAt: String
    var exists: Bool = false
    
    init(user: Node, shot: Node) {
        self.user = user
        self.shot = shot
        self.createdAt = Date().mysql
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        user = try node.extract("user_id")
        shot = try node.extract("shot_id")
        createdAt = try node.extract("created_at")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "user_id": user,
            "shot_id": shot,
            "created_at": createdAt
            ])
    }
    
    func makeJSON(request: Request) throws -> JSON {
        
        return try JSON(node: [
            "user_id": user,
            "shot_id": shot,
            "created_at": createdAt,
            ])
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete("likes")
    }
    
    public static func prepare(_ database: Database) throws {
        
        try database.create("likes") { like in
            like.id()
            like.parent(User.self, optional: false, unique: false)
            like.parent(Shot.self, optional: false, unique: false)
        }
        
    }
    
}
