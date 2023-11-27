//
//  LoanPartialSettIementViewController.swift
//  AgriBank
//
//  Created by ABOT on 2019/10/15.
//  Copyright © 2019 Systex. All rights reserved.
//
import UIKit


let PayLoanPartialSettIement_OutAccount_Title = "轉出帳號"
let PayLoanPartialSettIement_Currency_Title = "幣別"
let PayLoanPartialSettIement_Balance_Title = "餘額"

class PayLoanPartialSettIementViewController: BaseViewController, ThreeRowDropDownViewDelegate, UIActionSheetDelegate {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var LoanActLabel: UILabel!
    @IBOutlet weak var PayAmtLabel: UILabel!
    @IBOutlet weak var DFAmtLabel: UILabel!
    @IBOutlet weak var EAMTLabel: UILabel!
    
    @IBOutlet weak var IsTFlagLabel: UILabel!
    @IBOutlet weak var TotalAmtLabel: UILabel!
    
    
    private var topDropView:ThreeRowDropDownView? = nil
    private var accountList:[AccountStruct]? = nil      // 帳號列表
    private var list:[String:Any]? = nil                // 由LoanPrincipalInterestViewController將資訊傳進來
    private var inAccount:String? = nil                 // 放款帳戶
    private var EAMT:Double? = nil                      //提前清償違約金
    private var PayAmt:String? = nil                       //還本金額
    private var IsTFlg:Bool? = true                     //是否重算期金
    private var TotalPayAmt:Double? = 0                   //實繳金額
    
    // MARK: - Public
    func setList(_ list:[String:Any]?, _ inAccount:String?, _ EAMT:Double?, _ PayAmt:String?, _ IsTFlg:Bool?) {
        self.list = list
        self.inAccount = inAccount
        self.EAMT = EAMT
        self.PayAmt = PayAmt
        self.IsTFlg = IsTFlg
    }
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        topDropView = getUIByID(.UIID_ThreeRowDropDownView) as? ThreeRowDropDownView
        topDropView?.setThreeRow(PayLoanPartialSettIement_OutAccount_Title, Choose_Title, PayLoanPartialSettIement_Currency_Title, "", PayLoanPartialSettIement_Balance_Title, "")
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
        
        setShadowView(bottomView, .Top)
        
        fillDetailData()
        
