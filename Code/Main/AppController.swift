//
//  AppController.swift
//  Message
//
//  Created by Slava Bulgakov on 12/03/2017.
//  Copyright © 2017 Slava Bulgakov. All rights reserved.
//

import Foundation

class AppController {
    var network: NetworkController?

    func load() {
        network = NetworkController(service: Service())
    }
}
