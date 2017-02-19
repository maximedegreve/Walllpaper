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

let login = LoginController()
login.addRoutes(to: drop)

drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

drop.resource("shots", ShotController())

drop.run()
