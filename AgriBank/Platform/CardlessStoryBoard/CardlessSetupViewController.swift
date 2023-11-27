//
//  CardlessSetupViewController.swift
//  AgriBank
//
//  Created by ABOT on 2022/9/15.
//  Copyright © 2022 Systex. All rights reserved.
//


import UIKit

let Cardless_OutAccout_Title = "提款帳號"
let Cardless_Currency_Ttile = "幣別"
let Cardless_Balance_Ttile = "餘額"
class CardlessSetupViewController: BaseViewController, ThreeRowDropDownViewDelegate, UIActionSheetDelegate, UITextFieldDelegate  {
    @IBOutlet weak var m_vTransOutAccount: UIView!
    @IBOutlet weak var m_vShadowView: UIView!
    

    // 輸入
    @IBOutlet weak var m_vInput: UIView!
    @IBOutlet weak var m_vTransPhone: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var m_tfTransAmount: TextField!
    
    

    private var m_DDTransOutAccount: ThreeRowDropDownView? = nil
    private var accountList:[AccountStruct]? = nil      // 帳號列表
    private var curTextfield:UITextField? = nil
    private var inAccountIndex:Int? = nil
    private var Cardless_Balance:Float? = 0
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        m_DDTransOutAccount = getUIByID(.UIID_ThreeRowDropDownView) as? ThreeRowDropDownView
        m_DDTransOutAccount?.delegate = self
        m_DDTransOutAccount?.setThreeRow(MobileTransfer_OutAccout_Title, Choose_Title, MobileTransfer_Currency_Ttile, "", MobileTransfer_Balance_Ttile, "")
        m_DDTransOutAccount?.frame = CGRect(x:0, y:0, width:m_vTransOutAccount.frame.width, height:m_vTransOutAccount.frame.height)
        m_vTransOutAccount.addSubview(m_DDTransOutAccount!)
        m_vTransOutAccount.layer.borderWidth = Layer_BorderWidth
        m_vTransOutAccount.layer.borderColor = Gray_Color.cgColor
        setShadowView(m_vTransOutAccount)
        m_vTransOutAccount.layer.borderWidth = Layer_BorderWidth
        m_vTransOutAccount.layer.borderColor = Gray_Color.cgColor
        setShadowView(m_vShadowView)
        m_vShadowView.layer.borderWidth = Layer_BorderWidth
        m_vShadowView.layer.borderColor = Gray_Color.cgColor
     
        setShadowView(bottomView, .Top)
        bottomView.layer.borderWidth = Layer_BorderWidth
        bottomView.layer.borderColor = Gray_Color.cgColor
        
        addObserverToKeyBoard()
        addGestureForKeyBoard()
        if transactionId == "" {
            getTransactionID("16001", "Cardless_Description")
        }
        
       // getTransactionID("16001", TransactionID_Description)
       // self.postRequest("Comm/COMM0117", "COMM0117", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"16001","Operate":"getTerms","TransactionId":transactionId,"uid": AgriBank_DeviceID,"MotpDeviceID": MOTPPushAPI.getDeviceID()], true), AuthorizationManage.manage.getHttpHead(true))
        requestAcnt()
 
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
//        case TransactionID_Description:
//            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
//                tempTransactionId = tranId
//                transactionId = tempTransactionId
//                setLoading(true)
//                self.postRequest("Comm/COMM0117", "COMM0117", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"16001","Operate":"getTerms","TransactionId":tempTransactionId,"uid": AgriBank_DeviceID,"MotpDeviceID": MOTPPushAPI.getDeviceID()], true), AuthorizationManage.manage.getHttpHead(true))
//            } else {
//                super.didResponse(description, response)
//            }
       
