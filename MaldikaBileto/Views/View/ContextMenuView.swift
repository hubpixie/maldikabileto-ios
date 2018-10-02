//
//  ContextMenuView.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/23.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

@objc protocol ContextMenuViewDelegate {
    @objc optional func menuItem(menuItem: MenuItemCell)
}
class ContextMenuView: UITableView {
    private var _items: [String] = []
    var contentView: UIView = UIView(frame: UIScreen.main.bounds)
    var items: [String] {
        get {return _items}
    }
    var selectedRow: Int = 0
    
    var menuDelegate: ContextMenuViewDelegate?
    
    func setupContents(position: CGPoint, items: [String]) {
        
        // base attributes
        _items = items
        
        self.frame = CGRect(x: position.x, y: position.y, width: 160, height: CGFloat(45 * _items.count))
        self.tableFooterView = UIView()
        self.separatorStyle = .none
        self.isHidden = true
        
        //border attributes
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 5.0
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 5.0
        
        //set cells and data
        self.register(MenuItemCell.nib, forCellReuseIdentifier: MenuItemCell.identifier)
        self.delegate = self
        self.dataSource = self
        
        // content view
        self.contentView.backgroundColor = UIColor.clear
        self.contentView.addSubview(self)
    }
    
    func showMenu(showed: Bool) {
        self.isHidden = !showed
        self.contentView.isHidden = !showed
    }
}

extension ContextMenuView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuItemCell.identifier, for: indexPath) as! MenuItemCell
        cell.nameLabel.text = items[indexPath.row]
        cell.checkImageView.isHidden = true
        if self.selectedRow == indexPath.row {
            cell.checkImageView.isHidden = false
        }
        cell.selectionStyle = .none
        //cell.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
        return cell
    }
}

extension ContextMenuView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for cell  in tableView.visibleCells {
            if let vcell = cell as? MenuItemCell {
                vcell.checkImageView.isHidden = true
            }
        }
        self.selectedRow = indexPath.row
        if let menuDelegate = self.menuDelegate {
            let cell = tableView.cellForRow(at: indexPath) as! MenuItemCell
            cell.checkImageView.isHidden = false
            menuDelegate.menuItem!(menuItem: cell)
        }
    }
}
