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
    let chatsViewController: ChatsViewController
    var appController: AppController

    fileprivate let token: Lifetime.Token
    fileprivate let lifetime: Lifetime

    init(chatsViewController: ChatsViewController, appController: AppController) {
        self.chatsViewController = chatsViewController
        self.appController = appController
        token = Lifetime.Token()
        lifetime = Lifetime(token)
    }

    func start() {
        let viewModel = ChatsViewModel()
        chatsViewController.viewModel = viewModel
        chatsViewController.viewDidLoadSignal.flatMap(.latest) { [weak self] () -> SignalProducer<Void, NoError> in
            self?.appController.load()
            return self?.appController.network?.user.producer.skip(first: 1).filter({ $0 == nil }).map({ _ in return () }) ?? SignalProducer.empty
            }.take(during: lifetime).observeValues { [weak self] _ in
                self?.chatsViewController.performSegue(withIdentifier: "ChatsToSignIn", sender: nil)
        }
    }
}

extension ChatsCoordinator: CoordinationDelegate {
    func prepareForSegue(segue: UIStoryboardSegue) {
    }
}
