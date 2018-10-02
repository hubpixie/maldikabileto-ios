//
//  CmyWithdrawalConfirmController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/24.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyWithdrawalConfirmController: CmyAlertController {
    @IBOutlet weak var okButton:  RoundRectButton!
    @IBOutlet weak var approveCheckButton:  CheckButton!
    @IBOutlet weak var approveCheckLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //set other items
        self.approveCheckLabel.textColor = UIColor.cmyMainColor()
        self.approveCheckButton.delegate = self
    }
    
    /*
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CmyWithdrawalConfirmController: CheckButtonDelegate {
    func checkButton(checkButton: CheckButton, checked: Bool) {
        if checkButton == self.approveCheckButton {
            //self.approveCheckLabel.isEnabled = checked
            self.okButton.isEnabled = checked
        }
    }
}
