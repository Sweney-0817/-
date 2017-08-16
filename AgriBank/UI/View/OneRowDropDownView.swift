//
//  OneRowDropDownView.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/6/30.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

protocol OneRowDropDownViewDelegate {
    func clickOneRowDropDownView(_ sender: OneRowDropDownView)
}

class OneRowDropDownView: UIView {
    @IBOutlet weak var m_lbFirstRowTitle: UILabel!
    @IBOutlet weak var m_lbFirstRowContent: UILabel!
    var delegate:OneRowDropDownViewDelegate? = nil
    
    @IBAction func m_btnClick(_ sender: Any) {
        delegate?.clickOneRowDropDownView(self)
    }
    
    func getHeight() -> CGFloat {
        return 60
    }
    
    func setOneRow(_ firstTitle:String, _ firstContent:String) {
        m_lbFirstRowTitle.text = firstTitle
        m_lbFirstRowContent.text = firstContent
//        self.setNeedsLayout()
    }
    
    func getContentByType(_ index:DropDownType) -> String {
        var value = ""
        switch index {
        case .First:
            value = m_lbFirstRowContent.text ?? ""
            
        default: break
        }
        return value
    }
}
