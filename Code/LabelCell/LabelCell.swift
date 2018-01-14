//
//  ChatsCell.swift
//  Mssngr
//
//  Created by Slava Bulgakov on 13/01/2018.
//  Copyright © 2018 Slava Bulgakov. All rights reserved.
//

import UIKit

protocol LabelCellViewModel {
    var text: String { get }
}

class LabelCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!

    func set(viewModel: LabelCellViewModel) {
        label.text = viewModel.text
    }
}
