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
import Auth

final class LoginController {
    
    func addRoutes(to drop: Droplet) {
        drop.get("admin/login", handler: loginAdmin)
        drop.get("api/login", handler: login)
    }
    
    func login(_ request: Request) throws -> ResponseRepresentable {
        
        guard let code = request.data["code"]?.string else {
                throw Abort.badRequest
        }
        
        guard let accessToken = try Dribbble.getToken(code: code) else {
            throw Abort.badRequest
        }
        
        let token = DribbbleAccessToken(string: accessToken)
        
        if try request.session().data["isAdmin"]?.bool == true{
            try request.auth.login(token)
            return Response(redirect: "/admin")
        }
        
        let user = try User.authenticate(credentials: token)

        return user as! ResponseRepresentable
        
    }
    
    func loginAdmin(_ request: Request) throws -> ResponseRepresentable {
        try request.session().data["isAdmin"] = true
        return Response(redirect: Dribbble.loginLink())
    }
    

}
