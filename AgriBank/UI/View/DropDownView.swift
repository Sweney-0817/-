//
//  DropDownView.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/6/27.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

protocol DropDownViewDelegate {
    func clickDropDownView(_ sender: DropDownView)
}

class DropDownView: UIView {
    @IBOutlet weak var m_lbFirstRowTitle: UILabel!
    @IBOutlet weak var m_lbFirstRowContent: UILabel!
    @IBOutlet weak var m_lbSecondRowTitle: UILabel!
    @IBOutlet weak var m_lbSecondRowContent: UILabel!
    @IBOutlet weak var m_lbThirdRowTitle: UILabel!
    @IBOutlet weak var m_lbThirdRowContent: UILabel!
    @IBOutlet weak var m_consSecondRowHeight: NSLayoutConstraint!
    @IBOutlet weak var m_consThirdRowHeight: NSLayoutConstraint!
    @IBOutlet weak var m_consViewHeight: NSLayoutConstraint!
    @IBOutlet weak var m_consViewWidth: NSLayoutConstraint!
    let m_floatRowHeight:CGFloat = 25.0
    var delegate:DropDownViewDelegate? = nil
    @IBAction func m_btnClick(_ sender: Any) {
//        print(m_lbFirstRowTitle.text ?? "DropDownViewClick", m_lbFirstRowContent.text ?? "")
        delegate?.clickDropDownView(self)
    }
    
    func getHeight() -> CGFloat {
        return m_consViewHeight.constant
    }
    
    func initValue(_ width:CGFloat) {
        m_consViewWidth.constant = width
        m_consSecondRowHeight.constant = 0
        m_consThirdRowHeight.constant = 0
        m_lbFirstRowTitle.text = ""
        m_lbFirstRowContent.text = ""
        m_lbSecondRowTitle.text = ""
        m_lbSecondRowContent.text = ""
        m_lbThirdRowTitle.text = ""
        m_lbThirdRowContent.text = ""
    }
    
    func setOneRow(_ firstTitle:String, _ firstContent:String) {
        m_consViewHeight.constant = 60.0
        m_lbFirstRowTitle.text = firstTitle
        m_lbFirstRowContent.text = firstContent
        self.setNeedsLayout()
    }
   
    func setTwoRow(_ firstTitle:String, _ firstContent:String, _ secondTitle:String, _ secondContent:String) {
        m_consSecondRowHeight.constant = m_floatRowHeight
        m_consViewHeight.constant = 80.0
        m_lbFirstRowTitle.text = firstTitle
        m_lbFirstRowContent.text = firstContent
        m_lbSecondRowTitle.text = secondTitle
        m_lbSecondRowContent.text = secondContent
        self.setNeedsLayout()
    }

    func setThreeRow(_ firstTitle:String, _ firstContent:String, _ secondTitle:String, _ secondContent:String, _ thirdTitle:String, _ thirdContent:String) {
        m_consSecondRowHeight.constant = m_floatRowHeight
        m_consThirdRowHeight.constant = m_floatRowHeight
        m_consViewHeight.constant = 100.0
        m_lbFirstRowTitle.text = firstTitle
        m_lbFirstRowContent.text = firstContent
        m_lbSecondRowTitle.text = secondTitle
        m_lbSecondRowContent.text = secondContent
        m_lbThirdRowTitle.text = thirdTitle
        m_lbThirdRowContent.text = thirdContent
        self.setNeedsLayout()
    }
}
