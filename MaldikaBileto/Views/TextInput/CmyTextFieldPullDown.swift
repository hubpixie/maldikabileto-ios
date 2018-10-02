//
//  CmyTextFieldPullDown.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/10.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

@objc protocol CmyTextFieldPullDownDelegate {
    @objc optional func pulldown(pulldown: CmyTextFieldPullDown, done: Bool)
}

class CmyTextFieldPullDown: UITextField {
    var pickerDelegate: CmyTextFieldPullDownDelegate?
    
    weak var parentView: UIView!
    var pulldown: UITableView!
    var list: [String] = []
    var selectedIndex: Int?
    private var originText: String?
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) || action == #selector(UIResponderStandardEditActions.copy(_:)) || action == #selector(UIResponderStandardEditActions.select(_:)) || action == #selector(UIResponderStandardEditActions.selectAll(_:)){
            return false
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
    
    func setupPulldown(parentView: UIView) {
        self.parentView = parentView
        
        // インプットビュー設定
        self.textColor = UIColor.cmyTextColor()
        self.tintColor = UIColor.white
        
        //set arrow icon for rightview of textfield
        if let img = UIImage(named: "ico_down_arrow")  {
            self.rightView = UIImageView(image: img)
        }
        self.rightView?.contentMode = .scaleAspectFit
        self.rightView?.clipsToBounds = true
        self.rightViewMode = .always

        // set pulldown view
        self.pulldown = UITableView(frame: CGRect(x: self.frame.origin.x + 2,
                                                  y: self.frame.origin.y + self.frame.size.height + 2,
                                                  width: self.frame.size.width - 2, height: 160))
        self.pulldown.separatorStyle = .none
        self.pulldown.isHidden = true
        
        //border attributes
        self.pulldown.layer.masksToBounds = false
        self.pulldown.layer.cornerRadius = 5.0
        self.pulldown.layer.shadowColor = UIColor.black.cgColor
        self.pulldown.layer.shadowOffset = .zero
        self.pulldown.layer.shadowOpacity = 0.3
        self.pulldown.layer.shadowRadius = 5.0

        self.parentView.addSubview(self.pulldown)
        
        // AutoLayout対応
        self._fitAutoLayout()

        //set cells and data
        self.pulldown.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.pulldown.dataSource = self
        self.pulldown.delegate = self
        
        // Manage tableView visibility via TouchDown in textField
        self.delegate = self
        self.addTarget(self, action: #selector(textFieldActive), for: UIControlEvents.touchDown)

        //self.pulldown.backgroundColor = UIColor.groupTableViewBackground
        self.pulldown.reloadData()
    }
    
    // AutoLayout対応
    //
    private func _fitAutoLayout() {
        self.pulldown.translatesAutoresizingMaskIntoConstraints = false
        self.parentView.addConstraint(NSLayoutConstraint(item: self.pulldown,
                                                              attribute: .top,
                                                              relatedBy: .equal,
                                                              toItem: self,
                                                              attribute: .bottom,
                                                              multiplier: 1.0,
                                                              constant: 2))
        self.parentView.addConstraint(NSLayoutConstraint(item: self.pulldown,
                                                              attribute: .leading,
                                                              relatedBy: .equal,
                                                              toItem: self,
                                                              attribute: .leading,
                                                              multiplier: 1.0,
                                                              constant: 2))
        self.parentView.addConstraint(NSLayoutConstraint(item: self.pulldown,
                                                              attribute: .trailing,
                                                              relatedBy: .equal,
                                                              toItem: self,
                                                              attribute: .trailing,
                                                              multiplier: 1.0,
                                                              constant: 2))
        self.parentView.addConstraint(NSLayoutConstraint(item: self.pulldown,
                                                              attribute: .height,
                                                              relatedBy: .equal,
                                                              toItem: nil,
                                                              attribute: .notAnAttribute,
                                                              multiplier: 1.0,
                                                              constant: 160))
    }

    // set bottom border style
    //
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.cmyBottomBorderColor().cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}

// MARK: UITextFieldDelegate

extension CmyTextFieldPullDown: UITextFieldDelegate {
    // Toggle the tableView visibility when click on textField
    @objc func textFieldActive() {
       self.pulldown.isHidden = !self.pulldown.isHidden
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        // TODO: Your app can do something when textField finishes editing
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}

// MARK: UITableViewDataSource

extension CmyTextFieldPullDown: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell")
        // Set text from the data model
        cell?.textLabel?.textAlignment = .center
        cell?.textLabel?.text = list[indexPath.row]
        cell?.textLabel?.font = self.font
        return cell!
    
    }
}

extension CmyTextFieldPullDown: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Row selected, so set textField to relevant value, hide tableView
        // endEditing can trigger some other action according to requirements
        self.text = list[indexPath.row]
        self.selectedIndex = indexPath.row
        tableView.isHidden = true
        self.endEditing(true)
        self.pickerDelegate?.pulldown!(pulldown: self, done: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 38
    }
}
