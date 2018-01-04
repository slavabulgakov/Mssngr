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
        appController.network?.messages(chat: chat).take(during: lifetime).startWithValues { [unowned self] message in
            guard !self.updateMessageStatusIfCan(message: message) else { return }
            self.addTextMessage(message: message)
        }
    }
    
    func sendMessage(_ message: MessageModelProtocol) {
        
    }
    
    var sendingMessageModels = [String: DemoTextMessageModel]()
    
    func send(text: String) {
        var message: Message?
        switch state {
        case .new(let users):
            guard let chat = appController.network?.addChat(forUsers: users, firstMessageText: text) else { break }
            state = .exist(chat)
            bindChatIfCan()
            message = chat.messages.first
        case .exist(let chat):
            message = appController.network?.sendMessage(chat: chat, messageText: text)
        }
        guard let notNilMessage = message else { return }
        addTextMessage(message: notNilMessage, isJustSent: true)
    }
    
    fileprivate func updateMessageStatusIfCan(message: Message) -> Bool {
        guard let model = self.sendingMessageModels[message.id] else { return false }
        model.status = .success
        sendingMessageModels.removeValue(forKey: model.uid)
        self.delegate?.chatDataSourceDidUpdate(self)
        return true
    }
    
    fileprivate func addTextMessage(message: Message, isJustSent: Bool = false) {
        defer { self.delegate?.chatDataSourceDidUpdate(self) }
        let messageModel = createTextMessageModel(message.id, text: message.text, isIncoming: message.isIncoming)
        self.slidingWindow.insertItem(messageModel, position: .bottom)
        guard isJustSent else { return }
        messageModel.status = .sending
        sendingMessageModels[message.id] = messageModel
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
