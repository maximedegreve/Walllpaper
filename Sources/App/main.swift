import Vapor
import VaporMySQL
import Auth
import Sessions
import Fluent
import FluentMySQL
import Routing
import Jobs

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

drop.get("/") { request in
    return try drop.view.make("index")
}

drop.get("terms") { request in
    return try drop.view.make("terms")
}

drop.get("privacy") { request in
    return try drop.view.make("privacy")
}

drop.get("support") { request in
    return try drop.view.make("support")
}

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
        
        let userController = UserController()
        secure.get("me", handler: userController.me)
        secure.resource("shots", ShotController())
        secure.resource("likes", LikeController())
        secure.group("dribbble") { dribbble in
            
            let dribbbleController = DribbbleController()
            dribbble.get("follows-creators", handler: dribbbleController.isFollowingCreators)
            dribbble.get("follow-creators", handler: dribbbleController.followTheCreators)
            
        }
        
    }
}

// Tasks

// Every 6 hours
Jobs.add(interval: .seconds(21600)) {
    IntercomTasks.schedule()
}

drop.run()
