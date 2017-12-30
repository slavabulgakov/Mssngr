//
//  ChatViewModel.swift
//  Mssngr
//
//  Created by Slava Bulgakov on 28/12/2017.
//  Copyright © 2017 Slava Bulgakov. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

class ChatViewModel {
    let appController: AppController
    var state: State
    var text = ""
    fileprivate let textObserver: Signal<Void, NoError>.Observer
    let textSignal: Signal<Void, NoError>
    fileprivate let token: Lifetime.Token
    fileprivate let lifetime: Lifetime
    
    enum State {
        case new(Set<User>)
        case exist(Chat)
    }
    
    init(appController: AppController, state: State) {
        self.appController = appController
        self.state = state
        token = Lifetime.Token()
        lifetime = Lifetime(token)
        (textSignal, textObserver) = Signal<Void, NoError>.pipe()
        bindTextIfCan()
    }
    
    func bindTextIfCan() {
        guard case .exist(let chat) = state else { return }
        appController.network?.messages(chat: chat).take(during: lifetime).startWithValues { [weak self] message in
            self?.text += message.text + "\n"
            self?.textObserver.send(value: ())
        }
    }
    
    func sendMessage(text: String) {
        let message = Message(text: text)
        switch state {
        case .new(let users):
            guard let chat = appController.network?.addChat(forUsers: users, firstMessage: message) else { break }
            state = .exist(chat)
            bindTextIfCan()
        case .exist(let chat):
            appController.network?.sendMessage(chat: chat, message: message)
        }
    }
}
