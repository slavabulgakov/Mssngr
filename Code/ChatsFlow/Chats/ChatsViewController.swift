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
import IGListKit

class ChatsViewController: UIViewController, Coordinated {
    var viewModel: ChatsViewModel?
    var coordinationDelegate: CoordinationDelegate?
    let (viewDidLoadSignal, viewDidLoadObserver) = Signal<Void, NoError>.pipe()
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        adapter.collectionView = collectionView
        adapter.dataSource = self
        viewDidLoadObserver.send(value: ())
        viewModel?.updateChatsProducer()?.take(during: reactive.lifetime).startWithValues { [weak self] in
            self?.adapter.performUpdates(animated: true)
        }
    }
}

extension ChatsViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return viewModel?.items() ?? []
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return ChatsSectionController(viewModel: viewModel)
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}
