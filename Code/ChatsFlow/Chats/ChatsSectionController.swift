//
//  ChatsSectionController.swift
//  Mssngr
//
//  Created by Slava Bulgakov on 13/01/2018.
//  Copyright © 2018 Slava Bulgakov. All rights reserved.
//

import IGListKit

class ChatsSectionController: ListSectionController {
    var cellViewModel: ChatsCellViewModel?
    let chatsViewModel: ChatsViewModel?

    init(viewModel: ChatsViewModel?) {
        self.chatsViewModel = viewModel
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext?.containerSize.width ?? 100, height: 55)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cxt = collectionContext,
            let cell = cxt.dequeueReusableCell(withNibName: "LabelCell", bundle: nil, for: self, at: index) as? LabelCell,
            let viewModel = cellViewModel else {
                let cell = UICollectionViewCell()
                cell.backgroundColor = UIColor.red
                return cell
        }
        cell.set(viewModel: viewModel)
        return cell
    }

    override func didUpdate(to object: Any) {
        cellViewModel = object as? ChatsCellViewModel
    }

    override func didSelectItem(at index: Int) {
        chatsViewModel?.select(index: index)
    }
}
