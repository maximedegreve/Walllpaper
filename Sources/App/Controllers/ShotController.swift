import Vapor
import HTTP
import FluentMySQL
import Fluent

final class PublicShotController: ResourceRepresentable{
    
    func index(_ request: Request) throws -> ResponseRepresentable {
        
        let shotQuery = try Shot.query()
        shotQuery.limit = Limit(count: 8, offset: 0)
        return try shotQuery.union(User.self).filter(User.self, "consented", true).all().makeJSON()
        
    }
    
    func makeResource() -> Resource<Shot> {
        return Resource(
            index: index
        )
    }
    
}

final class ShotController: ResourceRepresentable {
    
    func index(request: Request) throws -> ResponseRepresentable {
        
        guard let categoryString = request.data["category"]?.string else {
            throw Abort.custom(status: .badRequest, message: "No category was defined")
        }
        
        if categoryString == "liked"{
            return try liked(request: request)
        }
        
        if categoryString == "all"{
            return try all(request: request)
        }
        
        guard let category = try Category.query().filter("name", categoryString).first() else {
            throw Abort.custom(status: .badRequest, message: "Category not found")
        }
        
        let user = try request.user()
        
        return try category.shots().union(User.self).filter(User.self, "consented", true).all().makeJSON(user: user)
        
    }
    
    func all(request: Request) throws -> ResponseRepresentable {
        
        let user = try request.user()

        return try Shot.query().all().makeJSON(user: user)
        
    }
    
    func liked(request: Request) throws -> ResponseRepresentable {
        
        let user = try request.user()
        
        guard let userId = user.id else {
            throw Abort.custom(status: .badRequest, message: "Could not get user id")
        }
        
        return try Like.query().filter("user_id", userId).all().makeJSON(request: request)
        
    }
    
    func makeResource() -> Resource<Shot> {
        return Resource(
            index: index
        )
    }
    
}


extension Request {
    func shot() throws -> Shot {
        guard let json = json else { throw Abort.badRequest }
        return try Shot(node: json)
    }
}
