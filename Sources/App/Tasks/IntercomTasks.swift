//
//  Dribbble.swift
//  Walllpaper
//
//  Created by Maxime De Greve on 19/02/2017.
//
//

import Vapor
import HTTP
import Fluent
import FluentMySQL
import Foundation

final class IntercomTasks {
    
    static func schedule(){
        
        try? background {
            try? updateUsers()
        }
        
    }
    
    static func updateUsers() throws -> Void{
        
        //  Rate Limiting: 82 request per minute
        let limitAmount = 82
        let usersCount = try User.query().all().count
        let amountIterations = ceil(Double(usersCount)/Double(limitAmount))
                    
        for iterate in 0...Int(amountIterations) {
            
            let offset = iterate * limitAmount
            let limit = Limit(count: limitAmount, offset: offset)
            let userQuery = try User.query()
            userQuery.limit = limit
            let users = try userQuery.all()
            try? updateUsersGroup(users: users)
            sleep(1)
            
        }
        
    }
    
    static func updateUsersGroup(users: [User]) throws -> Void{
        
        for user in users{
            if let userId = user.id?.string{
                let result = try Intercom.saveUser(userId: userId, name: user.name, avatarUrl: user.dribbbleAvatarUrl)
                Swift.print(result.description)
            }
        }
        
    }
    
}
