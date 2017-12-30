//
//  ChatViewController.swift
//  Mssngr
//
//  Created by Slava Bulgakov on 28/12/2017.
//  Copyright © 2017 Slava Bulgakov. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

class ChatViewController: UIViewController, Coordinated {
    var coordinationDelegate: CoordinationDelegate?
    var viewModel: ChatViewModel?
    let (viewDidLoadSignal, viewDidLoadObserver) = Signal<Void, NoError>.pipe()
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadObserver.send(value: ())
        viewModel?.textSignal.take(during: reactive.lifetime).observeValues { [weak self] in
            self?.textView.text = self?.viewModel?.text ?? ""
        }
    }

    @IBAction func sendMessage(_ sender: UIButton) {
        viewModel?.sendMessage(text: "slava")
    }
}
