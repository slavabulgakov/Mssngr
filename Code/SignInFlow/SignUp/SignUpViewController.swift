//
//  SignUpViewController.swift
//  Mssngr
//
//  Created by Slava Bulgakov on 22/12/2017.
//  Copyright © 2017 Slava Bulgakov. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, Coordinated {
    var viewModel: SignUpViewModel?
    var coordinationDelegate: CoordinationDelegate?
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func signUpButtonTap(_ sender: UIButton) {
        guard let email = emailField.text, let password = passwordField.text else { return }
        viewModel?.signUp(email: email, password: password)
    }
}
