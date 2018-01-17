//
//  KeyboardListener.swift
//  Mssngr
//
//  Created by Slava Bulgakov on 17/01/2018.
//  Copyright © 2018 Slava Bulgakov. All rights reserved.
//

import UIKit

class KeyboardListener {
    var scrollView: UIScrollView?
    var parentView: UIView?

    func setup(scrollView: UIScrollView, parentView: UIView) {
        self.scrollView = scrollView
        self.parentView = parentView
    }

    func beginListening() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }

    func endListening() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func adjustForKeyboard(notification: Notification) {
        guard let notNilScrollView = scrollView, let view = parentView,
            let keyboardFrameEnd = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardFrameEnd.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == Notification.Name.UIKeyboardWillHide {
            notNilScrollView.contentInset = UIEdgeInsets.zero
        } else {
            notNilScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }

        notNilScrollView.scrollIndicatorInsets = notNilScrollView.contentInset
    }
}
