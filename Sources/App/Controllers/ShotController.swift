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
        
        // Don't forget to change this
        return try category.shots().union(User.self).filter(User.self, "consented", false).all().makeJSON()
        
    }

    func makeResource() -> Resource<Shot> {
        return Resource(
            index: index
        )
    }
    
    func shotsIn(category: Category) throws -> [Shot]{
        
        if let mysql = drop.database?.driver as? MySQLDriver {
            
            
            
            //SELECT shots.id, shots.dribb_id, shots.title, shots.image_retina, shots.image_nonretina, shots.likes_count, users.name, users.avatar_url,shots.created_at, shots.image_overruled, shots.categories, (SELECT count(*) FROM likes WHERE likes.shot_id = shots.id AND likes.user_id = :user_id) AS liked FROM shots INNER JOIN users ON users.dribb_uid = shots.dribb_uid WHERE creator = 1 AND FIND_IN_SET(:tagId,shots.categories) > 0 ORDER BY shots.created_at DESC LIMIT :offset, :amount");
            
            
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
