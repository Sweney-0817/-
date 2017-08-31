//
//  PayLoanPrincipalInterestViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/10.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let PayLoanPrincipalInterest_OutAccount_Title = "轉出帳號"
let PayLoanPrincipalInterest_Currency_Title = "幣別"
let PayLoanPrincipalInterest_Balance_Title = "餘額"

class PayLoanPrincipalInterestViewController: BaseViewController, ThreeRowDropDownViewDelegate, UIActionSheetDelegate {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var calculatePeroidLabel: UILabel! // 計算期間
    @IBOutlet weak var rateLabel: UILabel! // 利率
    @IBOutlet weak var breakContractDayLabel: UILabel! // 違約天數
    @IBOutlet weak var needPayPrincipalLabel: UILabel! // 應繳本金
    @IBOutlet weak var needPayBreakContractLabel: UILabel! // 應繳違約金
    @IBOutlet weak var needPayInterestLabel: UILabel! // 應繳利息
    @IBOutlet weak var needPayDelayInterestLabel: UILabel! // 應繳逾期息
    @IBOutlet weak var lastShortAmountLabel: UILabel! // 上次短收金額
    @IBOutlet weak var needPayAmountLabel: UILabel! // 應繳總額
    private var topDropView:ThreeRowDropDownView? = nil
    private var accountList:[AccountStruct]? = nil      // 帳號列表
    private var list:[String:Any]? = nil                // 由LoanPrincipalInterestViewController將資訊傳進來
    private var inAccount:String? = nil                 // 放款帳戶
    
    // MARK: - Public
    func setList(_ list:[String:Any]?, _ inAccount:String?) {
        self.list = list
        self.inAccount = inAccount
    }
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        topDropView = getUIByID(.UIID_ThreeRowDropDownView) as? ThreeRowDropDownView
        topDropView?.setThreeRow(PayLoanPrincipalInterest_OutAccount_Title, "", PayLoanPrincipalInterest_Currency_Title, "", PayLoanPrincipalInterest_Balance_Title, "")
        topDropView?.frame = topView.frame
        topDropView?.frame.origin = .zero
        topDropView?.delegate = self
        topView.addSubview(topDropView!)
        topView.layer.borderWidth = Layer_BorderWidth
        topView.layer.borderColor = Gray_Color.cgColor
        setShadowView(topView)
        
        middleView.layer.borderWidth = Layer_BorderWidth
        middleView.layer.borderColor = Gray_Color.cgColor
        setShadowView(middleView)
        
        setShadowView(bottomView)
        
        fillDetailData()
        setLoading(true)
        postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickSendBtn(_ sender: Any) {
        if (topDropView?.getContentByType(.First).isEmpty)! {
            showErrorMessage(nil, ErrorMsg_Choose_OutAccount)
        }
        else {
            setLoading(true)
            postRequest("COMM/COMM0701", "COMM0701", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03004","Operate":"queryData"], true), AuthorizationManage.manage.getHttpHead(true))
        }
    }

    // MARK: - ThreeRowDropDownViewDelegate
    func clickThreeRowDropDownView(_ sender: ThreeRowDropDownView) {
        if accountList != nil {
            let actSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: UIActionSheet_Cancel_Title, destructiveButtonTitle: nil)
            for index in accountList! {
                actSheet.addButton(withTitle: index.accountNO)
            }
            actSheet.tag = ViewTag.View_AccountActionSheet.rawValue
            actSheet.show(in: view)
        }
    }
    
