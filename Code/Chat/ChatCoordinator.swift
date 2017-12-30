//
//  ChatCoordinator.swift
//  Mssngr
//
//  Created by Slava Bulgakov on 28/12/2017.
//  Copyright © 2017 Slava Bulgakov. All rights reserved.
//

import UIKit
import ReactiveSwift

class ChatCoordinator: Coordinator {
    var appController: AppController
    let viewController: ChatViewController
    let state: ChatViewModel.State
    fileprivate let token: Lifetime.Token
    fileprivate let lifetime: Lifetime
    
    init(viewController: ChatViewController, appController: AppController, state: ChatViewModel.State) {
        self.viewController = viewController
        self.appController = appController
        self.state = state
        token = Lifetime.Token()
        lifetime = Lifetime(token)
    }
    
    func start() {
        let viewModel = ChatViewModel(appController: appController, state: state)
        viewController.viewModel = viewModel
        viewController.coordinationDelegate = self
        viewController.viewDidLoadSignal.take(during: lifetime).observeValues { [weak self] in
            guard let viewControllers = self?.viewController.navigationController?.viewControllers,
            viewControllers[viewControllers.count - 2] is AddChatViewController else { return }
            self?.viewController.navigationController?.viewControllers.remove(at: viewControllers.count - 2)
        }
    }
}

extension ChatCoordinator: CoordinationDelegate {
    func prepareForSegue(segue: UIStoryboardSegue) {
        
    }
}
