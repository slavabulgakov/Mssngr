//
//  Models.swift
//  Mssngr
//
//  Created by Slava Bulgakov on 24/12/2017.
//  Copyright © 2017 Slava Bulgakov. All rights reserved.
//

import Foundation
import ObjectMapper

class User: ImmutableMappable, Equatable, Hashable {
    var id: String
    var email: String?

    required init(map: Map) throws {
        id = try map.value(User.firebaseIdKey)
        email = try? map.value("email")
    }

    init(id: String, email: String?) {
        self.id = id
        self.email = email
    }

    func mapping(map: Map) {
        id >>> map[User.firebaseIdKey]
        email >>> map["email"]
    }

    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }

    var hashValue: Int {
        return id.hashValue
    }
}

class Message: ImmutableMappable {
    var id: String
    var text: String
    var userId: String
    var isIncoming = false

    required init(map: Map) throws {
        id = try map.value(Message.firebaseIdKey)
        text = try map.value("text")
        userId = try map.value("userId")
    }

    init(id: String, text: String, userId: String) {
        self.id = id
        self.text = text
        self.userId = userId
    }

    func mapping(map: Map) {
        id >>> map[Message.firebaseIdKey]
        text >>> map["text"]
        userId >>> map["userId"]
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

    static func == (lhs: Chat, rhs: Chat) -> Bool {
        return lhs.id == rhs.id
    }
}

class ChatWithoutUsers: ImmutableMappable {
    var id: String
    var users: Set<String>
    var messages: [Message]
    
    let messagesTransform = TransformOf<[Message], [String: [String: String]]>(fromJSON: { dict -> [Message]? in
        dict?.map({ Message(id: $0.key, text: $0.value["text"] ?? "", userId: $0.value["userId"] ?? "") })
    }) { messages -> [String : [String : String]]? in
        var result = [String : [String : String]]()
        for message in messages ?? [] {
            result[message.id] = ["text": message.text, "userId": message.userId]
        }
        return result
    }

    required init(map: Map) throws {
        id = try map.value(ChatWithoutUsers.firebaseIdKey)
        users = try map.value("users", using: SetKeyTransform())
        messages = try map.value("messages", using: messagesTransform)
    }

    func mapping(map: Map) {
        id >>> map[ChatWithoutUsers.firebaseIdKey]
        users >>> (map["users"], SetKeyTransform())
        messages >>> (map["messages"], messagesTransform)
    }
}

class SetKeyTransform: TransformType {
    typealias Object = Set<String>
    typealias JSON = [String: Bool]

    func transformFromJSON(_ value: Any?) -> Set<String>? {
        guard let v = value as? JSON else { return Set<String>() }
        return Set(v.keys)
    }

    func transformToJSON(_ value: Set<String>?) -> [String: Bool]? {
        return value?.reduce([String: Bool](), { (result, string) -> [String: Bool] in
                var dict = result
                dict[string] = true
                return dict
            })
    }
}
