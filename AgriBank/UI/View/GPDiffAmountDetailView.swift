//
//  GPDiffAmountDetailView.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/8/20.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit
struct DiffAmountDetail {
    ///投資日(扣款日期)
    var m_strDate: String = ""
    ///投資金額
    var m_strAmount: String = ""
    ///基準價格(本行賣出價)
    var m_strBasePrice: String = ""
    ///較基準價格上漲
    var m_strUp: String = ""
    ///上漲時每次投資金額
    var m_strUpAmount: String = ""
    ///較基準價格下跌
    var m_strDown: String = ""
    ///下跌時每次投資金額
    var m_strDownAmount: String = ""
    ///每次投資金額上限
    var m_strAmountUpLimit: String = ""
    ///每次投資金額下限
    var m_strAmountDownLimit: String = ""
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
    @IBOutlet var m_lbAmountUpLimit: UILabel!
    @IBOutlet var m_lbAmountDownLimit: UILabel!
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
        m_lbAmountUpLimit.text = data.m_strAmountUpLimit
        m_lbAmountDownLimit.text = data.m_strAmountDownLimit
    }
}
