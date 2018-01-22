//
//  NetworkController.swift
//  Mssngr
//
//  Created by Slava Bulgakov on 19/12/2017.
//  Copyright © 2017 Slava Bulgakov. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

class NetworkController {
    let service: ServiceProtocol
    let semaphore = DispatchSemaphore(value: 0)
    let queue = DispatchQueue(label: "com.slavabulgakov.Mssngr.NetworkQueue", qos: .utility, attributes: .concurrent)

    init(service: ServiceProtocol) {
        self.service = service
    }

    enum NetworkError: Error {
        case signInNeeded
    }

    var user: Property<User?> {
        return self.service.user
    }

    func signIn(email: String, password: String) {
        self.service.signIn(email: email, password: password)
    }

    func signUp(email: String, password: String) {
        self.service.signUp(email: email, password: password)
    }

    func messages(chat: Chat) -> SignalProducer<Message, NoError> {
        return self.service.messages(chat: chat)
    }

    func addChat(forUsers users: Set<User>, firstMessageText: String) -> Chat? {
        return self.service.addChat(forUsers: users, firstMessageText: firstMessageText)
    }

    func sendMessage(chat: Chat, messageText: String) -> Message? {
        return self.service.sendMessage(chat: chat, messageText: messageText)
    }

    func searchUsers(byEmail email: String, block: @escaping ([User]) -> Void) {
        self.service.searchUsers(byEmail: email) {
            var users = $0
            defer { block(users) }
            guard let user = self.service.user.value, let index = users.index(of: user) else { return }
            users.remove(at: index)
        }
    }

    fileprivate func users(byUsersIds usersIds: Set<String>) -> [String: User] {
        let group = DispatchGroup()
        var users = [String: User]()
        for userId in usersIds {
            group.enter()
            self.service.user(byId: userId) {
                defer { group.leave() }
                guard let user = $0 else { return }
                users[user.id] = user
            }
        }
        group.wait()
        return users
    }

    func addChatProducer() -> SignalProducer<Chat, NoError> {
        return self.service.addChatProducer().flatMap(.merge) { chat -> SignalProducer<Chat, NoError> in
            return SignalProducer<Chat, NoError> { [unowned self] observer, _ in
                self.asyncRequest(background: {
                    return self.users(byUsersIds: chat.users).map { $0.value }
                }) { users in
                    observer.send(value: Chat(id: chat.id, users: Set(users), messages: chat.messages))
                }
            }
        }
    }

    func removeChatProducer() -> SignalProducer<Chat, NoError> {
        return self.service.removeChatProducer()
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
