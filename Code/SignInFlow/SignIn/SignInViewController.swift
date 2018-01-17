//
//  SignInViewController.swift
//  Mssngr
//
//  Created by Slava Bulgakov on 22/12/2017.
//  Copyright © 2017 Slava Bulgakov. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, Coordinated {
    var viewModel: SignInViewModel?
    var coordinationDelegate: CoordinationDelegate?
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.signInStatusSignal?.observeValues { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func signInButtonTap(_ sender: UIButton) {
        guard let email = email.text, let password = password.text else { return }
        viewModel?.signIn(email: email, password: password)
    }
}