    // MARK: - ConnectionUtilityDelegate
    override func didRecvdResponse(_ description:String, _ response: NSDictionary) {
        setLoading(false)
        switch description {
        case "ACCT0101":
            if let data = response.object(forKey: "Data") as? [String:Any], let array = data["Result"] as? [[String:Any]]{
                for category in array {
                    if let type = category["ACTTYPE"] as? String, let result = category["AccountInfo"] as? [[String:Any]], type == Account_Saving_Type {
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
            
        case "COMM0701":
//            if let data = response.object(forKey: "Data") as? [String:Any], let status = data["CanTrans"] as? Int, status == Can_Transaction_Status, let date = data["CurrentDate"] as? String {
            if let data = response.object(forKey: "Data") as? [String:Any], let date = data["CurrentDate"] as? String {
                let outAccount = topDropView?.getContentByType(.First) ?? ""
                let inAccount = self.inAccount ?? ""
                var APAMT = ""
                if let value = list?["APAMT"] as? String {
                    APAMT = value
                }
                var ACTBAL = ""
                if let value = list?["ACTBAL"] as? String {
                    ACTBAL = value
                }
                let TOTAL = needPayAmountLabel.text ?? ""
                let TPRIAMT = needPayPrincipalLabel.text ?? ""
                let TINTAMT = needPayInterestLabel.text ?? ""
                let TODIAMT = needPayDelayInterestLabel.text ?? ""
                let TDFAMT = needPayBreakContractLabel.text ?? ""
                let SINTAMT = lastShortAmountLabel.text ?? ""
                var ACRECAMT = ""
                if let value = list?["ACRECAMT"] as? String {
                    ACRECAMT = value
                }
                let FITIRT = rateLabel.text ?? ""
                let DFDAYS = breakContractDayLabel.text ?? ""
                
                let confirmRequest = RequestStruct(strMethod: "TRAN/TRAN0602", strSessionDescription: "TRAN0602", httpBody: AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03006","Operate":"commitTxn","TransactionId":transactionId,"PAYACTNO":outAccount,"ACTNOSQNO":inAccount,"APAMT":APAMT,"ACTBAL":ACTBAL,"TOTAL":TOTAL,"TPRIAMT":TPRIAMT,"TINTAMT":TINTAMT,"TODIAMT":TODIAMT,"TDFAMT":TDFAMT,"SINTAMT":SINTAMT,"ACRECAMT":ACRECAMT,"FITIRT":FITIRT,"DFDAYS":DFDAYS,"VLDATE":date], true), loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false)
                
                var dataConfirm = ConfirmResultStruct(image: ImageName.CowCheck.rawValue, title: Check_Transaction_Title, list: [[String:String]](), memo: "", confirmBtnName: "確認繳交", resultBtnName: "繼續交易", checkRequest: confirmRequest)
                dataConfirm.list?.append([Response_Key: "轉出帳號", Response_Value:outAccount])
                dataConfirm.list?.append([Response_Key: "放款帳號", Response_Value:inAccount])
                dataConfirm.list?.append([Response_Key: "計算期間", Response_Value:calculatePeroidLabel.text ?? ""])
                dataConfirm.list?.append([Response_Key: "利率", Response_Value:FITIRT])
                dataConfirm.list?.append([Response_Key: "違約天數", Response_Value:DFDAYS])
                dataConfirm.list?.append([Response_Key: "應繳本金", Response_Value:TPRIAMT])
                dataConfirm.list?.append([Response_Key: "應繳違約金", Response_Value:TDFAMT])
                dataConfirm.list?.append([Response_Key: "應繳利息", Response_Value:TINTAMT])
                dataConfirm.list?.append([Response_Key: "應繳逾期息", Response_Value:TODIAMT])
                dataConfirm.list?.append([Response_Key: "上次短收金額", Response_Value:SINTAMT])
                dataConfirm.list?.append([Response_Key: "應繳總額", Response_Value:TOTAL])
                enterConfirmResultController(true, dataConfirm, true)
            }
            else {
                showErrorMessage(nil, ErrorMsg_IsNot_TransTime)
            }
            
        default: super.didRecvdResponse(description, response)
        }
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            switch actionSheet.tag {
            case ViewTag.View_AccountActionSheet.rawValue:
                if let info = accountList?[buttonIndex-1] {
                    topDropView?.setThreeRow(PayLoanPrincipalInterest_OutAccount_Title, info.accountNO, PayLoanPrincipalInterest_Currency_Title, info.currency, PayLoanPrincipalInterest_Balance_Title, String(info.balance))
                }
        
            default: break
            }
        }
    }
    
    // MARK: - Private
    private func fillDetailData()  {
        if let array = list?["Result"] as? [[String:String]], let dic = array.first {
            calculatePeroidLabel.text = "\(dic["SDATE"] ?? "") - \(dic["EDATE"] ?? "")"
        }
        if let FITIRT = list?["FITIRT"] as? String {
            rateLabel.text = FITIRT
        }
        if let DFDAYS = list?["DFDAYS"] as? String {
            breakContractDayLabel.text = DFDAYS
        }
        if let TPRIAMT = list?["TPRIAMT"] as? String {
            needPayPrincipalLabel.text = TPRIAMT
        }
        if let TDFAMT = list?["TDFAMT"] as? String {
            needPayBreakContractLabel.text = TDFAMT
        }
        if let TINTAMT = list?["TINTAMT"] as? String {
            needPayInterestLabel.text = TINTAMT
        }
        if let TODIAMT = list?["TODIAMT"] as? String {
            needPayDelayInterestLabel.text = TODIAMT
        }
        if let SINTAMT = list?["SINTAMT"] as? String {
            lastShortAmountLabel.text = SINTAMT
        }
        if let TOTAL = list?["TOTAL"] as? String {
            needPayAmountLabel.text = TOTAL
        }
    }
}
