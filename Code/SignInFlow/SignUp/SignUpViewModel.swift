//
//  SignUpViewModel.swift
//  Mssngr
//
//  Created by Slava Bulgakov on 22/12/2017.
//  Copyright © 2017 Slava Bulgakov. All rights reserved.
//

import Foundation

class SignUpViewModel {
    let appController: AppController
    
    init(appController: AppController) {
        self.appController = appController
    }
    
    func signUp(email: String, password: String) {
        appController.network?.signUp(email: email, password: password)
    }
}
