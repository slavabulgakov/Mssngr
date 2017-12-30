//
//  AddChatViewModel.swift
//  Mssngr
//
//  Created by Slava Bulgakov on 24/12/2017.
//  Copyright © 2017 Slava Bulgakov. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

class AddChatViewModel {
    let appController: AppController
    fileprivate var _cells = [AddChatCellViewModel]()
    fileprivate let reloadObserver: Signal<Void, NoError>.Observer
    let reloadSignal: Signal<Void, NoError>
    var users = Set<User>()
    
    init(appController: AppController) {
        self.appController = appController
        (reloadSignal, reloadObserver) = Signal<Void, NoError>.pipe()
    }
    
    func searchUsers(byEmail email: String) {
        appController.network?.searchUsers(byEmail: email) { [weak self] users in
            self?._cells = users.map { AddChatCellViewModel(user: $0) }
            self?.reloadObserver.send(value: ())
        }
    }
    
    var numberOfRows: Int {
        return _cells.count
    }
    
    func item(atIndex index: Int) -> AddChatCellViewModel {
        return _cells[index]
    }
    
    func select(index: Int) {
        users.insert(_cells[index].user)
    }
}
