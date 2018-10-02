//
//  PasscodeViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/22.
//  Copyright © 2018 x.yang. All rights reserved.
//

import UIKit
import LocalAuthentication
import Security

public enum PasscodeType {
    case authenticate
    case makeCode
    case changeCode
}

class CmyPasscodeSettingViewController: UIViewController {
    
    //パスコード入力回数（上限）
    static let kLimitOfPasscodeInput: Int = 4
    //パスコードの長さ
    static let kPasscodeLen: Int = 4
    //パスコード入力の種別
    var type = PasscodeType.authenticate
    private var _type = PasscodeType.authenticate
    private var _newType = PasscodeType.authenticate

    var countOfAskPasscode: Int = 0
    var isUserDismissEnabled:Bool = false
    var compareCode: String?
    var originalCode: String?

    var code = "" {
        didSet {
            var count = 0
            
            for view in self.codeView.subviews {
                if let view = view as? PasscodeCharacterView {
                    view.value = count < code.count
                    count += 1
                }
            }
            
            guard self.code.count == CmyPasscodeSettingViewController.kPasscodeLen else { return }
            
            // a block for make a new passcode
            let make_code_block = {(codeType: PasscodeType) in
                if self.compareCode == nil  {
                    if self.originalCode == nil {
                        self._newType = .makeCode
                        self.originalCode = self.code
                    }else {
                        self.compareCode = self.code
                    }
                    self.confirmCode(codeType: codeType)
                    return
                } else {
                    if self.compareCode == self.code {
                        var passcodeSetting = CmyUserDefault.shared.passcodeSetting
                        passcodeSetting.passcode = self.code
                        CmyUserDefault.shared.passcodeSetting = passcodeSetting
                        self.dismiss(success: true)
                    } else {
                        self.displayError(codeType: codeType)
                    }
                }
            }
            
            switch self._type {
            case .authenticate:
                if code == CmyUserDefault.shared.passcodeSetting.passcode {
                    self.dismiss(success: true)
                } else {
                    if self.countOfAskPasscode >= CmyPasscodeSettingViewController.kLimitOfPasscodeInput {
                        self.dismiss(success: false)
                        break
                    }
                    self.displayError(codeType: _type)
                    self.countOfAskPasscode += 1
                }
            case .changeCode:
                if code != self.originalCode && self.originalCode != nil {
                    //現在のパスコードを確認する際、上限回数を超過したら、以降の処理を行わない
                    if self.countOfAskPasscode >= CmyPasscodeSettingViewController.kLimitOfPasscodeInput {
                        self.dismiss(success: false)
                        break
                    }
                    //元々のパシコード合わせのため、codeTypeにauthenticateを渡す
                    self.displayError(codeType: .authenticate)
                    self.countOfAskPasscode += 1
                } else {
                    self.isUserDismissEnabled = false
                    self.originalCode = nil
                    make_code_block(_type)
                }
            case .makeCode:
                make_code_block(_type)
            }
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var codeTitleLabel: UILabel!
    @IBOutlet weak var codeView: UIView!
    @IBOutlet weak var codeDescriptionLabel: UILabel!
    @IBOutlet weak var codeErrorLabel: UILabel!

    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var blurView: UIVisualEffectView!

    // MARK: - Callbacks
    
    var authenticatedCompletion: ((Bool) -> Void)?
    var dismissCompletion: (() -> Void)?
    
    // MARK: - View Cycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .default
        
        //キャンセルボタン
        self.cancelButton.isHidden = true
        self.cancelButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.cancelButton.setTitle(CmyLocaleUtil.shared.localizedMisc(key: "PasscodeSetting.Cancel", commenmt: "キャンセル"),
                                   for: .normal)
        
        //パスコード編集モードによる表示をきりかえる
        switch self.type {
        case .makeCode:
            self.codeTitleLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "PasscodeSetting.makeCode.title", commenmt: "パスコード設定")
            self.codeDescriptionLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "PasscodeSetting.makeCode.description", commenmt: "パスコード設定")
        case .changeCode:
            self.codeTitleLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "PasscodeSetting.changeCode.first.title", commenmt: "現在のパスコード入力")
            self.codeDescriptionLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "PasscodeSetting.changeCode.first.description", commenmt: "現在のパスコード入力")
            self.cancelButton.isHidden = false
        default:
            self.codeTitleLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "PasscodeSetting.authenticate.title", commenmt: "パスコード入力")
            self.codeDescriptionLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "PasscodeSetting.authenticate.description", commenmt: "パスコード入力")
        }
        self._type = self.type
        self._newType = self.type
        self.originalCode = CmyUserDefault.shared.passcodeSetting.passcode
        self.code = ""
    }
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .default
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Helpers
    
    func confirmCode(codeType: PasscodeType) {
        if codeType == .makeCode {
            self.codeTitleLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "PasscodeSetting.makeCode.again.title", commenmt: "パスコード再入力")
            self.codeDescriptionLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "PasscodeSetting.makeCode.again.description", commenmt: "パスコードを再入力してください")
            self.cancelButton.isHidden = false
        }
        if codeType == .changeCode {
            self.codeTitleLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "PasscodeSetting.changeCode.last.title", commenmt: "新しいパスコード")
            self.codeDescriptionLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "PasscodeSetting.changeCode.last.title", commenmt: "新しいパスコードを入力してください")
        }
        self.code = ""
    }
    
    public func dismiss(success: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
        
        if let dismissCompletion = dismissCompletion {
            if !self.isUserDismissEnabled {
                self.dismiss(animated: true) {
                    self.authenticatedCompletion?(success)
                    dismissCompletion()
                }
            } else {
                self.authenticatedCompletion?(success)
                dismissCompletion()
            }
        } else {
            if !self.isUserDismissEnabled {
                self.dismiss(animated: true) {
                    self.authenticatedCompletion?(success)
                }
            } else {
                self.authenticatedCompletion?(success)
            }
        }
    }
    
    func displayError(codeType: PasscodeType) {
        self.view.isUserInteractionEnabled = false
        let animation = CABasicAnimation(keyPath: "position")
        animation.autoreverses = true
        animation.duration = 0.1
        animation.isRemovedOnCompletion = true
        animation.repeatCount = 2
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.codeView.center.x - 10, y: self.codeView.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.codeView.center.x + 10, y: self.codeView.center.y))
        
        self.codeView.layer.add(animation, forKey: animation.keyPath)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + animation.duration * Double(animation.repeatCount + 1)) {
            self.code = ""
            self.view.isUserInteractionEnabled = true
            
            //エラーメッセージ表示
            if codeType == .makeCode {
                self.codeErrorLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "PasscodeSetting.makeCode.error", commenmt: "パスコード不一致")
            }
            if codeType == .changeCode {
                self.codeErrorLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "PasscodeSetting.changeCode.error", commenmt: "パスコード不一致")
            }
            if codeType == .authenticate {
                self.codeErrorLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "PasscodeSetting.authenticate.error.1", commenmt: "パスコードが違います")
            }
        }
    }

    // MARK: - IBActions
    
    @IBAction func didPress(button: UIButton) {
        //エラーメッセージをクリアする
        self.codeErrorLabel.text = ""
        
        self._type = self._newType
        
        //入力コードを確認し、画面へ反映する
        guard let button = button as? NumberButton else {
            self.code = String(self.code.dropLast(1))
            return
        }
        code.append(button.value)
    }
    
    @IBAction func cancel(_ sender: AnyObject?) {
        //パスコード変更時または再入力時、初期状態に戻す
        // それ以外、画面終了する
        self.code = ""
        //エラーメッセージをクリアする
        self.codeErrorLabel.text = ""

        if self._type == .makeCode && self.compareCode != nil {
            self.compareCode = nil
            if self.type == .makeCode {
                self.codeTitleLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "PasscodeSetting.makeCode.title", commenmt: "パスコード設定")
                self.codeDescriptionLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "PasscodeSetting.makeCode.description", commenmt: "パスコード設定")
                self.cancelButton.isHidden = true

            } else {
                self.codeTitleLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "PasscodeSetting.changeCode.last.title", commenmt: "新しいパスコード")
                self.codeDescriptionLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "PasscodeSetting.changeCode.last.title", commenmt: "新しいパスコードを入力してください")
            }
        } else {
            if self._newType == .changeCode {
                self.isUserDismissEnabled = false
                self.dismiss(success: true)
            } else {
                self.dismiss(success: false)
            }
        }
    }
}
