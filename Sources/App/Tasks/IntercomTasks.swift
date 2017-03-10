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
        
        //  Rate Limiting: 82 request per 10 seconds (100 per minute)
        //  Also for each user update -0.1 we lose on request
        //  So limit goes down 10 for 100 users
        
        let limitAmount = 82 - 10
        let usersPerRequest = 100
        let usersCount = try User.query().all().count
        let amountIterations = ceil(Double(usersCount)/Double(usersPerRequest))
                    
        for iterate in 0...Int(amountIterations) {
            
            let offset = iterate * usersPerRequest
            let limit = Limit(count: usersPerRequest, offset: offset)
            let userQuery = try User.query()
            userQuery.limit = limit
            let users = try userQuery.all()
            _ = try? Intercom.bulkUsersUpdate(users: users)
            
            let secondsSleep = UInt32(floor(Double(limitAmount/10)))
            sleep(secondsSleep)
            
        }
        
    }
    
}
