//
//  User.swift
//  Walllpaper
//
//  Created by Maxime De Greve on 18/02/2017.
//
//

import Foundation
import Vapor
import FluentMySQL
import HTTP
import Fluent
import TurnstileCrypto

final class User: Model {
    var id: Node?
    var accessToken: String
    var dribbbleId: Int
    var dribbbleUsername: String
    var name: String
    var dribbbleUrl: String
    var dribbbleAccessToken: String?
    var avatarUrl: String?
    var location: String?
    var website: String?
    var twitter: String?
    var followersCount: Int
    var followingCount: Int
    var consented: Bool = false
    var createdAt: String
    var admin: Bool = false
    var exists: Bool = false
    
    enum Error: Swift.Error {
        case userNotFound
        case unsupportedCredentials
    }
    
    init(name: String, dribbbleId: Int, dribbbleUsername: String, dribbbleUrl: String, avatarUrl: String?, location: String?, website: String?, twitter: String?, followersCount: Int, followingCount: Int, consented: Bool) {
        self.dribbbleId = dribbbleId
        self.name = name
        self.dribbbleUsername = dribbbleUsername
        self.dribbbleUrl = dribbbleUrl
        self.avatarUrl = avatarUrl
        self.location = location
        self.website = website
        self.twitter = twitter
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.consented = consented
        self.createdAt = Date().mysql
        self.accessToken = TurnstileCrypto.URandom().secureToken
    }
    
    init(node: Node, in context: Context) throws {
        self.id = nil
        self.name = try node.extract("name")
        self.accessToken = try node.extract("access_token")
        self.dribbbleId = try node.extract("dribbble_id")
        self.dribbbleUsername = try node.extract("dribbble_username")
        self.dribbbleUrl = try node.extract("dribbble_url")
        self.dribbbleAccessToken = try node.extract("dribbble_access_token")
        self.avatarUrl = try node.extract("avatar_url")
        self.location = try node.extract("location")
        self.website = try node.extract("website")
        self.twitter = try node.extract("twitter")
        self.followersCount = try node.extract("followers_count")
        self.followingCount = try node.extract("following_count")
        self.consented = try node.extract("consented")
        self.createdAt = try node.extract("created_at")
        self.admin = try node.extract("admin")
    }
    
    func makeNode(context: Context) throws -> Node {
        
        var dict: [String: Node] = [:]
        dict["id"] = id
        dict["name"] = name.makeNode()
        dict["access_token"] = accessToken.makeNode()
        dict["dribbble_id"] = try dribbbleId.makeNode()
        dict["dribbble_username"] = dribbbleUsername.makeNode()
        dict["dribbble_url"] = dribbbleUrl.makeNode()
        dict["dribbble_access_token"] = dribbbleAccessToken?.makeNode()
        dict["avatar_url"] = avatarUrl?.makeNode()
        dict["location"] = location?.makeNode()
        dict["website"] = website?.makeNode()
        dict["twitter"] = twitter?.makeNode()
        dict["followers_count"] = try followersCount.makeNode()
        dict["following_count"] = try followingCount.makeNode()
        dict["consented"] = consented.makeNode()
        dict["created_at"] = createdAt.makeNode()
        dict["admin"] = admin.makeNode()
        
        return .object(dict)

    }
    
    func makeJSON() throws -> JSON {
        
        return try JSON(node: [
            "id": self.id,
            "name": self.name,
            "dribbble_id": self.dribbbleId,
            "dribbble_username": self.dribbbleUsername,
            "dribbble_url": self.dribbbleUrl,
            "location": self.location,
            "website": self.website,
            "twitter": self.twitter,
            "followers_count": self.followersCount,
            "following_count": self.followingCount,
            "created_at": self.createdAt
            ])
    }
    
