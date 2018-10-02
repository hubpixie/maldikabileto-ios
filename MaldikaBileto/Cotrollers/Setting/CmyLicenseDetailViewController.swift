//
//  CmyLicenseDetailViewController.swift
//  MaldikaBileto
//
//  Created by venus.janne on 2018/09/22.
//  Copyright © 2018 x.yang. All rights reserved.
//

import UIKit

class CmyLicenseDetailViewController: CmyViewController {
    @IBOutlet weak var licenseContentTextView: UITextView!
    
    var licenseItem: [String: Any]! {
        didSet {
//            self.licenseContentTextView.text = self.licenseItem?["FooterText"] as? String
//            self.resetNavigationItemTitle()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.resetNavigationItemTitle()
        
        // setup textView
        self.licenseContentTextView.topAnchor.constraint(equalTo: self.view.compatibleSafeAreaLayoutGuide.topAnchor).isActive = true
        self.licenseContentTextView.isEditable = false
        self.licenseContentTextView.text = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.licenseContentTextView.text = self.licenseItem?["FooterText"] as? String
//        self.licenseContentTextView.scrollRangeToVisible(NSRange(location: 0, length: 0))
//        self.licenseContentTextView.setContentOffset(.zero, animated: true)
        self.licenseContentTextView.isEditable = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.sourceViewController != nil {
            // タイトル設定
            self.sourceViewController?.resetNavigationItemTitle()
            self.sourceViewController?.seguePrepared = false
        }
        super.viewWillDisappear(animated)
    }
    
    //reset navigation title
    //
    override func resetNavigationItemTitle() {
        self.navigationItem.title = self.licenseItem["Title"] as? String
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
