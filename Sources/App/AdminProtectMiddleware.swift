//
//  AdminProtectionMiddlewear.swift
//  Walllpaper
//
//  Created by Maxime De Greve on 23/02/2017.
//
//

import HTTP

public class AdminProtectMiddleware: Middleware {
    public let error: Error
    public init(error: Error) {
        self.error = error
    }
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        
        guard let user = try request.auth.user() as? User else {
            throw self.error
        }
        if user.admin == false {
            throw self.error
        }

        return try next.respond(to: request)
    }
}
