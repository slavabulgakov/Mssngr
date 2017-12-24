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

class User {
    init(user: FirebaseUser) {

    }
}

class Chat: Equatable {
    var id: String
    var users: Set<String>
    
    init(id: String, users: Set<String>) {
        self.id = id
        self.users = users
    }
    
    static func validate(key: String, value: Any?) -> Chat? {
        guard let dict = value as? [AnyHashable: Any], let users = dict["users"] as? [String: Bool] else { return nil }
        let chat = Chat(id: key, users: Set<String>(users.keys))
        return chat
    }
    
    static func ==(lhs: Chat, rhs: Chat) -> Bool {
        return lhs.id == lhs.id
    }
}

class NetworkController {
    fileprivate lazy var reference: DatabaseReference = Database.database().reference()
    var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?

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
        Auth.auth().createUser(withEmail: email, password: password)
    }
    
    func chatsQuery() -> DatabaseQuery? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return reference.child("chats").queryOrdered(byChild: "users/\(uid)")
            .queryEqual(toValue: true)
    }

    func addChatProducer() -> SignalProducer<Chat, NoError> {
        return SignalProducer<Chat, NoError> { [unowned self] observer, _ in
            self.chatsQuery()?.observe(.childAdded) { snapshot in
                guard let chat = Chat.validate(key: snapshot.key, value: snapshot.value) else { return }
                observer.send(value: chat)
            }
        }
    }
    
    func removeChatProducer() -> SignalProducer<Chat, NoError> {
        return SignalProducer<Chat, NoError> { [unowned self] observer, _ in
            self.chatsQuery()?.observe(.childRemoved) { snapshot in
                guard let chat = Chat.validate(key: snapshot.key, value: snapshot.value) else { return }
                observer.send(value: chat)
            }
        }
    }

    func addChat() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let newChatRef = reference.child("chats").childByAutoId()
        let chatItem = ["users": [uid: true]]
        newChatRef.setValue(chatItem)
        reference.child("users/\(uid)/\(newChatRef.key)").setValue(true)
    }
}
