//
//  UserController.swift
//  Walllpaper
//
//  Created by Maxime De Greve on 03/03/2017.
//
//

import Vapor
import HTTP
import Fluent
import FluentMySQL

final class UserController {
    
    func me(request: Request) throws -> ResponseRepresentable {
        let user = try request.user()
        let userJSON = try user.makeJSON()
        let response = Response()
        response.json = userJSON
        return response
    }
        
}
