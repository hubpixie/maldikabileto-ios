//
//  CmyTextFileldDatePicker.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/06.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import Foundation

@objc protocol CmyTextFieldDatePickerDelegate {
    @objc optional func datePicker(datePicker: CmyTextFieldDatePicker, done: Bool)
}

class CmyTextFieldDatePicker: UITextField {
    var datePicker: UIDatePicker = UIDatePicker()
    var pickerDelegate: CmyTextFieldDatePickerDelegate?
    private var originText: String?
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) || action == #selector(UIResponderStandardEditActions.copy(_:)) || action == #selector(UIResponderStandardEditActions.select(_:)) || action == #selector(UIResponderStandardEditActions.selectAll(_:)){
            return false
        }
        
        return super.canPerformAction(action, withSender: sender)
    }

    func setupDatePicker(parentView: UIView) {
        // ピッカー設定
        datePicker.datePickerMode = .date
        
        ////
        //datePicker.maximumDate =  Date()
        ///
        
        datePicker.timeZone = NSTimeZone.local
        datePicker.locale = Locale.current
        // 決定バーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: parentView.frame.size.width, height: 35))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        toolbar.setItems([cancelItem, spacelItem, doneItem], animated: true)
        
        // インプットビュー設定
        self.textColor = UIColor.cmyTextColor()
        self.tintColor = UIColor.white
        self.inputView = datePicker
        self.inputAccessoryView = toolbar
        
        self.delegate = self
        
    }
    
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.cmyBottomBorderColor().cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }

    // 決定ボタン押下
    @objc func doneTapped() {
        self.endEditing(true)
        
        // 日付のフォーマット
        self.text = self.datePicker.date.toLongDateString()
        self.originText = self.text
        
        self.pickerDelegate?.datePicker!(datePicker: self, done: true)
    }
    // キャンセルボタン押下
    @objc func cancelTapped() {
        self.endEditing(true)
        
        self.text = self.originText
        self.pickerDelegate?.datePicker!(datePicker: self, done: false)
    }
}

extension CmyTextFieldDatePicker: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.originText = textField.text
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}

