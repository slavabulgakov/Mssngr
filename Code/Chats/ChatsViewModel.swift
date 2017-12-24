//
//  ChatsViewModel.swift
//  Mssngr
//
//  Created by Slava Bulgakov on 19/12/2017.
//  Copyright © 2017 Slava Bulgakov. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

class ChatsViewModel {
    var appController: AppController?
    fileprivate var _chats = [ChatsCellViewModel]()
    lazy var chatsProducer: SignalProducer<[ChatsCellViewModel], NoError>? = {
        guard let n = appController?.network else { return nil }
        let add = n.addChatProducer().on(value: { [unowned self] in self._chats.append(ChatsCellViewModel(chat: $0)) })
        let remove = n.removeChatProducer().on { [unowned self] in
            guard let index = self._chats.index(of: ChatsCellViewModel(chat: $0)) else { return }
            self._chats.remove(at: index)
        }
        return SignalProducer<Chat, NoError>.merge(add, remove).debounce(0.1, on: QueueScheduler.main)
            .flatMap(.latest) { [unowned self] chat -> SignalProducer<[ChatsCellViewModel], NoError> in
                return SignalProducer<[ChatsCellViewModel], NoError> { observer, _ in
                    observer.send(value: self._chats)
                }
        }
    }()
    
    init(appController: AppController) {
        self.appController = appController
    }
    
    var numberOfRows: Int {
        return _chats.count
    }
    
    func item(atIndex index: Int) -> ChatsCellViewModel {
        return _chats[index]
    }
    
    func addChat() {
        appController?.network?.addChat()
    }
}
