//
//  ChatsCellViewModel.swift
//  Message
//
//  Created by Slava Bulgakov on 25/03/2017.
//  Copyright © 2017 Slava Bulgakov. All rights reserved.
//

import IGListKit

class ChatsCellViewModel: Equatable {
    static func == (lhs: ChatsCellViewModel, rhs: ChatsCellViewModel) -> Bool {
        return lhs.chat == rhs.chat
    }

    let chat: Chat

    init(chat: Chat) {
        self.chat = chat
    }

    var title: String {
        return Array(chat.users).map({ $0.id }).joined(separator: ", ")
    }
}

extension ChatsCellViewModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return chat.id as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let cell = object as? ChatsCellViewModel {
            return chat == cell.chat
        }
        return false
    }
}

extension ChatsCellViewModel: LabelCellViewModel {
    var text: String {
        return title
    }
}
