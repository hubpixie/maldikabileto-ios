//
//  InquireHeaderView.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/15.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

protocol InquireHeaderViewDelegate: class {
    func toggleSection(headerView: InquireHeaderView, section: Int)
}

class InquireHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var createAtLabel: UILabel!
    @IBOutlet weak var arrowButton: UIButton!

    @IBOutlet private weak var bottomBorderView: UIView!
    var collapsed: Bool!
    
    var section: Int = 0
    
    weak var delegate: InquireHeaderViewDelegate?
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bottomBorderView.borderWidth = 1
        self.bottomBorderView.borderColor = UIColor(red: 244.0/255.0, green: 244.0/255.0, blue: 244.0/255.0, alpha: 1.0)
    }
    
    @IBAction func arrowButtondidTapHeader(_ sender: UIButton) {
        delegate?.toggleSection(headerView: self, section: section)
    }

    func setCollapsed(collapsed: Bool) {
        self.collapsed = collapsed
        arrowButton.rotate(collapsed ? 0.0 : .pi)
    }
    
}

