//
//  SignInViewModel.swift
//  Mssngr
//
//  Created by Slava Bulgakov on 22/12/2017.
//  Copyright © 2017 Slava Bulgakov. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

class SignInViewModel {
    let appController: AppController
    let signInStatusSignal: Signal<Void, NoError>?

    init(appController: AppController) {
        self.appController = appController
        signInStatusSignal = appController.network?.user.signal.skipNil().map({ _ in return () })
    }

    func signIn(email: String, password: String) {
        appController.network?.signIn(email: email, password: password)
    }
}
