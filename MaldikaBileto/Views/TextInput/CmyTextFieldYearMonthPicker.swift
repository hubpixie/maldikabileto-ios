//
//  CmyTextFieldYearMonthPicker.swift
//  MaldikaBileto
//
//  Created by venus.janne on 2018/09/12.
//  Copyright © 2018 x.yang. All rights reserved.
//

import UIKit

@objc protocol CmyTextFieldYearMonthPickerDelegate {
    @objc optional func yearMonthPicker(yearMonthPicker: CmyTextFieldYearMonthPicker, done: Bool)
}

class CmyTextFieldYearMonthPicker: UITextField {
    var yearMonthPicker: YearMonthPickerView!
    var pickerDelegate: CmyTextFieldYearMonthPickerDelegate?
    private var originText: String?
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) || action == #selector(UIResponderStandardEditActions.copy(_:)) || action == #selector(UIResponderStandardEditActions.select(_:)) || action == #selector(UIResponderStandardEditActions.selectAll(_:)){
            return false
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
    
    func setupDatePicker(parentView: UIView, fromYear year: Int?) {
        
        ////
        //datePicker.maximumDate =  Date()
        ///
        yearMonthPicker = YearMonthPickerView()
        yearMonthPicker.timeZone = NSTimeZone.local
        yearMonthPicker.locale = Locale.current
        yearMonthPicker.minYear = year
        yearMonthPicker._setup()
        
        // 決定バーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: parentView.frame.size.width, height: 35))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        toolbar.setItems([cancelItem, spacelItem, doneItem], animated: true)
        
        // インプットビュー設定
        self.textColor = UIColor.cmyTextColor()
        self.tintColor = UIColor.white
        self.inputView = yearMonthPicker
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
        self.text = "\(self.yearMonthPicker.month)/\(self.yearMonthPicker.year)"
        
        self.pickerDelegate?.yearMonthPicker!(yearMonthPicker: self, done: true)
        self.originText = self.text
    }
    
    // キャンセルボタン押下
    @objc func cancelTapped() {
        self.endEditing(true)
        
        self.text = self.originText
        self.pickerDelegate?.yearMonthPicker!(yearMonthPicker: self, done: false)
    }
}

extension CmyTextFieldYearMonthPicker: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.originText = textField.text
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}

//////////////
/**
  <Some language code>
     language code = en, display name = English, in language = English
     language code = zh-Hans, display name = Chinese (Simplified Han), in language = 中文 (简体中文)
     language code = ja, display name = Japanese, in language = 日本語
     language code = pt, display name = Portuguese, in language = português
     language code = de, display name = German, in language = Deutsch
     language code = fr, display name = French, in language = français
     language code = ko, display name = Korean, in language = 한국어
     language code = zh-Hant, display name = Chinese (Traditional Han), in language = 中文 (繁體中文)
 */
class YearMonthPickerView: UIPickerView {
    enum MonthMode: Int {
        case ja
        case en
    }
    
    var timeZone: TimeZone!
    var locale: Locale!
    var monthMode: MonthMode = MonthMode.ja
    
    static let thisYear = Calendar.current.component(.year, from: Date())
    static let thisMonth = Calendar.current.component(.month, from: Date())
    var months: [String]!
    var minYear: Int?
    var componentIndexOfYear: Int = 0
    var componentIndexOfMonth: Int = 1
    var yearSymbol: String = ""
    var monthSymbol: String = ""

    var years: [Int]!
    
    var month = YearMonthPickerView.thisMonth {
        didSet {
            selectRow(self.month - 1, inComponent: self.componentIndexOfMonth, animated: false)
        }
    }
    
    var year = YearMonthPickerView.thisYear {
        didSet {
            selectRow(self.years.index(of: self.year)!, inComponent: self.componentIndexOfYear, animated: true)
        }
    }
    
    var date : Date? {
        get {
            let dateString = "\(self.year)-\(self.month)-01"
            return dateString.convertToDateWithYYYYMD()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func _setup() {
        //create years array
        self.years = {(minYear: Int?) -> [Int] in
            var years: [Int]!
            if let minYear = self.minYear {
                years = (minYear...minYear+50).map { $0 }
            } else {
                years = (YearMonthPickerView.thisYear - 100...YearMonthPickerView.thisYear + 50).map { $0 }
            }
            return years
        }(self.minYear)
        
        // population months with localized names
        self.months = {() -> [String] in
            var months: [String] = []
            var month = 0

            if ["ja", "zh-Hans", "zh-Hant"].contains(self.locale.languageCode) {
                self.monthMode = MonthMode.ja
                self.componentIndexOfMonth = 1
                self.componentIndexOfYear = 0
                self.yearSymbol = "年"
                self.monthSymbol = "月"
                
                for _ in 1...12 {
                    months.append("\(month+1)\(self.monthSymbol)")
                    month += 1
                }
            } else {
                self.monthMode = MonthMode.en
                self.componentIndexOfMonth = 0
                self.componentIndexOfYear = 1

                for _ in 1...12 {
                    months.append(DateFormatter().monthSymbols[month].capitalized)
                    month += 1
                }
            }
            return months
        }()
        
        self.delegate = self
        self.dataSource = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {[weak self] () in
            guard let weakSelf = self else {return}
            let yIdx = weakSelf.years.index(of: YearMonthPickerView.thisYear)
            
            weakSelf.selectRow(yIdx!, inComponent: weakSelf.componentIndexOfYear, animated: false)
            weakSelf.selectRow(YearMonthPickerView.thisMonth - 1, inComponent: weakSelf.componentIndexOfMonth, animated: false)
        }
    }
    
}

// MARK: UIPickerViewDataSource
//
extension YearMonthPickerView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var number: Int = 0
        switch component {
        case self.componentIndexOfYear:
            number = self.years.count
        case self.componentIndexOfMonth:
            number = self.months.count
        default:
            break
        }
        return number
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var retStr: String?
        
        switch component {
        case self.componentIndexOfYear:
            retStr = "\(self.years[row])\(self.yearSymbol)"
        case self.componentIndexOfMonth:
            retStr = self.months[row]
        default:
            break
        }
        return retStr
    }
    
}

// MARK: UIPickerViewDelegate
//
extension YearMonthPickerView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let month = self.selectedRow(inComponent: self.componentIndexOfMonth) + 1
        let year = years[self.selectedRow(inComponent: self.componentIndexOfYear)]
        self.month = month
        self.year = year
    }

}