        case "ACCT0105": // 取得轉出帳號列表
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any],
               let array = data["Result"] as? [[String:Any]]
            {
                getAcntData(array)
                setAcnt()
            }
            else {
                super.didResponse(description, response)
            }
            
        case "TRAN1101": // 預約提款
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any],
               let Id = data["taskId"] as? String
            {
                VaktenManager.sharedInstance().getTasksOperation{ resultCode, tasks  in
                    if VIsSuccessful(resultCode) && tasks != nil {
                        self.cardlesstask(tasks! as! [VTask], Id)
                    }
                    else {
                        self.showErrorMessage(nil, "\(ErrorMsg_GetTasks_Faild) \(resultCode.rawValue)")
                    }
                }
            }
            else {
                
                showErrorMessage(nil, ErrorMsg_No_TaskId)
            }
        case "Cardless_BaseCOMM0802":
            
                self.postRequest("Comm/COMM0115", "COMM0115", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"15002","Operate":"getTerms","TransactionId":transactionId,"uid": AgriBank_DeviceID,"MotpDeviceID": MOTPPushAPI.getDeviceID()], true), AuthorizationManage.manage.getHttpHead(true))
         
        case "Cardless_Description":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                if let info = AuthorizationManage.manage.getResponseLoginInfo() {
                    setLoading(true)
                    VaktenManager.sharedInstance().authenticateOperation(withSessionID: (info.Token ?? "")) { resultCode in
                        if VIsSuccessful(resultCode) {
                            if self.curFeatureID != nil {
                                self.postRequest("Comm/COMM0802", "Cardless_BaseCOMM0802", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"16001","Operate":"KPDeviceCF","TransactionId":self.transactionId,"userIp":self.getIP()], true), AuthorizationManage.manage.getHttpHead(true))
                            }
                        }
                    }
                }
            }
        case "COMM0115":
            if let data = response.object(forKey: ReturnData_Key) as? [String:String] {
               
                if (data["Read"] == "Y") {
              
                }
                else {
                    let controller = getControllerByID(.FeatureID_MobileTransferSetupAcceptRules)
                    (controller as! MobileTransferSetupAcceptRulesViewController).m_dicAcceptData = data
                    (controller as! MobileTransferSetupAcceptRulesViewController).m_nextFeatureID = curFeatureID
                    (controller as! MobileTransferSetupAcceptRulesViewController).transactionId = tempTransactionId
                    navigationController?.pushViewController(controller, animated: true)
                }
            }
      
        default:
            super.didResponse(description, response)
    
        }
    }
    
    override func addObserverToKeyBoard() {
        removeObserverToKeyBoard()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func keyboardWillShow(_ notification:NSNotification) {
        if loginView != nil, !(loginView?.isNeedRise())! {
            view.frame.origin.y = 0
            return
        }
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        
        // 換算 curTextfield 至 self.view的frame
        guard let txf = curTextfield,
              let frame1 = txf.superview?.convert(txf.frame, to: txf.superview?.superview),
              let frame2 = txf.superview?.superview?.superview?.convert(frame1, to: txf.superview?.superview?.superview?.superview),
              let frame3 = txf.superview?.superview?.superview?.superview?.superview?.convert(frame2, to: txf.superview?.superview?.superview?.superview?.superview?.superview)
        else { return }
        
        if (frame3.origin.y + originalY) >= keyboardRectangle.origin.y {
            let height = (frame3.origin.y + originalY + frame3.height) - keyboardRectangle.origin.y
            view.frame.origin.y = originalY - height
        }
    }
    
    
    // MARK: - API
    // 取得帳號列表
    private func requestAcnt() {
        setLoading(true)
        postRequest("ACCT/ACCT0105", "ACCT0105", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"16003","Operate":"getAcnt","TransactionId":transactionId,"GetType":"1"], true), AuthorizationManage.manage.getHttpHead(true))
    }
        // 預約提款確認
        private func requestSignBegin() {
            let dict: [String: String] = ["WorkCode":"16004",
                                          "Operate":"dataConfirm",
                                          "TransactionId":transactionId,
                                          "OUTACT":m_DDTransOutAccount?.getContentByType(.First) ?? "",
                                         
                                          "TXAMT":m_tfTransAmount.text ?? ""
            ]
            
            setLoading(true)
            postRequest("TRAN/TRAN1101", "TRAN1101", AuthorizationManage.manage.converInputToHttpBody(dict, true), AuthorizationManage.manage.getHttpHead(true))
        }
        private func cardlesstask(_ taskList:[VTask], _ taskID:String) {
            var task:VTask? = nil
            for info in taskList {
                if info.taskID == taskID {
                    task = info
                    break
                }
            }
            
            if task != nil, let data = task?.message.data(using: .utf8) {
                do {
                    let jsonDic = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                    
                    let OUTACT = (jsonDic?["OUTACT"] as? String) ?? ""
                    let TXAMT = (jsonDic?["TXAMT"] as? String) ?? ""
                    
                    let confirmRequest = RequestStruct(strMethod: "TRAN/TRAN1102", strSessionDescription: "TRAN1102", httpBody: nil, loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false, timeOut: TIME_OUT_125)
                    
                    var dataConfirm = ConfirmOTPStruct(image: ImageName.CowCheck.rawValue,
                                                       title: Check_Transaction_Title,
                                                       list: [[String:String]](),
                                                       memo: "",
                                                       confirmBtnName: "確認送出",
                                                       resultBtnName: "繼續交易",
                                                       checkRequest: confirmRequest,
                                                       httpBodyList: ["WorkCode":"16004",
                                                                      "Operate":"commitTxn",
                                                                      "TransactionId":transactionId,
                                                                      "OUTACT":OUTACT,
                                                                      "TXAMT":TXAMT,
                                                                      "taskId":taskID],task: task)
                    
                    dataConfirm.list?.append([Response_Key: "提款帳號", Response_Value:OUTACT])
                    dataConfirm.list?.append([Response_Key: "提款金額", Response_Value:TXAMT.separatorThousand()])
                    enterConfirmOTPController(dataConfirm, true)
                }
                catch {
                    showErrorMessage(nil, error.localizedDescription)
                }
            }
        }
        // MARK: - Private
