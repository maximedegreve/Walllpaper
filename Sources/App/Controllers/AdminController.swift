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
        drop.post("admin", handler: post)
        drop.get("admin/creators", handler: creators)
        
    }
    
    func getShots() throws -> [Shot]{
        
        let shotsQuery = try Shot.query()
        shotsQuery.limit = Limit(count: 42, offset: 0)
        let shots = try shotsQuery.sort("created_at", .descending).all()
        return shots
        
    }
    
    func getCategories() throws -> [Category]{
        
        return try Category.query().all()
        
    }
    
    func index(_ request: Request) throws -> ResponseRepresentable {

        return try drop.view.make("admin", [
                "shots": try getShots().makeNode(),
                "categories": try getCategories().makeNode(),
                ])
        
    }
    
    func post(_ request: Request) throws -> ResponseRepresentable {
        
        if let shotId = request.data["shot-id"]?.int{
            
            let response = try Dribbble.shot(token: Dribbble.access_token, id: shotId)
            
            guard let shotData = response.json?.object else {
                throw Abort.badRequest
            }
            
            var shot = try Shot.dribbbleData(data: shotData)
            try shot.save()
            
        }
        
        return try drop.view.make("admin", [
            "shots": try getShots().makeNode(),
            "categories": try getCategories().makeNode(),
            ])
    }
    
    func creators(_ request: Request) throws -> ResponseRepresentable {
        
        let users = try User.query().sort("created_at", .descending).all().makeNode()
        
        return try drop.view.make("admin-creator", [
            "users": users,
            ])
        
    }
    
}
