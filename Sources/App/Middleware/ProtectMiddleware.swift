//
//  AdminProtectionMiddlewear.swift
//  Walllpaper
//
//  Created by Maxime De Greve on 23/02/2017.
//
//

import HTTP
import Vapor
import Turnstile

public class ProtectMiddleware: Middleware {
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
            
        guard let token = request.data["token"]?.string else {
            throw Abort.badRequest
        }

        let accessToken = AccessToken(string: token)
        
        try User.authenticate(accessToken: accessToken)

        return try next.respond(to: request)

    }
}
