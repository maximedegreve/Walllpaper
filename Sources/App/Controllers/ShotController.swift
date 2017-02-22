import Vapor
import HTTP

final class ShotController: ResourceRepresentable {
    func index(request: Request) throws -> ResponseRepresentable {
        return try Shot.all().makeJSON()
    }

    func show(request: Request, post: Shot) throws -> ResponseRepresentable {
        return post
    }

    func delete(request: Request, post: Shot) throws -> ResponseRepresentable {
        try post.delete()
        return JSON([:])
    }

    func clear(request: Request) throws -> ResponseRepresentable {
        try Shot.query().delete()
        return JSON([])
    }

    /*
    func update(request: Request, post: Shot) throws -> ResponseRepresentable {
        let new = try request.shot()
        var post = post
        post.content = new.content
        try post.save()
        return post
    }
 */


    func makeResource() -> Resource<Shot> {
        return Resource(
            index: index,
            show: show,
            //modify: update,
            destroy: delete,
            clear: clear
        )
    }
}


extension Request {
    func shot() throws -> Shot {
        guard let json = json else { throw Abort.badRequest }
        return try Shot(node: json)
    }
}
