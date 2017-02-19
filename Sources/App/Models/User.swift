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
    var dribbbleUrl: String
    var dribbbleAccessToken: String
    var avatarUrl: String
    var location: String
    var website: String
    var twitter: String
    var followersCount: Int
    var followingCount: Int
    var consented: Bool = false
    var createdAt: String
    var exists: Bool = false
    
    enum Error: Swift.Error {
        case userNotFound
        case unsupportedCredentials
    }
    
    init(dribbbleId: Int, dribbbleUsername: String, dribbbleUrl: String, dribbbleAccessToken: String, avatarUrl: String, location: String, website: String, twitter: String, followersCount: Int, followingCount: Int, consented: Bool) {
        self.dribbbleId = dribbbleId
        self.dribbbleUsername = dribbbleUsername
        self.dribbbleUrl = dribbbleUrl
        self.dribbbleAccessToken = dribbbleAccessToken
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
    }
    
    func makeNode(context: Context) throws -> Node {
        
        var dict: [String: Node] = [:]
        dict["id"] = id
        dict["access_token"] = accessToken.makeNode()
        dict["dribbble_id"] = try dribbbleId.makeNode()
        dict["dribbble_username"] = dribbbleUsername.makeNode()
        dict["dribbble_url"] = dribbbleUrl.makeNode()
        dict["dribbble_access_token"] = dribbbleAccessToken.makeNode()
        dict["avatar_url"] = avatarUrl.makeNode()
        dict["location"] = location.makeNode()
        dict["website"] = website.makeNode()
        dict["twitter"] = twitter.makeNode()
        dict["followers_count"] = try followersCount.makeNode()
        dict["following_count"] = try followingCount.makeNode()
        dict["consented"] = consented.makeNode()
        dict["created_at"] = createdAt.makeNode()
        
        return .object(dict)

    }
    
    static func prepare(_ database: Database) throws {
        
        try database.create("users") { user in
            user.id()
            user.string("access_token", length: 250, optional: true, unique: false)
            user.int("dribbble_id", optional: false, unique: true, default: 0)
            user.string("dribbble_username", length: 250, optional: false, unique: true)
            user.string("dribbble_url", length: 250, optional: false, unique:true)
            user.string("dribbble_access_token", length: 250, optional: false, unique:true)
            user.string("avatar_url", length: 250, optional: false, unique: false)
            user.string("location", length: 250, optional: false, unique: false)
            user.string("website", length: 250, optional: true, unique: false)
            user.string("twitter", length: 250, optional: true, unique: false)
            user.int("followers_count", optional: false, unique: false, default: 0)
            user.int("following_count", optional: false, unique: false, default: 0)
            user.int("consented", optional: false, unique: false, default: 0)
            user.string("created_at", length: 250, optional: false, unique: false)
        }
        
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("users")
    }
}

import Auth

extension User: Auth.User {
    
    static func authenticate(credentials: Credentials) throws -> Auth.User {
        
        var user: User?
        
        switch credentials {
            
        case let accessToken as AccessToken:
            
            let response = try Dribbble.getUserData(token: accessToken.string)
            guard let dribbId = response.data["id"]?.int else {
                throw Abort.custom(status: .badRequest, message: "Something went wrong.")
            }
                
            user = try User.query().filter("dribbble_id", dribbId).first()

            
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
            
            let response = try Dribbble.getUserData(token: accessToken.string)
            
            guard let dribbId = response.data["id"]?.int,
                let dribbUsername = response.data["username"]?.string,
                let dribbUrl = response.data["html_url"]?.string,
                let avatarUrl = response.data["avatar_url"]?.string,
                let location = response.data["location"]?.string,
                let website = response.data["links"]?.object?["web"]?.string,
                let twitter = response.data["links"]?.object?["twitter"]?.string,
                let followersCount = response.data["followers_count"]?.int,
                let followingCount = response.data["followings_count"]?.int else {
                    throw Abort.badRequest
            }
            
            var newUser = User(dribbbleId: dribbId, dribbbleUsername: dribbUsername, dribbbleUrl: dribbUrl, dribbbleAccessToken: accessToken.string, avatarUrl: avatarUrl, location: location, website: website, twitter: twitter, followersCount: followersCount, followingCount: followingCount, consented: false)
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
