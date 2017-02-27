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
            
        guard let accessToken = request.data["token"]?.string else {
            throw Abort.badRequest
        }

        let token = AccessToken(string: accessToken)
        
        try User.authenticate(credentials: token)

        return try next.respond(to: request)

    }
}
