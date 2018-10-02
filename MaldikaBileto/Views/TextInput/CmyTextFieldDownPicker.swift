//
//  CmyTextFieldDownPicker.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/06.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import Foundation

@objc protocol CmyTextFieldDownPickerDelegate {
    @objc optional func downPicker(downPicker: CmyTextFieldDownPicker, done: Bool)
}

class CmyTextFieldDownPicker: UITextField {
    var pickerDelegate: CmyTextFieldDownPickerDelegate?

    weak var parentView: UIView!
    var downPicker: UIPickerView = UIPickerView()
    var pickerList: [String] = []
    private var originText: String?

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) || action == #selector(UIResponderStandardEditActions.copy(_:)) || action == #selector(UIResponderStandardEditActions.select(_:)) || action == #selector(UIResponderStandardEditActions.selectAll(_:)){
            return false
        }
        
        return super.canPerformAction(action, withSender: sender)
    }

    func setupDownPicker(parentView: UIView) {
        self.parentView = parentView

        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: parentView.frame.size.width, height: 35))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        toolbar.setItems([cancelItem, spacelItem, doneItem], animated: true)
        
        // インプットビュー設定
        self.tintColor = UIColor.white
        self.inputView = self.downPicker
        self.inputAccessoryView = toolbar
        

        //delegate
        self.delegate = self
        self.downPicker.dataSource = self
        self.downPicker.delegate = self
        
        self.downPicker.showsSelectionIndicator = true
        
        self.downPicker.backgroundColor = UIColor.groupTableViewBackground
        
    }
    
    // キャンセルボタン押下
    @objc func cancelTapped() {
        self.endEditing(true)
        
        self.text = self.originText
        
        self.pickerDelegate?.downPicker!(downPicker: self, done: false)

    }
    // 完了ボタン押下
    @objc func doneTapped() {
        self.endEditing(true)
        
        if self.text == nil || (self.text?.count)! < 1 {
            self.text = self.pickerList[0]
        }
        self.pickerDelegate?.downPicker!(downPicker: self, done: true)
    }

}

extension CmyTextFieldDownPicker: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let text = self.text, self.pickerList.count > 0 {
            if let idx = self.pickerList.index(of: text) {
                self.downPicker.selectedRow(inComponent: idx)
            }
            return true
        }
        return false
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.originText = textField.text
    }
}

extension CmyTextFieldDownPicker: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerList[row]
    }

    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.text = self.pickerList[row]
        
    }
}

extension CmyTextFieldDownPicker: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerList.count
    }
}
