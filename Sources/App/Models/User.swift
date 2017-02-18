//
//  User.swift
//  Walllpaper
//
//  Created by Maxime De Greve on 18/02/2017.
//
//

import Vapor
import Foundation

final class User: Model {
    var id: Node?
    var dribbbleId: Int
    var dribbbleUsername: String
    var dribbbleUrl: String
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
        case registerNotSupported
        case unsupportedCredentials
    }
    
    init(dribbbleId: Int, dribbbleUsername: String, dribbbleUrl: String, avatarUrl: String, location: String, website: String, twitter: String, followersCount: Int, followingCount: Int, consented: Bool) {
        self.dribbbleId = dribbbleId
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
    }
    
    init(node: Node, in context: Context) throws {
        self.id = nil
        self.dribbbleId = try node.extract("dribbble_id")
        self.dribbbleUsername = try node.extract("dribbble_username")
        self.dribbbleUrl = try node.extract("dribbble_url")
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
        return try Node(node: [
            "id": id,
            "dribbble_id": dribbbleId,
            "dribbble_username": dribbbleUsername,
            "dribbble_url": dribbbleUrl,
            "avatar_url": avatarUrl,
            "location": location,
            "website": website,
            "twitter": twitter,
            "followers_count": followersCount,
            "following_count": followingCount,
            "consented": consented,
            "created_at": createdAt,
            ])
    }
    
    static func prepare(_ database: Database) throws {
        
        try database.create("users") { user in
            user.id()
            user.int("dribbble_id", optional: false, unique: true, default: 0)
            user.string("dribbble_username", length: 250, optional: false, unique: true)
            user.string("dribbble_url", length: 250, optional: false, unique:true)
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
        let user: User?
        
        switch credentials {
        case let id as Identifier:
            user = try User.find(id.id)
        case let accessToken as AccessToken:
            user = try User.query().filter("access_token", accessToken.string).first()
        case let apiKey as APIKey:
            user = try User.query().filter("email", apiKey.id).filter("password", apiKey.secret).first()
        default:
            throw Abort.custom(status: .badRequest, message: "Invalid credentials.")
        }
        
        guard let u = user else {
            throw Abort.custom(status: .badRequest, message: "User not found")
        }
        
        return u
    }
    
    
    static func register(credentials: Credentials) throws -> Auth.User {
        throw Abort.custom(status: .badRequest, message: "Register not supported.")
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
