//
//  ServiceProtocol.swift
//  Mssngr
//
//  Created by Slava Bulgakov on 21/01/2018.
//  Copyright © 2018 Slava Bulgakov. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

protocol ServiceProtocol {
    var user: Property<User?> { get }
    func user(byId userId: String, block: @escaping (User?) -> ())
    func addChatProducer() -> SignalProducer<ChatWithoutUsers, NoError>
    func removeChatProducer() -> SignalProducer<Chat, NoError>
    func searchUsers(byEmail email: String, block: @escaping ([User]) -> Void)
    func sendMessage(chat: Chat, messageText: String) -> Message?
    func addChat(forUsers users: Set<User>, firstMessageText: String) -> Chat?
    func messages(chat: Chat) -> SignalProducer<Message, NoError>
    func signIn(email: String, password: String)
    func signUp(email: String, password: String)
}
