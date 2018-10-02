//
//  UIImage+QRCode.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/25.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

extension UIImage {
    
    // Generate QR code image with a given string
    //
    class func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    // Generate QR code image with a given base64 string
    //
    class func generateQRCodeWithBase64(from string: String) -> UIImage? {
        let data = Data(base64Encoded: string, options: .ignoreUnknownCharacters)
        
        return UIImage(data: data!)
    }
    
    // return a fitting sized image
    //
    class func fitSizedImage(image inImage: UIImage?, widthOffset: CGFloat) ->UIImage? {
        guard var image = inImage else {return nil}
        if image.size.width > UIScreen.main.bounds.width - widthOffset {
            let ratio = (UIScreen.main.bounds.width - widthOffset) / image.size.width
            let newImgSize = CGSize(width: UIScreen.main.bounds.width - widthOffset, height: image.size.height * ratio)
            if let image_ = image.resize(size: newImgSize) {image = image_}
        }
        return image
    }

    // Resize an image as new size and return it
    //
    func resize(size inSize: CGSize) -> UIImage? {
        let widthRatio = inSize.width / size.width
        let heightRatio = inSize.height / size.height
        let ratio = widthRatio < heightRatio ? widthRatio : heightRatio
        
        let resizedSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0)
        draw(in: CGRect(origin: .zero, size: resizedSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
}

