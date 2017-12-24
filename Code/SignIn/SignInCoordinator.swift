//
//  SignInCoordinator.swift
//  Mssngr
//
//  Created by Slava Bulgakov on 22/12/2017.
//  Copyright © 2017 Slava Bulgakov. All rights reserved.
//

import UIKit

class SignInCoordinator: Coordinator {
    let viewController: SignInViewController
    var appController: AppController
    
    init(viewController: SignInViewController, appController: AppController) {
        self.viewController = viewController
        self.appController = appController
    }
    
    func start() {
        let viewModel = SignInViewModel(appController: appController)
        viewController.viewModel = viewModel
        viewController.coordinationDelegate = self
    }
}

extension SignInCoordinator: CoordinationDelegate {
    func prepareForSegue(segue: UIStoryboardSegue) {
        guard let viewController = segue.destination as? SignUpViewController else { return }
        let coordinator = SignUpCoordinator(viewController: viewController, appController: appController)
        coordinator.start()
    }
}
