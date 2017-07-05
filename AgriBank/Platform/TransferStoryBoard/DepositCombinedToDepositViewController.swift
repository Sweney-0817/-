//
//  DepositCombinedToDepositViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/4.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class DepositCombinedToDepositViewController: BaseViewController, UITextFieldDelegate, ThreeRowDropDownViewDelegate, OneRowDropDownViewDelegate {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var depositTypeView: UIView!
    @IBOutlet weak var periodView: UIView!
    @IBOutlet weak var rateFlexibleBtn: UIButton! // 利率方式 - 機動
    @IBOutlet weak var rateFixedBtn: UIButton!// 利率方式 - 固定
    @IBOutlet weak var currentRateLabel: UILabel!
    @IBOutlet weak var continueDepositBtn: UIButton!
    @IBOutlet weak var notContinueDepositBtn: UIButton!
    @IBOutlet weak var autoRateFixedBtn: UIButton! // 自動轉期利率 - 固定
    @IBOutlet weak var autoRateFlexibleBtn: UIButton! // 自動轉期利率 - 機動
    private var topDropView:ThreeRowDropDownView? = nil
    private var depositTypeDropView:OneRowDropDownView? = nil
    private var periodDropView:OneRowDropDownView? = nil
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        topDropView = getUIByID(.UIID_ThreeRowDropDownView) as? ThreeRowDropDownView
        topDropView?.setThreeRow("綜存帳號", "", "幣別", "", "餘額", "")
        topDropView?.frame = topView.frame
        topDropView?.frame.origin = .zero
        topView.addSubview(topDropView!)
        setShadowView(topView)
        topView.layer.borderWidth = Layer_BorderWidth
        topView.layer.borderColor = Gray_Color.cgColor
        
        depositTypeDropView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        depositTypeDropView?.setOneRow("存款種類", "")
        depositTypeDropView?.frame = depositTypeView.frame
        depositTypeDropView?.frame.origin = .zero
        depositTypeView.addSubview(depositTypeDropView!)
        
        periodDropView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        periodDropView?.setOneRow("轉存期別", "")
        periodDropView?.frame = periodView.frame
        periodDropView?.frame.origin = .zero
        periodView.addSubview(periodDropView!)
        
        setShadowView(middleView)
        middleView.layer.borderWidth = Layer_BorderWidth
        middleView.layer.borderColor = Gray_Color.cgColor
        
        setShadowView(bottomView)
        
        AddObserverToKeyBoard()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickRateBtn(_ sender: Any) {
        let btn = sender as! UIButton
        if btn == rateFlexibleBtn {
            rateFlexibleBtn.setImage(UIImage(named: ImageName.RadioOn.rawValue), for: .normal)
            rateFixedBtn.setImage(UIImage(named: ImageName.RadioOff.rawValue), for: .normal)
        }
        else {
            rateFixedBtn.setImage(UIImage(named: ImageName.RadioOn.rawValue), for: .normal)
            rateFlexibleBtn.setImage(UIImage(named: ImageName.RadioOff.rawValue), for: .normal)
        }
    }
  
    @IBAction func clickDepositBtn(_ sender: Any) {
        let btn = sender as! UIButton
        if btn == continueDepositBtn {
            continueDepositBtn.setImage(UIImage(named: ImageName.RadioOn.rawValue), for: .normal)
            notContinueDepositBtn.setImage(UIImage(named: ImageName.RadioOff.rawValue), for: .normal)
        }
        else {
            notContinueDepositBtn.setImage(UIImage(named: ImageName.RadioOn.rawValue), for: .normal)
            continueDepositBtn.setImage(UIImage(named: ImageName.RadioOff.rawValue), for: .normal)
        }
    }
    
    @IBAction func clickAutoRateBtn(_ sender: Any) {
        let btn = sender as! UIButton
        if btn == autoRateFlexibleBtn {
            autoRateFlexibleBtn.setImage(UIImage(named: ImageName.RadioOn.rawValue), for: .normal)
            autoRateFixedBtn.setImage(UIImage(named: ImageName.RadioOff.rawValue), for: .normal)
        }
        else {
            autoRateFixedBtn.setImage(UIImage(named: ImageName.RadioOn.rawValue), for: .normal)
            autoRateFlexibleBtn.setImage(UIImage(named: ImageName.RadioOff.rawValue), for: .normal)
        }
    }
    
    @IBAction func clickSendBtn(_ sender: Any) {
        var data = ConfirmResultStruct(ImageName.CowCheck.rawValue, "請確認本次交易資訊", [[String:String]](), nil, "確認送出", "繼續交易")
        data.list!.append(["Key": "轉出帳號", "Value":"12345678901234"])
        data.list!.append(["Key": "預約轉帳日", "Value":"固定每月30日"])
        data.list!.append(["Key": "銀行代碼", "Value":"008"])
        data.list!.append(["Key": "轉入帳號", "Value":"12345678901235"])
        data.list!.append(["Key": "轉帳金額", "Value":"9,999,999.00"])
        data.list!.append(["Key": "備註/交易備註", "Value":"備註"])
        enterConfirmResultController(true, data, true)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - ThreeRowDropDownViewDelegate
    func clickThreeRowDropDownView(_ sender: ThreeRowDropDownView) {
        
    }
    
    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        
    }
}
