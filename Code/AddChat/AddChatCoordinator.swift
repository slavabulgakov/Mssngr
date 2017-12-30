//
//  AddChatCoordinator.swift
//  Mssngr
//
//  Created by Slava Bulgakov on 24/12/2017.
//  Copyright © 2017 Slava Bulgakov. All rights reserved.
//

import UIKit

class AddChatCoordinator: Coordinator {
    var appController: AppController
    let viewController: AddChatViewController
    var viewModel: AddChatViewModel?
    
    init(viewController: AddChatViewController, appController: AppController) {
        self.viewController = viewController
        self.appController = appController
    }
    
    func start() {
        let viewModel = AddChatViewModel(appController: appController)
        viewController.viewModel = viewModel
        viewController.coordinationDelegate = self
        self.viewModel = viewModel
    }
}

extension AddChatCoordinator: CoordinationDelegate {
    func prepareForSegue(segue: UIStoryboardSegue) {
        guard let viewController = segue.destination as? ChatViewController, let users = viewModel?.users else { return }
        let coordinator = ChatCoordinator(viewController: viewController, appController: appController, state: .new(users))
        coordinator.start()
    }
}
