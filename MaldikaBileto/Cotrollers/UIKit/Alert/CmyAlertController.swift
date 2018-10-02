//
//  CmyAlertController.swift
//  MaldikaBileto
//
//  Created by venus.janne on 2018/07/28.
//  Copyright © 2018 x.yang. All rights reserved.
//

import UIKit

class CmyAlertController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    
    var okAction: (()->())!
    var cancelAction: (()->())!

    var isUserDismissEnabled:Bool = false

//    class func instance<T>(aClass: T) -> CmyAlertController {
//        let inst = CmyAlertController(nibName: String(describing: aClass), bundle: Bundle(for: aClass as! AnyClass))
//        return inst
//    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
        self.view.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        if let contentview = self.contentView {
            contentview.layer.cornerRadius = 6
            contentview.layer.masksToBounds = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func okButtonDidTap(_ sender: RoundRectButton) {
        if !self.isUserDismissEnabled {
            self.dismiss(animated: true, completion: {
                if let action = self.okAction {
                    action()
                }
            })
        } else {
            if let action = self.okAction {
                action()
            }
        }
    }
    
    @IBAction func cancelButtonDidTap(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            if let action = self.cancelAction {
                action()
            }
        })
    }

}
