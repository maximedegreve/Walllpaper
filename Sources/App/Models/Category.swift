//
//  Category.swift
//  Walllpaper
//
//  Created by Maxime De Greve on 18/02/2017.
//
//

import Vapor
import HTTP
import Fluent
import FluentMySQL

final class Category: Model {
    
    var id: Node?
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            ])
    }
    
    func makeJSON(request: Request) throws -> JSON {

        return try JSON(node: [
            "name": name,
            ])
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete("categories")
    }
    
    public static func prepare(_ database: Database) throws {
        
        try database.create("categories") { category in
            category.id()
            category.string("name", length: 250, optional: false, unique: false)
        }
        
    }
    
}
