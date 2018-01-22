//
//  Service.swift
//  Mssngr
//
//  Created by Slava Bulgakov on 21/01/2018.
//  Copyright © 2018 Slava Bulgakov. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import ObjectMapper
import ReactiveSwift
import Result

typealias FirebaseUser = FirebaseAuth.User

class Service: ServiceProtocol {
    fileprivate var reference: DatabaseReference = Database.database().reference()
    var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?

    deinit {
        if let listenerHandle = authStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(listenerHandle)
        }
        reference.removeAllObservers()
    }

    lazy var user: Property<User?> = {
        let producer = SignalProducer<User?, NoError> { observer, _ in
            Auth.auth().addStateDidChangeListener { auth, user in
                guard let notNilUser = user else {
                    observer.send(value: nil)
                    return
                }
                observer.send(value: User(user: notNilUser))
            }
        }
        var user: User?
        if let fu = Auth.auth().currentUser {
            user = User(user: fu)
        }
        return Property(initial: user, then: producer)
    }()

    func user(byId userId: String, block: @escaping (User?) -> ()) {
        reference.child("users/\(userId)").observeSingleEvent(of: .value) { snapshot in
            block(User(snapshot: snapshot))
        }
    }

    fileprivate var chatsQuery: DatabaseQuery? {
        guard let id = self.user.value?.id else { return nil }
        return self.reference.child("chats").queryOrdered(byChild: "users/\(id)").queryEqual(toValue: true)
    }

    func addChatProducer() -> SignalProducer<ChatWithoutUsers, NoError> {
        return SignalProducer<ChatWithoutUsers, NoError> { [unowned self] observer, _ in
            self.chatsQuery?.observe(.childAdded) { snapshot in
                guard let chat = ChatWithoutUsers(snapshot: snapshot) else { return }
                observer.send(value: chat)
            }
        }
    }

    func removeChatProducer() -> SignalProducer<Chat, NoError> {
        return SignalProducer<Chat, NoError> { [unowned self] observer, _ in
            self.chatsQuery?.observe(.childRemoved) { snapshot in
                guard let chat = ChatWithoutUsers(snapshot: snapshot) else { return }
                observer.send(value: Chat(id: chat.id, users: Set(), messages: chat.messages))
            }
        }
    }

    func searchUsers(byEmail email: String, block: @escaping ([User]) -> Void) {
        reference.child("users").queryOrdered(byChild: "email").queryStarting(atValue: email)
            .queryEnding(atValue: email + "\u{f8ff}").observeSingleEvent(of: .value) { snapshot in
                var users = [User]()
                for data in snapshot.children {
                    guard let s = data as? DataSnapshot, let user = User(snapshot: s) else { continue }
                    users += [user]
                }
                block(users)
        }
    }

    func sendMessage(chat: Chat, messageText: String) -> Message? {
        guard let currentUser = self.user.value else { return nil }
        return Message.createMessage(chatRef: reference.child("chats/\(chat.id)"), text: messageText, userId: currentUser.id)
    }

    func addChat(forUsers users: Set<User>, firstMessageText: String) -> Chat? {
        guard let currentUser = self.user.value else { return nil }
        let allUsers = users.union(Set([currentUser]))
        let newChatRef = reference.child("chats").childByAutoId()
        var usersIds = [String: Bool]()
        for user in allUsers {
            usersIds[user.id] = true
            reference.child("users/\(user.id)/chats/\(newChatRef.key)").setValue(true)
        }
        let firstMessage = Message.createMessage(chatRef: newChatRef, text: firstMessageText, userId: currentUser.id)
        newChatRef.child("users").setValue(usersIds)
        return Chat(id: newChatRef.key, users: allUsers, messages: [firstMessage])
    }

    func messages(chat: Chat) -> SignalProducer<Message, NoError> {
        return SignalProducer<Message, NoError> { [unowned self] observer, _ in
            self.reference.child("chats/\(chat.id)/messages").observe(.childAdded) { snapshot in
                guard let message = Message(snapshot: snapshot), let currentUserId = self.user.value?.id else { return }
                message.isIncoming = currentUserId != message.userId
                observer.send(value: message)
            }
        }
    }

    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password)
    }

    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [unowned self] user, error in
            guard let uid = user?.uid, let email = user?.email else { return }
            self.reference.child("users/\(uid)/email").setValue(email)
        }
    }
}

extension User {
    convenience init(user: FirebaseUser) {
        self.init(id: user.uid, email: user.email)
    }
}

extension BaseMappable {
    static var firebaseIdKey: String {
        get {
            return "FirebaseIdKey"
        }
    }
    init?(snapshot: DataSnapshot) {
        guard var json = snapshot.value as? [String: Any] else {
            return nil
        }
        json[Self.firebaseIdKey] = snapshot.key as Any

        self.init(JSON: json)
    }
}

extension Message {
    static func createMessage(chatRef: DatabaseReference, text: String, userId: String) -> Message {
        let newMessageRef = chatRef.child("messages").childByAutoId()
        let message = Message(id: newMessageRef.key, text: text, userId: userId)
        newMessageRef.setValue(message.toJSON())
        return message
    }
}
