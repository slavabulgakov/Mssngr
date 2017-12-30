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
    fileprivate var disposable: ScopedDisposable<AnyDisposable>?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.obscuresBackgroundDuringPresentation = false
        let searchBar = searchController.searchBar
        searchBar.placeholder = "Emails"
        searchBar.autocapitalizationType = .none
        searchBar.keyboardType = .emailAddress
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    fileprivate func bindViewModel() {
        let composite = CompositeDisposable()
        defer {
            disposable = ScopedDisposable(composite)
        }
        composite += viewModel?.reloadSignal.take(during: reactive.lifetime).observeValues { [weak self] in
            self?.tableView.reloadData()
        }
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
    }
}

extension UITableViewCell {
    func set(viewModel: AddChatCellViewModel) {
        textLabel?.text = viewModel.title
    }
}
