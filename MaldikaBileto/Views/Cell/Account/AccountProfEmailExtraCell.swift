//
//  AccountProfEmailExtraCell.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/21.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit
protocol AccountEditEmailDelegate: class {
    func resendEmailVerification(cell: AccountProfEmailExtraCell)
    func emailWillChange(cell: AccountProfEmailExtraCell)
}

class AccountProfEmailExtraCell: UITableViewCell {

    @IBOutlet weak var itemValueLabel: UILabel!
    @IBOutlet private weak var itemNameLabel: UILabel!
    @IBOutlet private weak var remarkLabel: UILabel!
    @IBOutlet private weak var resendEmailVerificationButton: UIButton!

    private static let kCellWidth: CGFloat = UIScreen.main.bounds.size.width - 110 - 16 * 2 - 90
    private static let kCellPadding: CGFloat = 0
    private static let kCellHeightMax: CGFloat = 45
    private static let kCellHeightForVerification: CGFloat = 50
    
    weak var delegate: AccountEditEmailDelegate?
    var emailVerified: Bool = false {
        didSet {
            self.resendEmailVerificationButton.isHidden = emailVerified
            self.remarkLabel.isHidden = emailVerified
        }
    }
    var itemValue: String?  {
        didSet {
            guard let v = itemValue else {return}
            
            // judge the text size of ItemValue
            let size: CGSize = v.getTextSize(font: self.itemValueLabel.font, viewWidth: self.itemValueLabel.frame.width, padding: 0)
            
            // adjust text size of ItemValue
            let frame = self.itemValueLabel.frame
            self.itemValueLabel.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: size.height)
            self.itemValueLabel.text = v
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
        //self.itemValueLabel.adjustsFontSizeToFitWidth = true
        self.resendEmailVerificationButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let lastButton = self.subviews.reversed().lazy.flatMap({ $0 as? UIButton }).first {
            // This subview should be the accessory view, change its origin
            lastButton.frame.origin.y = 15
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Manage cell view when touching
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let touch:UITouch = touches.first else
        {
            return;
        }
        let y: CGFloat = self.itemValueLabel.frame.origin.y + self.itemValueLabel.frame.height + 5
        if y >= touch.location(in: touch.view).y
        {
            self.emailChangeAction(touch.view)
        }
    }
    

    @IBAction func resendEmailVerificationButtonDidTap(_ sender: UIButton) {
        self.delegate?.resendEmailVerification(cell: self)
    }
    
    func emailChangeAction(_ sender: Any?) {
        self.delegate?.emailWillChange(cell: self)
    }
    
    static func calcContentsHeight(contentString: String, emailVerified: Bool) -> CGFloat {
        let size = contentString.getTextSize(font: UIFont.systemFont(ofSize: 15.0), viewWidth: AccountProfEmailExtraCell.kCellWidth, padding: AccountProfEmailExtraCell.kCellPadding)
        return (size.height < AccountProfEmailExtraCell.kCellHeightMax ?  AccountProfEmailExtraCell.kCellHeightMax : size.height) + (!emailVerified ? AccountProfEmailExtraCell.kCellHeightForVerification : 0)
    }

}
