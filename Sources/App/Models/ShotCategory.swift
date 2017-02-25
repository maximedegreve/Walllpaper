//
//  ShotCategory.swift
//  Walllpaper
//
//  Created by Maxime De Greve on 25/02/2017.
//
//
import Vapor
import HTTP
import Fluent
import FluentMySQL
import Foundation

final class ShotCategory: Model {

    static var entity = "shot_categories"

    var id: Node?
    var shot: Node
    var category: Node
    
    init(shot: Node, category: Node) {
        self.shot = shot
        self.category = category
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        shot = try node.extract("shot_id")
        category = try node.extract("category_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "shot": shot,
            "category": category,
            ])
    }
    
    public static func prepare(_ database: Database) throws {
        
        try database.create("shot_categories") { shotCategory in
            shotCategory.id()
            shotCategory.parent(Shot.self, optional: false, unique: false)
            shotCategory.parent(Category.self, optional: false, unique: false)
        }
        
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete("shot_categories")
    }
    
}
