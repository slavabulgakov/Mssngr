//
//  NetworkController.swift
//  Mssngr
//
//  Created by Slava Bulgakov on 19/12/2017.
//  Copyright © 2017 Slava Bulgakov. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import ReactiveSwift
import ReactiveCocoa
import Result

typealias FirebaseUser = FirebaseAuth.User

class NetworkController {
    fileprivate var reference: DatabaseReference = Database.database().reference()
    var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    let semaphore = DispatchSemaphore(value: 0)
    let queue = DispatchQueue(label: "com.slavabulgakov.Mssngr.NetworkQueue", qos: .utility, attributes: .concurrent)

    enum NetworkError: Error {
        case signInNeeded
    }

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
        return Property(initial: nil, then: producer)
    }()

    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password)
    }

    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [unowned self] user, error in
            guard let uid = user?.uid, let email = user?.email else { return }
            self.reference.child("users/\(uid)/email").setValue(email)
        }
    }

    func messages(chat: Chat) -> SignalProducer<Message, NoError> {
        return SignalProducer<Message, NoError> { [unowned self] observer, _ in
            self.reference.child("chats/\(chat.id)/messages").observe(.childAdded) { snapshot in
                guard let text = snapshot.value as? String else { return }
                observer.send(value: Message(text: text))
            }
        }
    }

    func addChat(forUsers users: Set<User>, firstMessage: Message) -> Chat? {
        guard let currentUser = Auth.auth().currentUser else { return nil }
        let mutableUsers = users.union(Set([User(user: currentUser)]))
        let newChatRef = reference.child("chats").childByAutoId()
        var usersIds = [String: Bool]()
        for user in mutableUsers {
            usersIds[user.id] = true
            reference.child("users/\(user.id)/chats/\(newChatRef.key)").setValue(true)
        }
        newChatRef.setValue(["users": usersIds])
        let chat = Chat(id: newChatRef.key, users: mutableUsers, messages: [firstMessage])
        let newMessageRef = newChatRef.child("messages").childByAutoId()
        newMessageRef.setValue(firstMessage.text)
        return chat
    }

    func sendMessage(chat: Chat, message: Message) {
        let newMessageRef = reference.child("chats/\(chat.id)/messages").childByAutoId()
        newMessageRef.setValue(message.text)
    }

    func searchUsers(byEmail email: String, block: @escaping ([User]) -> Void) {
        reference.child("users").queryOrdered(byChild: "email").queryStarting(atValue: email)
            .queryEnding(atValue: email + "\u{f8ff}").observeSingleEvent(of: .value) { snapshot in
                var users = [User]()
                for data in snapshot.children {
                    guard let s = data as? DataSnapshot, let user = User.validate(key: s.key, value: s.value),
                        user.email != Auth.auth().currentUser?.email
                        else { return }
                    users += [user]
                }
                block(users)
        }
    }

    fileprivate func loadUsers(byUsersIds usersIds: Set<String>) -> [String: User] {
        let group = DispatchGroup()
        var users = [String: User]()
        for userId in usersIds {
            group.enter()
            reference.child("users/\(userId)").observeSingleEvent(of: .value) { snapshot in
                defer { group.leave() }
                guard let user = User.validate(key: snapshot.key, value: snapshot.value) else { return }
                users[user.id] = user
            }
        }
        group.wait()
        return users
    }
    
    var chatsQuery: DatabaseQuery? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return self.reference.child("chats").queryOrdered(byChild: "users/\(uid)").queryEqual(toValue: true)
    }

    func chatsProducer() -> SignalProducer<Chat, NoError> {
        return SignalProducer<ChatWithoutUsers, NoError> { [unowned self] observer, _ in
            self.chatsQuery?.observe(.childAdded) { snapshot in
                guard let chat = ChatWithoutUsers.validate(key: snapshot.key, value: snapshot.value) else { return }
                observer.send(value: chat)
            }
        }.flatMap(.merge) { chat -> SignalProducer<Chat, NoError> in
            return SignalProducer<Chat, NoError> { [unowned self] observer, _ in
                self.asyncRequest(background: {
                    return self.loadUsers(byUsersIds: chat.users).map { $0.value }
                }) { users in
                    observer.send(value: Chat(id: chat.id, users: Set(users), messages: chat.messages))
                }
            }
        }
    }
}

extension NetworkController {
    func syncRequest<T>(request: (@escaping (T) -> ()) -> ()) -> T? {
        var response: T?
        request { [unowned self] r in
            response = r
            self.semaphore.signal()
        }
        semaphore.wait()
        return response
    }

    func asyncRequest<T>(background: @escaping () -> (T), main: @escaping (T) -> ()) {
        queue.async {
            let response = background()
            DispatchQueue.main.async {
                main(response)
            }
        }
    }
}

extension User {
    convenience init(user: FirebaseUser) {
        self.init(id: user.uid, email: user.email)
    }
}
