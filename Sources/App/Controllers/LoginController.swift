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
    }
    
    func login(_ request: Request) throws -> ResponseRepresentable {
        
        guard let code = request.data["code"]?.string else {
                throw Abort.badRequest
        }
        
        guard let accessToken = try Dribbble.getToken(code: code) else {
            throw Abort.badRequest
        }
        
        let token = DribbbleAccessToken(string: accessToken)
        let user = try User.authenticate(credentials: token)
        
        return user as! ResponseRepresentable
        
    }

}
