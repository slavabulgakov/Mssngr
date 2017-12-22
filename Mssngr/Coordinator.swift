//
//  Coordinator.swift
//  Message
//
//  Created by Slava Bulgakov on 13/05/2017.
//  Copyright © 2017 Slava Bulgakov. All rights reserved.
//

import UIKit

protocol Coordinator: class {
    var appController: AppController { get set }
    func start()
}

protocol CoordinationDelegate {
    func prepareForSegue(segue: UIStoryboardSegue)
}

protocol Coordinated {
    var coordinationDelegate: CoordinationDelegate? { get set }
}
