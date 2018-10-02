//
//  CmyAccountRegAlertController.swift
//  MaldikaBileto
//
//  Created by venus.janne on 2018/07/28.
//  Copyright © 2018 x.yang. All rights reserved.
//

import UIKit

class CmyAccountRegFinAlertController: CmyAlertController {

    @IBOutlet weak var messageLabel: UILabel!

//    enum ViewHeightStyle: Int {
//        case low
//        case medium
//        case high
//    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setModalStyle(a: String) {
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // Manage self view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let touch:UITouch = touches.first else
        {
            return;
        }
        if touch.view != self.view
        {
            self.dismiss(animated: true, completion: nil)
        }
    }

}
