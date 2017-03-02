import Vapor
import VaporMySQL
import Auth
import Sessions
import Fluent
import FluentMySQL

let drop = Droplet()

try drop.addProvider(VaporMySQL.Provider.self)
drop.preparations.append(User.self)
drop.preparations.append(Shot.self)
drop.preparations.append(Pivot<Shot, Category>.self)
drop.preparations.append(Category.self)
drop.preparations.append(Like.self)

let memory = MemorySessions()
let sessions = SessionsMiddleware(sessions: memory)
drop.middleware.append(sessions)

let auth = AuthMiddleware(user: User.self)
drop.middleware.append(auth)

let login = LoginController()
login.addRoutes(to: drop)

let admin = AdminController()
admin.addRoutes(to: drop)

let adminCreators = AdminCreatorsController()
adminCreators.addRoutes(to: drop)

// API

drop.group("api") { api in
    api.resource("public-shots", PublicShotController())
    api.group(ProtectMiddleware()) { secure in
        secure.resource("shots", ShotController())
        secure.resource("likes", LikeController())
    }
}

drop.run()
