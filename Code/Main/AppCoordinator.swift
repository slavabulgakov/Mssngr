//
//  AppCoordinator.swift
//  Mssngr
//
//  Created by Slava Bulgakov on 05/12/2017.
//  Copyright © 2017 Slava Bulgakov. All rights reserved.
//

import UIKit

class AppCoordinator: Coordinator
{
    var appController: AppController
    
    var window: UIWindow
    var chatsCoordinator: ChatsCoordinator?
    
    init(window: UIWindow) {
        self.window = window
        UIViewController.addCoordination()
        appController = AppController()
    }
    
    func start() {
        guard let chatsViewController = self.window.rootViewController as? ChatsViewController else { return }
        chatsCoordinator = ChatsCoordinator(chatsViewController: chatsViewController, appController: appController)
        chatsCoordinator?.start()
    }
}

extension UIViewController {
    
    class func addCoordination() {
        DispatchQueue.once(token: "com.mvvmcs.Mssngr") {
            let originalPerformSelector = #selector(UIViewController.prepare(for: sender:))
            let swizzledPerformSelector = #selector(swizzledPrepare(for: sender:))
            
            method_exchangeImplementations(class_getInstanceMethod(UIViewController.self, originalPerformSelector)!,
                                           class_getInstanceMethod(UIViewController.self, swizzledPerformSelector)!)
        }
    }
    
    @objc func swizzledPrepare(for segue: UIStoryboardSegue, sender: Any?) {
        defer {
            self.swizzledPrepare(for: segue, sender: self)
        }
        
        guard let sourceViewController = segue.source as? Coordinated else {
            return
        }
        
        sourceViewController.coordinationDelegate?.prepareForSegue(segue: segue)
        
    }
}

public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block: () -> Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
}
