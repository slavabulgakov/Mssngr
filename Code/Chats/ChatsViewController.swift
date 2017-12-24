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

class ChatsViewController: UIViewController, Coordinated {
    let cellIdentifier = "ChatCellIdentifier"
    var viewModel: ChatsViewModel?
    var coordinationDelegate: CoordinationDelegate?
    let (viewDidLoadSignal, viewDidLoadObserver) = Signal<Void, NoError>.pipe()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadObserver.send(value: Void())
        bindViewModel()
    }
    
    func bindViewModel() {
        viewModel?.chatsProducer?.take(during: self.reactive.lifetime).startWithValues({ [weak self] chats in
            self?.tableView.reloadData()
        })
    }
    
    @IBAction func addChatTap(_ sender: UIButton) {
        viewModel?.addChat()
    }
}

extension ChatsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRows ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier), let viewModel = viewModel else {
            let cell = UITableViewCell()
            cell.backgroundColor = UIColor.red
            return cell
        }
        cell.set(viewModel: viewModel.item(atIndex: indexPath.row))
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        viewModel?.select(index: indexPath.row)
//    }
}

extension UITableViewCell {
    func set(viewModel: ChatsCellViewModel) {
        textLabel?.text = viewModel.title
    }
}
