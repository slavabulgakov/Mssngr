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
    fileprivate let chatSelectObserver: Signal<Chat, NoError>.Observer
    let chatSelectSignal: Signal<Chat, NoError>

    init(appController: AppController) {
        self.appController = appController
        (chatSelectSignal, chatSelectObserver) = Signal<Chat, NoError>.pipe()
    }

    func updateChatsProducer() -> SignalProducer<(), NoError>? {
        guard let network = appController?.network else { return nil }
        let remove = network.removeChatProducer().on {
            guard let index = self._chats.index(of: ChatsCellViewModel(chat: $0)) else { return }
            self._chats.remove(at: index)
        }
        let add = network.addChatProducer().on { self._chats += [ChatsCellViewModel(chat: $0)] }
        return SignalProducer.merge(remove, add).debounce(0.1, on: QueueScheduler.main).map { _ in return () }
    }

    func items() -> [ChatsCellViewModel] {
        return _chats
    }

    func select(cellModel: ChatsCellViewModel) {
        chatSelectObserver.send(value: cellModel.chat)
    }
}
