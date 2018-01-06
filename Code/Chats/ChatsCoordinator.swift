//
//  ChatsCoordinator.swift
//  Message
//
//  Created by Slava Bulgakov on 14/05/2017.
//  Copyright © 2017 Slava Bulgakov. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import CocoaLumberjack

class ChatsCoordinator: Coordinator {
    let viewController: ChatsViewController
    var appController: AppController
    
    var chatOpeningMode: ChatViewModel.ChatOpeningMode?
    

    fileprivate let token: Lifetime.Token
    fileprivate let lifetime: Lifetime

    init(viewController: ChatsViewController, appController: AppController) {
        self.viewController = viewController
        self.appController = appController
        token = Lifetime.Token()
        lifetime = Lifetime(token)
    }

    func start() {
        let viewModel = ChatsViewModel(appController: appController)
        viewController.viewModel = viewModel
        viewController.coordinationDelegate = self
        viewController.viewDidLoadSignal.flatMap(.latest) { [weak self] () -> SignalProducer<Void, NoError> in
            self?.appController.load()
            return self?.appController.network?.user.producer.skip(first: 1).filter({ $0 == nil }).map({ _ in return () }) ?? SignalProducer.empty
            }.take(during: lifetime).observeValues { [weak self] _ in
                self?.viewController.performSegue(withIdentifier: "ChatsToSignIn", sender: nil)
        }
        
        viewModel.chatSelectSignal.take(during: lifetime).observeValues { [weak self] chat in
            self?.chatOpeningMode = .openExistChat(chat)
            self?.viewController.performSegue(withIdentifier: "ChatsToChat", sender: nil)
        }
    }
    
    func createChat(viewController: AddChatViewController) {
        let viewModel = AddChatViewModel(appController: appController)
        viewController.viewModel = viewModel
        viewController.coordinationDelegate = self
        viewModel.users.producer.take(during: lifetime).startWithValues { [weak self] users in
            self?.chatOpeningMode = .createNewChat(users)
        }
    }
    
    func openChat(viewController: ChatViewController) {
        guard let chatMode = chatOpeningMode else { return }
        let viewModel = ChatViewModel(appController: appController, state: chatMode)
        viewController.viewModel = viewModel
        viewController.coordinationDelegate = self
        viewController.viewDidLoadSignal.take(during: lifetime).observeValues { [weak self] in
            guard let viewControllers = self?.viewController.navigationController?.viewControllers,
                viewControllers[viewControllers.count - 2] is AddChatViewController else { return }
            self?.viewController.navigationController?.viewControllers.remove(at: viewControllers.count - 2)
        }
    }
}

extension ChatsCoordinator: CoordinationDelegate {
    func prepareForSegue(segue: UIStoryboardSegue) {
        var coordinator: Coordinator?
        var destination: UIViewController? = segue.destination
        if let d = destination as? UINavigationController {
            destination = d.topViewController
        }
        switch destination {
        case let controller as SignInViewController:
            coordinator = SignInCoordinator(viewController: controller, appController: appController)
        case let controller as AddChatViewController:
            createChat(viewController: controller)
        case let controller as ChatViewController:
            openChat(viewController: controller)
        default:
            break
        }
        coordinator?.start()
    }
}
