//
//  ViewController.swift
//  Mssngr
//
//  Created by Slava Bulgakov on 04/12/2017.
//  Copyright © 2017 Slava Bulgakov. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

class ChatsViewController: UIViewController {
    var viewModel: ChatsViewModel?
    let (viewDidLoadSignal, viewDidLoadObserver) = Signal<Void, NoError>.pipe()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadObserver.send(value: Void())
    }
}

