//
//  ChatsCellViewModel.swift
//  Message
//
//  Created by Slava Bulgakov on 25/03/2017.
//  Copyright © 2017 Slava Bulgakov. All rights reserved.
//

import Foundation

class ChatsCellViewModel: Equatable {
    static func ==(lhs: ChatsCellViewModel, rhs: ChatsCellViewModel) -> Bool {
        return lhs.chat == rhs.chat
    }
    
    let chat: Chat

    init(chat: Chat) {
        self.chat = chat
    }

    var title: String {
        return Array(chat.users ?? Set()).joined(separator: ", ")
    }
}
