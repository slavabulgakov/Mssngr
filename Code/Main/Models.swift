//
//  Models.swift
//  Mssngr
//
//  Created by Slava Bulgakov on 24/12/2017.
//  Copyright © 2017 Slava Bulgakov. All rights reserved.
//

import Foundation

class User: Equatable, Hashable {
    var email: String?
    var id: String
    
    init(id: String, email: String?) {
        self.id = id
        self.email = email
    }
    
    static func validate(key: String, value: Any?) -> User? {
        guard let dict = value as? [AnyHashable: Any], let email = dict["email"] as? String else { return nil }
        return User(id: key, email: email)
    }
    
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    var hashValue: Int {
        return id.hashValue
    }
}

class Message {
    let text: String
    
    init(text: String) {
        self.text = text
    }
}

class Chat: Equatable {
    var id: String
    var users: Set<User>
    var messages: [Message]
    
    init(id: String, users: Set<User>, messages: [Message]) {
        self.id = id
        self.users = users
        self.messages = messages
    }
    
    static func ==(lhs: Chat, rhs: Chat) -> Bool {
        return lhs.id == rhs.id
    }
}

class ChatWithoutUsers {
    var id: String
    var users: Set<String>
    var messages: [Message]
    
    init(id: String, users: Set<String>, messages: [Message]) {
        self.id = id
        self.users = users
        self.messages = messages
    }
    
    static func validate(key: String, value: Any?) -> ChatWithoutUsers? {
        guard let dict = value as? [String: Any], let users = dict["users"] as? [String: Bool] else { return nil }
        let messages = (dict["messages"] as? [String: String])?.map { Message(text: $0.value) } ?? []
        return ChatWithoutUsers(id: key, users: Set(users.map({ $0.key })), messages: messages)
    }
}
