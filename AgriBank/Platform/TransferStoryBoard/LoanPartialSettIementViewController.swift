//
//  LoanPartialSettIementViewController.swift
//  AgriBank
//
//  Created by ABOT on 2019/10/15.
//  Copyright © 2019 Systex. All rights reserved.
//

import UIKit
let LoanPartialSettIement_PayLoan_Segue = "GoPayPartLoan"
let LoanPartialSettIement_Accout_Title = "放款帳號"
 
class LoanPartialSettIementViewController: BaseViewController, OneRowDropDownViewDelegate, UIActionSheetDelegate {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var middleSeparatorView: UIView!
    @IBOutlet weak var ButtonView: UIView!
    
    @IBOutlet weak var AmountLabel: UILabel!
    @IBOutlet weak var MulctLabel: UILabel!
    @IBOutlet weak var PayLoanAmtLabel: TextField!
    @IBOutlet weak var YesButton: UIButton!
    @IBOutlet weak var NoButton: UIButton!
    @IBOutlet weak var SendButton: UIButton!
    
    private var topDropView:OneRowDropDownView? = nil
    private var accountList:[AccountStruct]? = nil                  // 帳號列表
    private var currentTextField:UITextField? = nil
    private var accountIndex:Int? = nil                             // 目前選擇放款帳號
    private var result:[String:Any]? = nil                          // 電文Response
    private var oneResult:[String:Any]? = nil                       // 電文Response
    private var curIndex:Int? = nil                                 // result["Result"] => Array, Array的Index
    private var memoStatus:String? = nil                            // 是否可部分清償
    private var inputAccount:String? = nil                          // 由「帳戶總覽」帶入的帳號
    private var wkEAMT:Double? = nil                                 //提前清償違約金
    private var IsTFlag:Bool? = true                              //是否重算期金
    private var wkBAL:Double? = nil                                    //餘額
    // MARK: - Public
    func setInitial(_ account:String?)  {
        if accountList != nil && account != nil {
            for index in 0..<(accountList?.count)! {
                if let info = accountList?[index], info.accountNO == account! {
                    accountIndex = index
                    topDropView?.setOneRow(LoanPrincipalInterest_Accout_Title,info.accountNO)
                    break
                }
            }
        }
        else {
            inputAccount = account
        }
    }
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
       
       // setShadowView(middleView!,.Bottom)
        
        topDropView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        topDropView?.setOneRow(LoanPartialSettIement_Accout_Title, Choose_Title)
        topDropView?.frame = topView.frame
        topDropView?.frame.origin = .zero
        topDropView?.delegate = self
        topView.addSubview(topDropView!)
        SendButton.isEnabled = false
        ButtonView.isHidden = true
        addObserverToKeyBoard()
        addGestureForKeyBoard()
        getTransactionID("03006", TransactionID_Description)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == LoanPartialSettIement_PayLoan_Segue {
            let controller = segue.destination as! PayLoanPartialSettIementViewController
            controller.transactionId = transactionId
            controller.setList(result, topDropView?.getContentByType(.First),wkEAMT,PayLoanAmtLabel.text, IsTFlag)
           
        }
       
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                setLoading(true)
                postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else {
                super.didResponse(description, response)
            }
            
