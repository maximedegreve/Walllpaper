//
//  AdminProtectionMiddlewear.swift
//  Walllpaper
//
//  Created by Maxime De Greve on 23/02/2017.
//
//

import HTTP
import Vapor

public class AdminProtectMiddleware: Middleware {
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        
        var user: User?
        
        do {
            user = try request.auth.user() as? User
        } catch {
            return Response(redirect: "/admin/login")
        }

        if user?.admin == false {
            throw Abort.custom(
                status: .badRequest,
                message: "You are not a admin."
            )
        }
        
        return try next.respond(to: request)

    }
}
