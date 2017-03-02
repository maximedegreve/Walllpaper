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
        
        let user = try request.user()
        
        return try category.shots().union(User.self).filter(User.self, "consented", false).all().makeJSON(user: user)
        
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
