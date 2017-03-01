import Vapor
import HTTP
import FluentMySQL

final class ShotController: ResourceRepresentable {
    
    func index(request: Request) throws -> ResponseRepresentable {
        
        guard let categoryString = request.data["category"]?.string else {
            throw Abort.custom(status: .badRequest, message: "No category was defined")
        }

        guard let category = try Category.query().filter("name", categoryString).first() else {
            throw Abort.custom(status: .badRequest, message: "Category not found")
        }
        
        // Don't forget to add makejson user here
        return try category.shots().union(User.self).filter(User.self, "consented", false).all().makeJSON()
        
    }

    func makeResource() -> Resource<Shot> {
        return Resource(
            index: index
        )
    }
    
    func shotsIn(category: Category) throws -> [Shot]{
        
        if let mysql = drop.database?.driver as? MySQLDriver {

            let results = try mysql.raw("SELECT * FROM categories WHERE name = \(category.name) ")
        
            guard case .array(let array) = results else {
                return [Shot]()
            }
            
            let users = try array.map {
                try Shot(node: $0)
            }
            
            return users
        }
        
        return [Shot]()
        
    }
}


extension Request {
    func shot() throws -> Shot {
        guard let json = json else { throw Abort.badRequest }
        return try Shot(node: json)
    }
}
