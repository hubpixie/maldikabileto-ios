//
//  CmyPushFadeSegue.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/05.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import Foundation

class CmyPushFadeSegue: UIStoryboardSegue {
    var extraHandler: (()->())?
    override func perform() {
        UIView.transition(
            with: (source.navigationController?.view)!,
            duration: 0.5,
            options: .transitionCrossDissolve,
            animations: {
                () -> Void in
                //self.source.navigationController?.pushViewController(self.destination, animated: false)
                if let extraHandler = self.extraHandler {
                    extraHandler()
                }
        },
            completion: nil)
    }
    
}
