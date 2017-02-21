//
//  AdminController.swift
//  Walllpaper
//
//  Created by Maxime De Greve on 20/02/2017.
//
//

import Vapor
import HTTP
import Turnstile
import Auth
import Fluent

final class AdminController {
    
    func addRoutes(to drop: Droplet) {

        drop.get("admin", handler: index)
        
    }
    
    func index(_ request: Request) throws -> ResponseRepresentable {
                    
        let shotsQuery = try Shot.query()
        shotsQuery.limit = Limit(count: 42, offset: 0)
        let shots = try shotsQuery.sort("created_at", .descending).all()
            
        return try drop.view.make("admin", [
                "shots": shots.makeNode(),
                ])
        
    }
    
}
