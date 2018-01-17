//
//  AppDelegate.swift
//  Mssngr
//
//  Created by Slava Bulgakov on 04/12/2017.
//  Copyright © 2017 Slava Bulgakov. All rights reserved.
//

import UIKit
import Firebase
import CocoaLumberjack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var appCoordinator: AppCoordinator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        guard let notNilWindow = window else { return true }
        FirebaseApp.configure()
        defaultDebugLevel = .info
        DDLog.add(DDTTYLogger.sharedInstance)

        appCoordinator = AppCoordinator(window: notNilWindow)
        appCoordinator.start()
        return true
    }
}

