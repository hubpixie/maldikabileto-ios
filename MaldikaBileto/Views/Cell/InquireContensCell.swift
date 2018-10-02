//
//  InquireContensCell.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/15.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class InquireContensCell: UITableViewCell {
    
    @IBOutlet weak var contentsLabel: UILabel?
    static let kCellPadding: CGFloat = 0
    static let kCellWidth: CGFloat = UIScreen.main.bounds.size.width - 70

    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static func calcContentsHeight(contentString: String) -> CGFloat {
        let size = contentString.getTextSize(font: UIFont.systemFont(ofSize: 15.0), viewWidth: kCellWidth, padding: kCellPadding)
        return size.height + 10
    }

}
