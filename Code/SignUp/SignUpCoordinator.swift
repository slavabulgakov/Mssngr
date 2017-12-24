//
//  SignUpCoordinator.swift
//  Mssngr
//
//  Created by Slava Bulgakov on 22/12/2017.
//  Copyright © 2017 Slava Bulgakov. All rights reserved.
//

import UIKit

class SignUpCoordinator: Coordinator {
    let viewController: SignUpViewController
    var appController: AppController
    
    init(viewController: SignUpViewController, appController: AppController) {
        self.viewController = viewController
        self.appController = appController
    }
    
    func start() {
        let viewModel = SignUpViewModel(appController: appController)
        viewController.viewModel = viewModel
        viewController.coordinationDelegate = self
    }
}

extension SignUpCoordinator: CoordinationDelegate {
    func prepareForSegue(segue: UIStoryboardSegue) {
        
    }
}
