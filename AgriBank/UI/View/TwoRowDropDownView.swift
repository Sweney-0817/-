//
//  TwoRowDropDownView.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/6/30.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

protocol TwoRowDropDownViewDelegate {
    func clickTwoRowDropDownView(_ sender: TwoRowDropDownView)
}

class TwoRowDropDownView: UIView {
    @IBOutlet weak var m_lbFirstRowTitle: UILabel!
    @IBOutlet weak var m_lbFirstRowContent: UILabel!
    @IBOutlet weak var m_lbSecondRowTitle: UILabel!
    @IBOutlet weak var m_lbSecondRowContent: UILabel!
    @IBOutlet weak var m_btn: UIButton!
    var delegate:TwoRowDropDownViewDelegate? = nil
    
    @IBAction func m_btnClick(_ sender: Any) {
        delegate?.clickTwoRowDropDownView(self)
    }
    
    func getHeight() -> CGFloat {
        return 80
    }
    
    func setTwoRow(_ firstTitle:String, _ firstContent:String, _ secondTitle:String, _ secondContent:String) {
        m_lbFirstRowTitle.text = firstTitle
        m_lbFirstRowContent.text = firstContent
        m_lbSecondRowTitle.text = secondTitle
        m_lbSecondRowContent.text = secondContent
        //無障礙＋
        let acclb:String  = firstTitle +  firstContent  + secondTitle + secondContent
        m_btn.accessibilityLabel = acclb
//        self.setNeedsLayout()
    }
    
    func getContentByType(_ index:DropDownType) -> String {
        var value = ""
        switch index {
        case .First:
            value = m_lbFirstRowContent.text ?? ""
            
        case .Second:
            value = m_lbSecondRowContent.text ?? ""
            
        default: break
        }
        return value
    }
}