        setLoading(true)
        postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case "ACCT0101":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]]{
                for category in array {
                    if let type = category["ACTTYPE"] as? String, let result = category["AccountInfo"] as? [[String:Any]], type == Account_Saving_Type {
                        accountList = [AccountStruct]()
                        for actInfo in result {
                            if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? String, let ebkfg = actInfo["EBKFG"] as? String, ebkfg == Account_EnableTrans {
                                accountList?.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
                            }
                        }
                    }
                }
            }
            else {
                super.didResponse(description, response)
            }
            
        default: super.didResponse(description, response)
        }
    }
    
    // MARK: - Private
    private func inputIsCorrect() -> Bool {
        //        if !AuthorizationManage.manage.getPayLoanStatus() {
        //            showErrorMessage(nil, ErrorMsg_NoAuth)
        //            return false
        //        }
        if topDropView?.getContentByType(.First) == Choose_Title {
            showErrorMessage(nil, "\(Choose_Title)\(topDropView?.m_lbFirstRowTitle.text ?? "")")
            return false
        }
        return true
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickSendBtn(_ sender: Any) {
        if inputIsCorrect() {
            let outAccount = topDropView?.getContentByType(.First) ?? "" //轉出帳號
            let inAccount = self.inAccount ?? ""                         //放款帳號
            let sPayAmt = PayAmtLabel.text                                   //還本金額
            let sDFAMT = self.DFAmtLabel.text ?? ""                      //違約金
            let sEAMT = EAMTLabel.text ?? ""                            //提前清償違約金
            let TOTAL = TotalAmtLabel.text                               //實繳金額
            var sISTFLG = "1"                                           //是否重算期金 0:NO 1:YES
            var strISTFLG = "是"
            if let value = IsTFlg {
                if value == true{
                    sISTFLG = "1"
                    strISTFLG = "是"
                }else{
                    sISTFLG = "0"
                    strISTFLG = "否"
                }
            }
            let SINTAMT = list?["SINTAMT"] as? String             //短收利息
            let CACREC = list?["CACREC"] as? String                //累計預收款金額
            let CREAMT = list?["CREAMT"] as? String                //已提存還繳金額
            let REFAMT = list?["REFAMT"] as? String                //未提存還繳金額
            let DFCD = list?["DFCD"] as? String                    //違約金計收方式
            let LTYFLG = list?["LTYFLG"] as? String                //協議分期記號
            let TDFAMT = "0"
            let TINTAMT = "0"
            let curDate = list?["VLDATE"] as? String                //生效日
            
            let confirmRequest = RequestStruct(strMethod: "TRAN/TRAN0802", strSessionDescription: "TRAN0802", httpBody: AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03006","Operate":"commitTxn","TransactionId":transactionId,"PAYACTNO":outAccount,"ACTNOSQNO":inAccount,"TOTAL":TOTAL!.replacingOccurrences(of: ",", with: ""),"SINTAMT":SINTAMT as Any,"CACREC":CACREC as Any,"CREAMT":CREAMT as Any,"EAMT":sEAMT.replacingOccurrences(of: ",", with: ""),"REFAMT":REFAMT as Any,"DFCD":DFCD as Any,"LTYFLG":LTYFLG as Any,"TDFAMT":TDFAMT,"TINTAMT":TINTAMT,"TODIAMT":sDFAMT.replacingOccurrences(of: ",", with: ""),"TPRIAMT":sPayAmt!.replacingOccurrences(of: ",", with: ""),"ISTFLG":sISTFLG,"VLDATE":curDate as Any], true), loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false, timeOut: REQUEST_TIME_OUT)
            var dataConfirm = ConfirmResultStruct(image: ImageName.CowCheck.rawValue, title: Check_Transaction_Title, list: [[String:String]](), memo: "", confirmBtnName: "確認繳交", resultBtnName: "繼續交易", checkRequest: confirmRequest)
            dataConfirm.list?.append([Response_Key: "轉出帳號", Response_Value:outAccount])
            dataConfirm.list?.append([Response_Key: "放款帳號", Response_Value:inAccount])
            dataConfirm.list?.append([Response_Key: "還本金額", Response_Value:sPayAmt as Any])
            dataConfirm.list?.append([Response_Key: "違約金", Response_Value:sDFAMT])
            dataConfirm.list?.append([Response_Key: "提前清償違約金", Response_Value:sEAMT])
            dataConfirm.list?.append([Response_Key: "實繳金額", Response_Value:TOTAL as Any])
            dataConfirm.list?.append([Response_Key: "是否重算期金", Response_Value:strISTFLG])
            enterConfirmResultController(true, dataConfirm, true)
        }
    }
    
    // MARK: - ThreeRowDropDownViewDelegate
    func clickThreeRowDropDownView(_ sender: ThreeRowDropDownView) {
        if accountList != nil {
            let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
            accountList?.forEach{index in actSheet.addButton(withTitle: index.accountNO)}
            actSheet.tag = ViewTag.View_AccountActionSheet.rawValue
            actSheet.show(in: view)
        }
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            switch actionSheet.tag {
            case ViewTag.View_AccountActionSheet.rawValue:
                if let info = accountList?[buttonIndex-1] {
                    topDropView?.setThreeRow(PayLoanPrincipalInterest_OutAccount_Title, info.accountNO, PayLoanPrincipalInterest_Currency_Title, (info.currency == Currency_TWD ? Currency_TWD_Title:info.currency), PayLoanPrincipalInterest_Balance_Title, String(info.balance).separatorThousandDecimal())
                }
                
            default: break
            }
        }
    }
    
    // MARK: - Private
    private func fillDetailData()  {
        
        if let LoanAct = inAccount {
            LoanActLabel.text = LoanAct
        }
        if let oPayAmt = PayAmt{
            PayAmtLabel.text =  oPayAmt.separatorThousand()
            if let Pamt = Double(PayAmt!),let Tamt = TotalPayAmt   {
                TotalPayAmt = Tamt + Pamt
            }
        }
        if let DFAMT = list?["DFAMT"] as? String {
            DFAmtLabel.text = DFAMT.separatorThousand()
            if let Damt = Double(DFAMT),let Tamt = TotalPayAmt   {
                TotalPayAmt = Tamt + Damt
            }
        }
        if let oEAMT = EAMT   {
            EAMTLabel.text = String(oEAMT).separatorThousand()
            if let Tamt = TotalPayAmt   {
                TotalPayAmt = Tamt + EAMT!
            }
        }
        if  let TotAmt =  TotalPayAmt   {
            let StrAmt = String(TotAmt)
            TotalAmtLabel.text = StrAmt.separatorThousand()
        }
        if let oIsTFlag = IsTFlg {
            switch oIsTFlag
            {
            case true:
                IsTFlagLabel.text = "是"
            case false:
                IsTFlagLabel.text = "否"
            }
        }
    }
}
