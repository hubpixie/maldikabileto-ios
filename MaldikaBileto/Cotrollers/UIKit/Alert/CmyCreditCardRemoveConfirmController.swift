//
//  CmyCreditCardRemoveConfirmController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/02.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyCreditCardRemoveConfirmController: CmyAlertController {
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var cardExpirationDateLabel: UILabel!

    @IBOutlet weak var removeButton:  RoundRectButton!
    @IBOutlet weak var approveCheckButton:  CheckButton!
    @IBOutlet weak var approveCheckLabel: UILabel!
    
    var card: Card!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //set other items
        self.cardNumberLabel.text = "\(self.card.cardCompany ?? "") \(self.card.cardNumber)"
        self.cardExpirationDateLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "Common.cardExpirationDate.label", commenmt: "有効期限：") + self.card.cardExpirationDate
        
        if UIScreen.main.bounds.width <= 320 {
            //self.approveCheckLabel.font = UIFont.systemFont(ofSize: self.approveCheckLabel.font.pointSize - 2)
        }
        self.approveCheckLabel.textColor = UIColor.cmyMainColor()
        
        self.approveCheckButton.delegate = self
    }
    
    init(card: Card!) {
        if let card = card {
            self.card = card
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
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

extension CmyCreditCardRemoveConfirmController: CheckButtonDelegate {
    func checkButton(checkButton: CheckButton, checked: Bool) {
        if checkButton == self.approveCheckButton {
            //self.approveCheckLabel.isEnabled = checked
            self.removeButton.isEnabled = checked
        }
    }
}
