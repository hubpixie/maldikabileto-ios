//
//  Passcode.swift
//  AuthenticatonView
//
//  Created by x.yang on 2018/07/22.
//  Copyright © 2018 x.yang. All rights reserved.
//

import UIKit

public class PasscodeBundle {
    
    struct Setting {
        var passcode: String
        var isValid: Bool
        
        static func setting(from dic: Dictionary<String, Any>?) -> Setting {
            let pwd = dic?["passcode"] as? String ?? ""
            let valid = dic?["is_valid"] as? Bool ?? false
            return Setting(passcode: pwd, isValid: valid)
        }
        
        func dictionary() -> Dictionary<String, Any> {
            let dic: [String : Any] = [
                "passcode": self.passcode,
                "is_valid": self.isValid
                ]
            return dic
        }
    }
    public var isPresented = false
    private var appDelegateWindow: UIWindow?
    
    private var authenticationViewController: CmyPasscodeSettingViewController?
    private lazy var passcodeWindow: UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        window.windowLevel = 0
        window.makeKeyAndVisible()
        
        return window
    }()
    
    public init(window: UIWindow?) {
        self.appDelegateWindow = window
    }
    
    @objc func willEnterForeground() {
    }
    
    @objc func didEnterBackground() {
    }
    
    // MARK: - Public
    
    public func authenticateWindow(completion: ((Bool) -> Void)? = nil) {
        guard !isPresented, let viewController = self.load(type: .authenticate, completion: completion) else { return }
        
        viewController.dismissCompletion = { [weak self] in self?.dismiss() }
        
        passcodeWindow.windowLevel = 2
        passcodeWindow.rootViewController = viewController
        
        self.isPresented = true
    }
    
    public func authenticate(completion: ((Bool) -> Void)? = nil) -> UIViewController? {
        return self.load(type: .authenticate, completion: completion)
    }
    
    public func authenticate(on viewController: UIViewController, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        guard let vc = self.authenticate(completion: completion) else { return }
        viewController.present(vc, animated: animated)
    }
    
    public func makeCode(completion: ((Bool) -> Void)? = nil) -> UIViewController? {
        return self.load(type: .makeCode, completion: completion)
    }
    
    public func makeCode(on viewController: UIViewController, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        guard let vc = self.makeCode(completion: completion) else { return }
        viewController.present(vc, animated: animated)
    }
    
    public func changeCode(completion: ((Bool) -> Void)? = nil) -> UIViewController? {
        return self.load(type: .changeCode, completion: completion)
    }
    
    public func changeCode(on viewController: UIViewController, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        guard let vc = self.makeCode(completion: completion) else { return }
        viewController.present(vc, animated: animated)
    }

    
    // MARK: - Private
    
    private func load(type: PasscodeType, completion: ((Bool) -> Void)?) -> CmyPasscodeSettingViewController? {
        //let bundle = Bundle(for: CmyPasscodeSettingViewController.self)
        let storyboard = UIStoryboard.main()
        guard let viewController = storyboard.instantiateViewController(withIdentifier: CmyStoryboardIds.passcodeSetting.rawValue) as? CmyPasscodeSettingViewController else {
            return nil
        }
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .crossDissolve
        viewController.authenticatedCompletion = completion
        viewController.type = type
        
        self.authenticationViewController = viewController
        
        return viewController
    }
    
    private func dismiss(animated: Bool = true) {
        DispatchQueue.main.async {
            self.isPresented = false
            self.appDelegateWindow?.windowLevel = 1
            self.appDelegateWindow?.makeKeyAndVisible()
            
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0,
                options: [.curveEaseInOut],
                animations: { [weak self] in
                    self?.passcodeWindow.alpha = 0
                },
                completion: { [weak self] _ in
                    self?.passcodeWindow.windowLevel = 0
                    self?.passcodeWindow.rootViewController = nil
                    self?.passcodeWindow.alpha = 1
                }
            )
        }
    }
}
