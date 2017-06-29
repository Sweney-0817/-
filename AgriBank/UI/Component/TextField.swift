//
//  TextField.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/6/17.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let TextField_Insets = CGFloat(10)

class TextField: UITextField {

    let padding = UIEdgeInsets(top: 0, left: TextField_Insets, bottom: 0, right: TextField_Insets);
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }

}
