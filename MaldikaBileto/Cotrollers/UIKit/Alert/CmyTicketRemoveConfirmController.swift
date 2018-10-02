//
//  CmyTicketRemoveConfirmController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/02.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyTicketRemoveConfirmController: CmyAlertController {
    @IBOutlet weak var removeButton:  RoundRectButton!
    @IBOutlet weak var approveCheckButton:  CheckButton!
    @IBOutlet weak var approveCheckLabel: UILabel!
    @IBOutlet weak var remarkLabel: UILabel!

    
    var ticket: Ticket!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //set other items
        
        // remark label
        if ticket.ticketType == .gift {
            self.remarkLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "TicketRemoveConfirm.remarkLabel.text.gift", commenmt: "使用できなくなる")
        } else {
            self.remarkLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "TicketRemoveConfirm.remarkLabel.text.private", commenmt: "使用できなくなる")
        }

        //check button
        self.approveCheckLabel.textColor = UIColor.cmyMainColor()
        self.approveCheckButton.delegate = self
    }
    
    init(ticket: Ticket!) {
        if let ticket = ticket {
            self.ticket = ticket
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

extension CmyTicketRemoveConfirmController: CheckButtonDelegate {
    func checkButton(checkButton: CheckButton, checked: Bool) {
        if checkButton == self.approveCheckButton {
            //self.approveCheckLabel.textColor = checked ? UIColor.cmyMainColor() : UIColor.cmyTextColor()
            self.removeButton.isEnabled = checked
        }
    }
}