private func getAcntData(_ array: [[String:Any]]) {
    accountList = [AccountStruct]()
            for actInfo in  array {
                if let actNO = actInfo["ACTNO"] as? String, // 帳號
                   let curcd = actInfo["CURCD"] as? String, // 幣別
                   let bal = actInfo["BAL"] as? String, // 帳面餘額
                   let WCARDSTAT = actInfo["WCARDSTAT"] as? String,  // 此帳號狀態 1:正常2:停用3:關閉
                  WCARDSTAT == Cardless_Enable
                {
                    accountList?.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: WCARDSTAT))
                
        
    }
}
}
    // 若轉出帳號只有一筆,則直接秀
    private func setAcnt() {
        if(accountList?.count)! > 0 {
            if let info = accountList?[0] {
                m_DDTransOutAccount?.setThreeRow(Cardless_OutAccout_Title, info.accountNO, Cardless_Currency_Ttile, (info.currency == Currency_TWD ? Currency_TWD_Title:info.currency), Cardless_Balance_Ttile, String(info.balance).separatorThousandDecimal())
                if let infobalance = Float(info.balance) {
                    Cardless_Balance = infobalance
                }
            }
        }else{
            //請使用晶片金融卡至ＡＴＭ設定提款帳號
            let mmsg = "請使用晶片金融卡至ＡＴＭ設定提款帳號"
            showAlert(title: UIAlert_Default_Title, msg: mmsg, confirmTitle: "確認", cancleTitle: nil, completionHandler: {
                self.enterFeatureByID(.FeatureID_Home, true)
            }, cancelHandelr: {()})
        }
    }
    
    private func showOutAccountList() {
        if accountList != nil && (accountList?.count)! > 0 {
            let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
            for index in accountList! {
                actSheet.addButton(withTitle: index.accountNO)
            }
            actSheet.tag = ViewTag.View_AccountActionSheet.rawValue
            actSheet.show(in: view)
        }
        else {
            showErrorMessage(nil, "\(Get_Null_Title)\(m_DDTransOutAccount?.m_lbFirstRowTitle.text ?? "")")
        }
    }
    private func inputIsCorrect() -> Bool {
        // 轉出帳號
        if m_DDTransOutAccount?.getContentByType(.First) == Choose_Title {
            showErrorMessage(nil, "\(Choose_Title)\(m_DDTransOutAccount?.m_lbFirstRowTitle.text ?? "")")
            return false
        }
         
        
        // 轉帳金額
        if (m_tfTransAmount.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(m_tfTransAmount.placeholder ?? "")")
            return false
        }
        if let amount = Int(m_tfTransAmount.text!) {
            if (amount == 0) {
                showErrorMessage(nil, ErrorMsg_Input_Amount)
                return false
            }
            //檢查是否被1000整除
            if (amount % 1000 != 0 ){
                showErrorMessage(nil, ErrorMsg_CardlessamountCheck)
                return false
            }
            //檢查是否超過30000
            if (amount > 30000 ){
                showErrorMessage(nil, ErrorMsg_CardlessamountCheck)
                return false
            }
            
            //檢查是否超過存款餘額
            let wkBalance = Int(Cardless_Balance!)
            if (amount > wkBalance  ){
                showErrorMessage(nil, ErrorMsg_CardlessBalanceCheck)
                return false
            }
        }
        else {
            showErrorMessage(nil, ErrorMsg_Illegal_Character)
            return false
        }
        
       
        return true
    }
    
    
    
    
    // MARK: - ThreeRowDropDownViewDelegate
    func clickThreeRowDropDownView(_ sender: ThreeRowDropDownView) {
        curTextfield?.resignFirstResponder()
        if accountList == nil {
            requestAcnt()
        }
        showOutAccountList()
    }
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet.cancelButtonIndex != buttonIndex {
            switch (actionSheet.tag) {

            case ViewTag.View_AccountActionSheet.rawValue:
                if let info = accountList?[buttonIndex-1] {
                    m_DDTransOutAccount?.setThreeRow(MobileTransfer_OutAccout_Title, info.accountNO, MobileTransfer_Currency_Ttile, (info.currency == Currency_TWD ? Currency_TWD_Title:info.currency), MobileTransfer_Balance_Ttile, String(info.balance).separatorThousandDecimal())
                  
                    m_tfTransAmount.text = ""
                    if let infobalance = Float(info.balance) {
                        Cardless_Balance = infobalance
                    }
                }
                
            default: break
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    

    
    @IBAction func m_btnSendClick(_ sender: Any) {
        guard inputIsCorrect() else { return }
        requestSignBegin()
    }
}

