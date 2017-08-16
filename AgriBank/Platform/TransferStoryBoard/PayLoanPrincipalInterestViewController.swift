//
//  PayLoanPrincipalInterestViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/10.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class PayLoanPrincipalInterestViewController: BaseViewController, ThreeRowDropDownViewDelegate {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var advancePayAmtLabel: UILabel! // 預收金額
    @IBOutlet weak var needPayAmtLabel: UILabel! // 應繳總額
    @IBOutlet weak var calculatePeroidLabel: UILabel! // 計算期間
    @IBOutlet weak var rateLabel: UILabel! // 利率
    @IBOutlet weak var breakContractDayLabel: UILabel! // 違約天數
    @IBOutlet weak var needPayPrincipalLabel: UILabel! // 應繳本金
    @IBOutlet weak var needPayBreakContractLabel: UILabel! // 應繳違約金
    @IBOutlet weak var needPayInterestLabel: UILabel! // 應繳利息
    @IBOutlet weak var needPayDelayInterestLabel: UILabel! // 應繳逾期息
    @IBOutlet weak var amountLabel: UILabel! // 實際金額
    private var topDropView:ThreeRowDropDownView? = nil
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        topDropView = getUIByID(.UIID_ThreeRowDropDownView) as? ThreeRowDropDownView
        topDropView?.setThreeRow("轉出帳號", "", "幣別", "", "餘額", "")
        topDropView?.frame = topView.frame
        topDropView?.frame.origin = .zero
        topView.addSubview(topDropView!)
        topView.layer.borderWidth = Layer_BorderWidth
        topView.layer.borderColor = Gray_Color.cgColor
        setShadowView(topView)
        
        middleView.layer.borderWidth = Layer_BorderWidth
        middleView.layer.borderColor = Gray_Color.cgColor
        setShadowView(middleView)
        
        setShadowView(bottomView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickSendBtn(_ sender: Any) {

    }

    // MARK: - ThreeRowDropDownViewDelegate
    func clickThreeRowDropDownView(_ sender: ThreeRowDropDownView) {
    }
}
