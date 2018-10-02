//
//  CmyPresentSegue.swift
//  MaldikaBileto
//
//  Created by venus.janne on 2018/07/21.
//  Copyright © 2018 x.yang. All rights reserved.
//

import Foundation

class CmyPresentSegue: UIStoryboardSegue {
    var extraHandler: (()->())?
    override func perform() {
//        UIView.transition(
//            with: (source.navigationController?.view)!,
//            duration: 0.5,
//            options: .transitionCrossDissolve,
//            animations: {
//                () -> Void in
//                //self.source.navigationController?.present(self.destination, animated: true, completion: nil)
//                if let extraHandler = self.extraHandler {
//                    extraHandler()
//                }
//        },
//            completion: nil)
        if let extraHandler = self.extraHandler {
            extraHandler()
        }
    }
    
}
