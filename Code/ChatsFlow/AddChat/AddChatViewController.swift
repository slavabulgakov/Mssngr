//
//  AddChatViewController.swift
//  Mssngr
//
//  Created by Slava Bulgakov on 24/12/2017.
//  Copyright © 2017 Slava Bulgakov. All rights reserved.
//

import UIKit
import ReactiveSwift

class AddChatViewController: UIViewController, Coordinated {
    let cellIdentifier = "AddChatCellIdentifier"
    var coordinationDelegate: CoordinationDelegate?
    var viewModel: AddChatViewModel?
    let searchController = UISearchController(searchResultsController: nil)
    let keyboardListener = KeyboardListener()
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.obscuresBackgroundDuringPresentation = false
        let searchBar = searchController.searchBar
        searchBar.placeholder = L10n.email
        searchBar.autocapitalizationType = .none
        searchBar.keyboardType = .emailAddress
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        addButtonOnToolbar()
        bindViewModel()
        keyboardListener.setup(scrollView: tableView, parentView: view)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
        keyboardListener.beginListening()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        keyboardListener.endListening()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
        searchController.isActive = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = true
    }

    fileprivate func bindViewModel() {
        viewModel?.reloadSignal.take(during: reactive.lifetime).observeValues { [weak self] in
            self?.tableView.reloadData()
        }
        viewModel?.users.producer.take(during: reactive.lifetime).startWithValues { [weak self] users in
            self?.navigationController?.setToolbarHidden(users.count == 0, animated: true)
        }
    }

    fileprivate func addButtonOnToolbar() {
        let buttons = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Go to chat >", style: .plain, target: self, action: #selector(goToChat)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        ]
        setToolbarItems(buttons, animated: false)
    }

    @objc fileprivate func goToChat() {
        performSegue(withIdentifier: "AddChatToChat", sender: nil)
    }
    
    
}

extension AddChatViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let email = searchController.searchBar.text, !email.isEmpty else { return }
        viewModel?.searchUsers(byEmail: email)
    }
}

extension AddChatViewController: UITableViewDelegate, UITableViewDataSource {
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.select(index: indexPath.row)
        searchController.searchBar.resignFirstResponder()
    }
}

extension UITableViewCell {
    func set(viewModel: AddChatCellViewModel) {
        textLabel?.text = viewModel.title
    }
}