        case "ACCT0101":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]] {
                for category in array {
                    if let type = category["ACTTYPE"] as? String, let result = category["AccountInfo"] as? [[String:Any]], type == Account_Loan_Type {
                        accountList = [AccountStruct]()
                        for actInfo in result {
                            if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? String, let ebkfg = actInfo["EBKFG"] as? String {
                                accountList?.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
                            }
                        }
                    }
                }
                
                if inputAccount != nil {
                    for index in 0..<(accountList?.count)! {
                        if let info = accountList?[index], info.accountNO == inputAccount! {
                            accountIndex = index
                            topDropView?.setOneRow(LoanPartialSettIement_Accout_Title,info.accountNO)
                            break
                        }
                    }
                    if accountIndex != nil {
                        setLoading(true)
                        postRequest("TRAN/TRAN0801", "TRAN0801", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03006","Operate":"commitTxn","TransactionId":transactionId,"REFNO":topDropView?.getContentByType(.First) ?? "","PRDCNT":"0"], true), AuthorizationManage.manage.getHttpHead(true))
                    }
                    inputAccount = nil
                }
            }
            else {
                super.didResponse(description, response)
            }
            
        case "TRAN0801":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any] {
                middleView.isHidden = false
              
                result = data
                //放款帳戶餘額
                if let BAL = result?["BAL"] as? String {
                    AmountLabel.text = BAL.separatorThousand()
                    wkBAL = Double(BAL)
                }
                else {
                    AmountLabel.text = ""
                    wkBAL = 0
                }
                //違約金
                if let DFAMT = result?["DFAMT"] as? String {
                    MulctLabel.text = DFAMT.separatorThousand()
                }
                else {
                    MulctLabel.text = ""
                }
                // set 還本金額
                PayLoanAmtLabel.text = ""
                //是否可提前償還
                if let Memo = result?["Memo"] as? String {
                    memoStatus = Memo
                }
            //show msg
                SendButton.isEnabled = false
                ButtonView.isHidden = true
                if memoStatus != nil {
                    var message = ""
                    switch memoStatus! {
                    case "1":
                        message = "請客戶親洽臨櫃辦理結清作業。"
                        
                    case "2":
                        message = "請客戶親洽臨櫃辦理還本作業。"
                        
                    case "3":
                        message = "放款帳戶餘額為0，此交易無法執行，請至臨櫃處理。"
                        
                    case "4":
                        message = "請先執行「繳交放款本息」功能，繳清已逾期的本金利息和其他費用。"
                    case "7":       //chiu 2020/06/10
                        message = "催收戶請洽櫃台"
                        
                    default: break
                    }
                    if !message.isEmpty {
                        middleView.isHidden = true
                        let alert = UIAlertView(title: UIAlert_Default_Title, message: message, delegate: nil, cancelButtonTitle:Determine_Title)
                        alert.show()
                    }
                    else {
                        SendButton.isEnabled = true
                        ButtonView.isHidden = false
                         middleView.isHidden = false
                    }
                }
                else {
                    showErrorMessage(nil, "Memo狀態不明")
                }
                
            }
            else {
                middleView.isHidden = true
              // middleSeparatorView.isHidden = true
                super.didResponse(description, response)
            }
        case "COMM0701":
            //sweney 1100226 三點半後可以交易 status ==
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]],  let status = array.first?["CanTrans"] as? String, status == Can_Transaction_Status {
                self.setLoading(true)
            //取生效日 send 0803 get 違約金
                if (self.result?["VLDATE"] as? String) != nil {
                
                    self.postRequest("TRAN/TRAN0803", "TRAN0803", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03006","Operate":"commitTxn","TransactionId":self.transactionId,"REFNO":self.topDropView?.getContentByType(.First) ?? "","TPRIAMT":Int(self.PayLoanAmtLabel.text!) ?? 0,"VLDATE":self.result?["VLDATE"] as? String ?? "" ], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else{
                self.showErrorMessage(nil, "查詢提前清償違約金時發生錯誤！")
            }
            }else{
                //sweney 1100226 start 三點半後可以交易
                let confirmHandler : ()->Void = {  //sweney 1100226  三點半後可以交易
                    self.setLoading(true)
                //取生效日 send 0803 get 違約金
                    if (self.result?["VLDATE"] as? String) != nil {
                    
                        self.postRequest("TRAN/TRAN0803", "TRAN0803", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03006","Operate":"commitTxn","TransactionId":self.transactionId,"REFNO":self.topDropView?.getContentByType(.First) ?? "","TPRIAMT":Int(self.PayLoanAmtLabel.text!) ?? 0,"VLDATE":self.result?["VLDATE"] as? String ?? "" ], true), AuthorizationManage.manage.getHttpHead(true))
                }
                else{
                    self.showErrorMessage(nil, "查詢提前清償違約金時發生錯誤！")
                }
                    
            }
                let cancelHandler : ()->Void = {
                     
                }
                showAlert(title: "注意", msg: ErrorMsg_TransTime_check , confirmTitle: "確認送出", cancleTitle: "取消", completionHandler: confirmHandler, cancelHandelr: cancelHandler)
            }
//            else {
//                showErrorMessage(nil, ErrorMsg_IsNot_TransTime)
//            }
        case "TRAN0803":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any] {
                middleView.isHidden = false
                 // result = data
                if  let EAMT = data["EAMT"] as? String {
                    wkEAMT = Double(EAMT)
                }
                performSegue(withIdentifier: LoanPartialSettIement_PayLoan_Segue, sender: nil)
            }
            else {
                super.didResponse(description, response)
            }
            
        default: super.didResponse(description, response)
        }
    }
    
    
    
    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        if accountList != nil && accountList?.count != 0 {
            let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
            for index in accountList! {
                actSheet.addButton(withTitle: index.accountNO)
            }
            actSheet.tag = ViewTag.View_AccountActionSheet.rawValue
            actSheet.show(in: view)
        }
        else {
            showErrorMessage(nil, "\(Get_Null_Title)\(sender.m_lbFirstRowTitle.text!)")
        }
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            switch actionSheet.tag {
            case ViewTag.View_AccountActionSheet.rawValue:
                accountIndex = buttonIndex-1
                topDropView?.setOneRow(LoanPartialSettIement_Accout_Title, actionSheet.buttonTitle(at: buttonIndex) ?? "")
                setLoading(true)
             postRequest("TRAN/TRAN0801", "TRAN0801", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03006","Operate":"commitTxn","TransactionId":transactionId,"REFNO":topDropView?.getContentByType(.First) ?? "","PRDCNT":"0"], true), AuthorizationManage.manage.getHttpHead(true))// PRDCNT:繳息期數=>0-為查回全部,1-為可繳交第一期
                
            default: break
            }
        }
    }
 
    @IBAction func BtnSend(_ sender: Any) {
        if  inputIsCorrect(){
                        postRequest("COMM/COMM0701", "COMM0701", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03004","Operate":"queryData"], false), AuthorizationManage.manage.getHttpHead(false))
        }
        
        
    }
    
    // MARK: - Private
    private func inputIsCorrect() -> Bool {
        //check bank
        if topDropView?.getContentByType(.First) == Choose_Title {
            showErrorMessage(nil, "\(Choose_Title)\((topDropView?.m_lbFirstRowTitle.text)!)")
            return false
        }
        //轉入帳號檢核
        if PayLoanAmtLabel.text!.isEmpty  {
            showErrorMessage(nil, "請輸入還本金額")
            return false
        }else{
            if let amount = Int(PayLoanAmtLabel.text!) {
                if amount == 0 {
                    showErrorMessage(nil, ErrorMsg_Input_Amount)
                    return false
                }
            }
        }
        if let payamt = Int(PayLoanAmtLabel.text!){
            let amt = Int(wkBAL!)
            if payamt > amt{
                showErrorMessage(nil, "還本金額不可大於目前本金餘額")
                return false
            }
            if payamt == amt{
                showErrorMessage(nil, "請親洽臨櫃辦理全部清償作業")
                return false
            }
        }
        return true
    }
    
   
    // MARK: - StoryBoard Touch Event
    @IBAction func clickDepositBtn(_ sender: Any) {
        let btn = sender as? UIButton
        if btn == YesButton {
            IsTFlag = true
            YesButton.setImage(UIImage(named: ImageName.RadioOn.rawValue), for: .normal)
            NoButton.setImage(UIImage(named: ImageName.RadioOff.rawValue), for: .normal)
        }
        else {
            IsTFlag = false
            NoButton.setImage(UIImage(named: ImageName.RadioOn.rawValue), for: .normal)
            YesButton.setImage(UIImage(named: ImageName.RadioOff.rawValue), for: .normal)
            
        }
    }
    
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentTextField = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    // MARK: - KeyBoard
    override func keyboardWillShow(_ notification:NSNotification) {
        if   currentTextField == PayLoanAmtLabel   {
            super.keyboardWillShow(notification)
        }
    }
}
