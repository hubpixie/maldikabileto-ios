//
//  UIStoryboard+ext.swift
//  MaldikaBileto
//
//  Created by venus.janne on 2018/08/05.
//  Copyright © 2018 x.yang. All rights reserved.
//

import UIKit

extension UIStoryboard {
    class func splash() -> UIStoryboard {
        return UIStoryboard(name: "LaunchScreen", bundle: nil)
    }
    class func main() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    class func main2() -> UIStoryboard {
        return UIStoryboard(name: "Main2", bundle: nil)
    }
}
