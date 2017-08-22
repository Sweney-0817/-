//
//  DepositCombinedToDepositViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/4.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let DepositCombinedToDeposit_Account_Title = "綜存帳號"
let DepositCombinedToDeposit_Currency_Title = "幣別"
let DepositCombinedToDeposit_Balance_Title = "餘額"
let DepositCombinedToDeposit_DepositType_Title = "存款種類"
let DepositCombinedToDeposit_Period_Title = "轉存期別"

class DepositCombinedToDepositViewController: BaseViewController, UITextFieldDelegate, ThreeRowDropDownViewDelegate, OneRowDropDownViewDelegate {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var depositTypeView: UIView!
    @IBOutlet weak var periodView: UIView!
    @IBOutlet weak var rateFlexibleBtn: UIButton!           // 利率方式 - 機動
    @IBOutlet weak var rateFixedBtn: UIButton!              // 利率方式 - 固定
    @IBOutlet weak var currentRateLabel: UILabel!
    @IBOutlet weak var continueDepositBtn: UIButton!
    @IBOutlet weak var notContinueDepositBtn: UIButton!
    @IBOutlet weak var autoRateFixedBtn: UIButton!          // 自動轉期利率 - 固定
    @IBOutlet weak var autoRateFlexibleBtn: UIButton!       // 自動轉期利率 - 機動
    private var topDropView:ThreeRowDropDownView? = nil
    private var depositTypeDropView:OneRowDropDownView? = nil
    private var periodDropView:OneRowDropDownView? = nil
    private var accountList:[AccountStruct]? = nil      // 帳號列表
    private var accountIndex:Int? = nil                 // 目前選擇轉出帳號
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        topDropView = getUIByID(.UIID_ThreeRowDropDownView) as? ThreeRowDropDownView
        topDropView?.setThreeRow(DepositCombinedToDeposit_Account_Title, "", DepositCombinedToDeposit_Currency_Title, "", DepositCombinedToDeposit_Balance_Title, "")
        topDropView?.frame = topView.frame
        topDropView?.frame.origin = .zero
        topView.addSubview(topDropView!)
        setShadowView(topView)
        topView.layer.borderWidth = Layer_BorderWidth
        topView.layer.borderColor = Gray_Color.cgColor
        
        depositTypeDropView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        depositTypeDropView?.setOneRow(DepositCombinedToDeposit_DepositType_Title, "")
        depositTypeDropView?.frame = depositTypeView.frame
        depositTypeDropView?.frame.origin = .zero
        depositTypeView.addSubview(depositTypeDropView!)
        
        periodDropView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        periodDropView?.setOneRow(DepositCombinedToDeposit_Period_Title, "")
        periodDropView?.frame = periodView.frame
        periodDropView?.frame.origin = .zero
        periodView.addSubview(periodDropView!)
        
        setShadowView(middleView)
        middleView.layer.borderWidth = Layer_BorderWidth
        middleView.layer.borderColor = Gray_Color.cgColor
        
        setShadowView(bottomView)
        AddObserverToKeyBoard()
        setLoading(true)
        getTransactionID("03004", TransactionID_Description)
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
    
    // MARK: - ConnectionUtilityDelegate
    override func didRecvdResponse(_ description:String, _ response: NSDictionary) {
        setLoading(false)
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: "Data") as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                setLoading(true)
                postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else {
                super.didRecvdResponse(description, response)
            }
            
        case "ACCT0101":
            if let data = response.object(forKey: "Data") as? [String:Any], let array = data["Result"] as? [[String:Any]]{
                for category in array {
                    if let type = category["ACTTYPE"] as? String, let result = category["AccountInfo"] as? [[String:Any]], type == Account_Deposit_Type {
                        accountList = [AccountStruct]()
                        for actInfo in result {
                            if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? Double, let ebkfg = actInfo["EBKFG"] as? Int, ebkfg == Account_EnableTrans {
                                accountList?.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
                            }
                        }
                    }
                }
            }
            else {
                super.didRecvdResponse(description, response)
            }
            
        default: super.didRecvdResponse(description, response)
        }
    }
}
