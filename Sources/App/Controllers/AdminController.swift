//
//  AdminController.swift
//  Walllpaper
//
//  Created by Maxime De Greve on 20/02/2017.
//
//

import Vapor
import HTTP
import Turnstile
import Auth

final class AdminController {
    
    func addRoutes(to drop: Droplet) {

        drop.get("admin", handler: index)
        
    }
    
    func index(_ request: Request) throws -> ResponseRepresentable {
        
        Swift.print(user)
        return try drop.view.make("admin")
        
    }
    
}
