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
    /* 為了帳戶往來明細特別設置 */
    @IBOutlet weak var titleWeight: NSLayoutConstraint!
    @IBOutlet weak var clickBtn: UIButton!
    
    @IBAction func m_btnClick(_ sender: Any) {
        delegate?.clickOneRowDropDownView(self)
    }
    
    func getHeight() -> CGFloat {
        return 60
    }
    
    func setOneRow(_ firstTitle:String, _ firstContent:String, _ isEnable:Bool = true) {
        m_lbFirstRowTitle.text = firstTitle
        m_lbFirstRowContent.text = firstContent
        clickBtn.isEnabled = isEnable
        m_lbFirstRowContent.textColor = isEnable ? .black : m_lbFirstRowTitle.textColor
        let acclb:String = firstTitle + firstContent
        clickBtn.accessibilityLabel = acclb
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
