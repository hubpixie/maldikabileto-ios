//
//  TicketInfoCell.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/30.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class TicketInfoCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var expiryDateLabel: UILabel!
    @IBOutlet weak var paymentDateLabel: UILabel!
    @IBOutlet private weak var statusImageView: UIImageView!

    private static let _statusImageNames: [String] = ["ico_unused_ticket_black", "ico_used_ticket_black", "ico_erred_ticket_red", "ico_expired_black"]
    
    static let expiredIndex: Int = 3
    
    var segueId: CmySegueIds!
    var statusImageIndex: Int = -1 {
        didSet {
            if self.statusImageIndex == -1 {return}
            let imgName: String = TicketInfoCell._statusImageNames[self.statusImageIndex]
            self.statusImageView.image = UIImage(named: imgName)
        }
    }

    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