    static func prepare(_ database: Database) throws {
        
        try database.create("users") { user in
            user.id()
            user.string("name", length: 250, optional: false, unique: false)
            user.string("access_token", length: 250, optional: true, unique: false)
            user.int("dribbble_id", optional: false, unique: true, default: 0)
            user.string("dribbble_username", length: 250, optional: false, unique: true)
            user.string("dribbble_url", length: 250, optional: false, unique:true)
            user.string("dribbble_access_token", length: 250, optional: true, unique:true)
            user.string("avatar_url", length: 250, optional: true, unique: false)
            user.string("location", length: 250, optional: true, unique: false)
            user.string("website", length: 250, optional: true, unique: false)
            user.string("twitter", length: 250, optional: true, unique: false)
            user.int("followers_count", optional: false, unique: false, default: 0)
            user.int("following_count", optional: false, unique: false, default: 0)
            user.int("consented", optional: false, unique: false, default: 0)
            user.date("created_at")
            user.int("admin", optional: false, unique: false, default: 0)
        }
        
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("users")
    }
    
    static func findWith(dribbbleId: Int) throws -> User?{
        return try User.query().filter("dribbble_id", dribbbleId).all().first
    }
    
    static func dribbbleData(data:[String: Polymorphic]) throws -> User{
        
        guard let dribbId = data["id"]?.int,
            let dribbUsername = data["username"]?.string,
            let name = data["name"]?.string,
            let dribbUrl = data["html_url"]?.string,
            let followersCount = data["followers_count"]?.int,
            let followingCount = data["followings_count"]?.int else {
                throw Abort.badRequest
        }
        
        let avatarUrl = data["avatar_url"]?.string
        let location = data["location"]?.string
        let website = data["links"]?.object?["web"]?.string
        let twitter = data["links"]?.object?["twitter"]?.string
        
        let newUser = User(name: name, dribbbleId: dribbId, dribbbleUsername: dribbUsername, dribbbleUrl: dribbUrl, avatarUrl: avatarUrl, location: location, website: website, twitter: twitter, followersCount: followersCount, followingCount: followingCount, consented: false)
        
        return newUser
        
    }
    
    static func withShots() throws -> [User]{
        
        
        if let mysql = drop.database?.driver as? MySQLDriver {
            
            let results = try mysql.raw("SELECT users.* FROM shots INNER JOIN users ON users.id = shots.user_id GROUP BY users.id")
            
            guard case .array(let array) = results else {
                return [User]()
            }
            
            let users = try array.map {
                try User(node: $0)
            }
            
            return users
        }
        
        return [User]()
        
    }
    
    
    
}

import Auth

extension User: Auth.User {
    
    static func authenticate(credentials: Credentials) throws -> Auth.User {
        
        var user: User?
        
        switch credentials {
            
        case let identifier as Identifier:
            
            user = try User.query().filter("id", identifier.id).first()
            
        case let accessToken as DribbbleAccessToken:
            
            let response = try Dribbble.user(token: accessToken.string)
            
            guard let dribbId = response.data["id"]?.int else {
                throw Abort.custom(status: .badRequest, message: "Something went wrong.")
            }
            
            user = try User.query().filter("dribbble_id", dribbId).first()
            
            // Else create account
            if user == nil{
                user = try User.register(credentials: accessToken) as? User
            }
            
            // Update Dribbble token
            user?.dribbbleAccessToken = accessToken.string

            try user?.save()
            
        case let accessToken as AccessToken:
            
            user = try User.query().filter("access_token", accessToken.string).first()
            
        default:
            throw Abort.custom(status: .badRequest, message: "Invalid credentials.")
        }

        guard let u = user else {
            throw Abort.custom(status: .badRequest, message: "User not found")
        }
                
        return u
    }
    
    
    static func register(credentials: Credentials) throws -> Auth.User {
        
        switch credentials {
            
        case let accessToken as DribbbleAccessToken:
            
            guard let response = try Dribbble.user(token: accessToken.string).json?.object else {
                throw Abort.badRequest
            }
            
            var newUser = try User.dribbbleData(data: response)
            try newUser.save()

            return newUser
            
        default:
            let type = type(of: credentials)
            throw Abort.custom(status: .forbidden, message: "Unsupported credential type: \(type).")
        }

    }
}

import HTTP

extension Request {
    
    func user() throws -> User {
        guard let user = try auth.user() as? User else {
            throw Abort.custom(status: .badRequest, message: "Invalid user type.")
        }
        
        return user
    }
    
}
