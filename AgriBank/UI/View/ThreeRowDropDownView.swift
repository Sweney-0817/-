//
//  ThreeRowDropDownView.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/6/30.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

protocol ThreeRowDropDownViewDelegate {
    func clickThreeRowDropDownView(_ sender: ThreeRowDropDownView)
}

class ThreeRowDropDownView: UIView {
    @IBOutlet weak var m_lbFirstRowTitle: UILabel!
    @IBOutlet weak var m_lbFirstRowContent: UILabel!
    @IBOutlet weak var m_lbSecondRowTitle: UILabel!
    @IBOutlet weak var m_lbSecondRowContent: UILabel!
    @IBOutlet weak var m_lbThirdRowTitle: UILabel!
    @IBOutlet weak var m_lbThirdRowContent: UILabel!

    var delegate:ThreeRowDropDownViewDelegate? = nil
    @IBOutlet weak var m_btn: UIButton!
    @IBAction func m_btnClick(_ sender: Any) {
        delegate?.clickThreeRowDropDownView(self)
    }
    func getHeight() -> CGFloat {
        return 100
    }
 
    func setThreeRow(_ firstTitle:String, _ firstContent:String, _ secondTitle:String, _ secondContent:String, _ thirdTitle:String, _ thirdContent:String) {
        m_lbFirstRowTitle.text = firstTitle
        m_lbFirstRowContent.text = firstContent
        m_lbSecondRowTitle.text = secondTitle
        m_lbSecondRowContent.text = secondContent
        m_lbThirdRowTitle.text = thirdTitle
        m_lbThirdRowContent.text = thirdContent
        //無障礙＋
        let acclb:String  = firstTitle +  firstContent  + secondTitle + secondContent + thirdTitle + thirdContent
        m_btn.accessibilityLabel = acclb
        
        
        
        self.setNeedsLayout()
    }
    
    func getContentByType(_ index:DropDownType) -> String {
        var value = ""
        switch index {
        case .First:
            value = m_lbFirstRowContent.text ?? ""
        
        case .Second:
            value = m_lbSecondRowContent.text ?? ""
            
        case .Third:
            value = m_lbThirdRowContent.text ?? ""
        }
        return value
    }
}
