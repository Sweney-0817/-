//
//  ColorExtension.swift
//  SKLAgent
//
//  Created by JaN on 2016/11/19.
//  Copyright © 2016年 Yu-Chun-Chen. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(red: Int, green: Int, blue: Int, fAlpha: CGFloat) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: fAlpha)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    convenience init(netHex:Int, fAlpha: CGFloat) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff, fAlpha: fAlpha)
    }
    
    convenience init(netHex:Int, fAlpha: CGFloat, overlayWithNetHex overlay: Int) {
        self.init(red: Int(CGFloat(netHex >> 16 & 0xff) * fAlpha + (CGFloat(overlay >> 16 & 0xff) * (1 - fAlpha))),
                  green: Int(CGFloat(netHex >> 8 & 0xff) * fAlpha + (CGFloat(overlay >> 8 & 0xff) * (1 - fAlpha))),
                  blue: Int(CGFloat(netHex & 0xff) * fAlpha + (CGFloat(overlay & 0xff) * (1 - fAlpha))),
                  fAlpha: 1)
    }
    
    convenience init(hex8: UInt32) {
        let divisor = CGFloat(255)
        let red     = CGFloat((hex8 & 0xFF000000) >> 24) / divisor
        let green   = CGFloat((hex8 & 0x00FF0000) >> 16) / divisor
        let blue    = CGFloat((hex8 & 0x0000FF00) >>  8) / divisor
        let alpha   = CGFloat( hex8 & 0x000000FF       ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    convenience init(array: [String], alpha: CGFloat) {
        guard array.count == 3 else {
            self.init(red: 255/255, green: 255/255, blue: 255/255, alpha: alpha)
            return
        }
        let red = Int(array[0]) ?? 255
        let green = Int(array[1]) ?? 255
        let blue = Int(array[2]) ?? 255
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(gradientColor withframe: CGRect, colors:[UIColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = withframe
        gradientLayer.colors = colors
//        gradientLayer.startPoint = GradientDirection.leftToRight.values().start
//        gradientLayer.endPoint = GradientDirection.leftToRight.values().end
        
        UIGraphicsBeginImageContext(withframe.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let gradientColorImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.init(patternImage: gradientColorImage)
    }
}
