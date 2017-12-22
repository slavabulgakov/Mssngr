//
//  NetworkController.swift
//  Mssngr
//
//  Created by Slava Bulgakov on 19/12/2017.
//  Copyright © 2017 Slava Bulgakov. All rights reserved.
//

import Foundation
import FirebaseAuth
import ReactiveSwift
import ReactiveCocoa
import Result

class User {}

class NetworkController {
    lazy var user: Property<User?> = {
        let producer = SignalProducer<User?, NoError> { observer, _ in
            Auth.auth().addStateDidChangeListener { auth, user in
                observer.send(value: user == nil ? nil : User())
            }
        }
        return Property(initial: nil, then: producer)
    }()
}
