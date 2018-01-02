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
import Chatto
import ChattoAdditions

class ChatViewModel {
    let appController: AppController
    var state: State
    fileprivate let token: Lifetime.Token
    fileprivate let lifetime: Lifetime
    
    var nextMessageId: Int = 0
    let preferredMaxWindowSize = 500
    var slidingWindow: SlidingDataSource<ChatItemProtocol>
    weak var delegate: ChatDataSourceDelegateProtocol?
    
    enum State {
        case new(Set<User>)
        case exist(Chat)
    }
    
    init(appController: AppController, state: State) {
        self.appController = appController
        self.state = state
        token = Lifetime.Token()
        lifetime = Lifetime(token)
        slidingWindow = SlidingDataSource(items: [], pageSize: 50)
        bindChatIfCan()
    }
    
    func bindChatIfCan() {
        guard case .exist(let chat) = state else { return }
        appController.network?.messages(chat: chat).take(during: lifetime).startWithValues { [weak self] message in
            self?.addTextMessage(message.text, isIncoming: message.isIncoming)
        }
    }
    
    func sendMessage(_ message: MessageModelProtocol) {
        //        self.fakeMessageStatus(message)
    }
    
    func send(text: String) {
        switch state {
        case .new(let users):
            guard let chat = appController.network?.addChat(forUsers: users, firstMessageText: text) else { break }
            state = .exist(chat)
            bindChatIfCan()
        case .exist(let chat):
            appController.network?.sendMessage(chat: chat, messageText: text)
        }
    }
    
    fileprivate func addTextMessage(_ text: String, isIncoming: Bool) {
        let uid = "\(self.nextMessageId)"
        self.nextMessageId += 1
        let message = createTextMessageModel(uid, text: text, isIncoming: isIncoming)
        self.slidingWindow.insertItem(message, position: .bottom)
        self.delegate?.chatDataSourceDidUpdate(self)
    }
}

extension ChatViewModel: ChatDataSourceProtocol {
    var hasMoreNext: Bool {
        return self.slidingWindow.hasMore()
    }
    
    var hasMorePrevious: Bool {
        return self.slidingWindow.hasPrevious()
    }
    
    var chatItems: [ChatItemProtocol] {
        return self.slidingWindow.itemsInWindow
    }
    
    func loadNext() {
        self.slidingWindow.loadNext()
        self.slidingWindow.adjustWindow(focusPosition: 1, maxWindowSize: self.preferredMaxWindowSize)
        self.delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)
    }
    
    func loadPrevious() {
        self.slidingWindow.loadPrevious()
        self.slidingWindow.adjustWindow(focusPosition: 0, maxWindowSize: self.preferredMaxWindowSize)
        self.delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)
    }
    
    func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion: (_ didAdjust: Bool) -> Void) {
        let didAdjust = self.slidingWindow.adjustWindow(focusPosition: focusPosition, maxWindowSize: preferredMaxCount ?? self.preferredMaxWindowSize)
        completion(didAdjust)
    }
}
