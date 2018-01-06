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

    func chatsProducer() -> SignalProducer<(), NoError>? {
        return appController?.network?.chatsProducer().on {
            self._chats += [ChatsCellViewModel(chat: $0)]
        }.debounce(0.1, on: QueueScheduler.main).map { _ in return () }
    }

    var numberOfRows: Int {
        return _chats.count
    }

    func item(atIndex index: Int) -> ChatsCellViewModel {
        return _chats[index]
    }

    func select(index: Int) {
        chatSelectObserver.send(value: _chats[index].chat)
    }
}
