//
//  LoginController.swift
//  Walllpaper
//
//  Created by Maxime De Greve on 19/02/2017.
//
//

import Vapor
import HTTP
import Turnstile

final class LoginController {
    
    //https://dribbble.com/oauth/authorize?redirect_uri=http://0.0.0.0:8080/api/login&client_id=f4128949138dccac8ea96cc32f77ba892745ceaa93def72774ca0b2dbfc4d0d6&scope=write public
    
    func addRoutes(to drop: Droplet) {
        drop.get("api/login", handler: login)
        //drop.post("api/register", handler: createAdmin)
    }
    
    func login(_ request: Request) throws -> ResponseRepresentable {
        
        guard let code = request.data["code"]?.string else {
                throw Abort.badRequest
        }
        
        guard let accessToken = try Dribbble.getToken(code: code) else {
            throw Abort.badRequest
        }
        
        let token = AccessToken(string: accessToken)
        let user = try User.authenticate(credentials: token)
        
        return user as! ResponseRepresentable
        
    }
    
    
    /*
    func createAdmin(_ request: Request)throws -> ResponseRepresentable {
        guard let username = request.data["username"]?.string,
            let password = request.data["password"]?.string else {
                throw Abort.badRequest
        }
        
        
        let creds = UsernamePassword(username: username, password: password)
        var user = try User.register(credentials: creds) as? User
        if user != nil {
            try user!.save()
            return Response(redirect: "/user/\(user!.username)")
        } else {
            return Response(redirect: "/create-admin")
        }
    }
    
    func adminLogin(_ request: Request)throws -> ResponseRepresentable {
        guard let username = request.data["username"]?.string,
            let password = request.data["password"]?.string else {
                throw Abort.badRequest
        }
        
        let credentials = UsernamePassword(username: username, password: password)
        do {
            try request.auth.login(credentials, persist: true)
            return Response(redirect: "/admin/new-post")
        } catch {
            return Response(redirect: "/login?succeded=false")
        }
    }
 
*/
}
