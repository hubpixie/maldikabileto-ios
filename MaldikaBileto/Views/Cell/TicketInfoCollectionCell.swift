//
//  TicketInfoCollectionCell.swift
//  Commoney
//
//  Created by venus.janne on 2018/07/21.
//  Copyright © 2018 x.yang. All rights reserved.
//

import UIKit

class TicketInfoCollectionCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var expiryDateLabel: UILabel!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!

    var segueId: CmySegueIds!
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        let screenWidth = UIScreen.main.bounds.size.width
        widthConstraint.constant = screenWidth - 24
    }

}
