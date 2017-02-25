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

        drop.group(AdminProtectMiddleware()) { secure in
            
            secure.get("admin", handler: index)
            secure.post("admin", handler: post)
            secure.get("admin","delete", handler: delete)
            secure.post("admin","category", handler: categoryPost)
            secure.delete("admin","category", handler: categoryDelete)
        }

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
                "shots": try getShots().makeAdminNode(),
                ])
        
    }
    
    func delete(_ request: Request) throws -> ResponseRepresentable {
        
        guard let shotID = request.data["shot-id"]?.int else {
            throw Abort.badRequest
        }
        
        guard let shot = try Shot.find(shotID) else {
            throw Abort.badRequest
        }
        
        try shot.delete()
        
        return Response(redirect: "/admin")
    }
    
    func categoryPost(_ request: Request) throws -> ResponseRepresentable {
        
        guard let shotID = request.data["shot-id"]?.int else {
            throw Abort.badRequest
        }
        
        guard let shot = try Shot.find(shotID) else {
            throw Abort.badRequest
        }
        
        guard let categoryID = request.data["category-id"]?.int else {
            throw Abort.badRequest
        }
        
        guard let category = try Category.find(categoryID) else {
            throw Abort.badRequest
        }
        
        let pivot = try Pivot<Shot, Category>.query().filter("shot_id", shotID).filter("category_id", categoryID).first()
        
        if pivot != nil{
            // Already exists
            throw Abort.badRequest
        }
        
        var newPivot = Pivot<Shot, Category>(shot, category)   // Create the relationship
        try newPivot.save()
                
        return Response(status: .created, body: "Added to category...")
    }
    
    func categoryDelete(_ request: Request) throws -> ResponseRepresentable {

        guard let shotID = request.data["shot-id"]?.int else {
            throw Abort.badRequest
        }

        guard let categoryID = request.data["category-id"]?.int else {
            throw Abort.badRequest
        }
        
        let pivots = try Pivot<Shot, Category>.query().filter("shot_id", shotID).filter("category_id", categoryID).all()
        
        for pivot in pivots{
            try pivot.delete()
        }

        return Response(status: .created, body: "Deleted the category...")
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
        
        return Response(redirect: "/admin")
    }
    
}

private extension Sequence where Iterator.Element: Shot {
    func makeAdminNode() throws -> Node {
        return try Node(node: self.map {
            try $0.makeAdminShotNode()
        })
    }
}

private extension Shot {
    
    func makeAdminShotNode() throws -> Node {
        
        let categories = try self.categories().all()
        let possibleCategories = try Category.query().all()
        
        var categoriesList = [Node]()
        for category in possibleCategories{
            
            let isIncluded = categories.contains(where: { (cat) -> Bool in
                return cat.id == category.id
            })

            let node = try Node(node: [
                "id": category.id,
                "name": category.name,
                "included": isIncluded,
                ])
            categoriesList.append(node)
            
        }
        
        return try Node(node: [
            "id": self.id,
            "title": self.title,
            "image": self.image,
            "categories": try categoriesList.makeNode(),
            ])

    }

}

