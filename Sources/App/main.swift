import Vapor
import VaporMySQL
import Auth

let drop = Droplet()

try drop.addProvider(VaporMySQL.Provider.self)
drop.preparations.append(User.self)
drop.preparations.append(Shot.self)
drop.preparations.append(Category.self)
drop.preparations.append(Like.self)

let auth = AuthMiddleware(user: User.self)
drop.middleware.append(auth)

drop.group(auth) { authorized in
    //authorized.get("access_token") { request in
        // has been authorized
    //}
}

let login = LoginController()
login.addRoutes(to: drop)

drop.resource("shots", ShotController())

drop.run()
