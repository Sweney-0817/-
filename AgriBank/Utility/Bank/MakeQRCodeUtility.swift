//
//  MakeQRCode.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/7/9.
//  Copyright © 2018年 Systex. All rights reserved.
//

import Foundation

class MakeQRCodeUtility {
    static let utility = MakeQRCodeUtility()
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.applying(transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
}
