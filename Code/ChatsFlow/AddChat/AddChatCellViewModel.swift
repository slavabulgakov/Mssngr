//
//  AddChatCellViewModel.swift
//  Mssngr
//
//  Created by Slava Bulgakov on 24/12/2017.
//  Copyright © 2017 Slava Bulgakov. All rights reserved.
//

import Foundation

class AddChatCellViewModel: Equatable {
    let user: User
    
    init(user: User) {
        self.user = user
    }
    
    var title: String {
        return user.email ?? ""
    }
    
    static func ==(lhs: AddChatCellViewModel, rhs: AddChatCellViewModel) -> Bool {
        return lhs.user == rhs.user
    }
}
