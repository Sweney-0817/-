//
//  GPDiffAmountDetailView.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/8/20.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit
struct DiffAmountDetail {
    var m_strDate: String
    var m_strAmount: String
    var m_strBasePrice: String
    var m_strUp: String
    var m_strUpAmount: String
    var m_strDown: String
    var m_strDownAmount: String
    var m_strAmountLimit: String
}
protocol GPDiffAmountDetailViewDelegate {
    func clickDiffAmountDetailViewCloseBtn()
}

class GPDiffAmountDetailView: UIView {
    var delegate:GPDiffAmountDetailViewDelegate? = nil
    @IBOutlet var m_lbDate: UILabel!
    @IBOutlet var m_lbAmount: UILabel!
    @IBOutlet var m_lbBasePrice: UILabel!
    @IBOutlet var m_lbUp: UILabel!
    @IBOutlet var m_lbUpAmount: UILabel!
    @IBOutlet var m_lbDown: UILabel!
    @IBOutlet var m_lbDownAmount: UILabel!
    @IBOutlet var m_lbAmountLimit: UILabel!
    @IBAction func clickCloseBtn(_ sender: Any) {
        delegate?.clickDiffAmountDetailViewCloseBtn()
    }
    func setData(_ data: DiffAmountDetail) {
        m_lbDate.text = data.m_strDate
        m_lbAmount.text = data.m_strAmount
        m_lbBasePrice.text = data.m_strBasePrice
        m_lbUp.text = data.m_strUp
        m_lbUpAmount.text = data.m_strUpAmount
        m_lbDown.text = data.m_strDown
        m_lbDownAmount.text = data.m_strDownAmount
        m_lbAmountLimit.text = data.m_strAmountLimit
    }
}
