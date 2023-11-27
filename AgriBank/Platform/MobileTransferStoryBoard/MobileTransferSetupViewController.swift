//
//  MobileTransferSetupViewController.swift
//  AgriBank
//
//  Created by 傅意芸 on 2021/8/2.
//  Copyright © 2021 Systex. All rights reserved.
//

import UIKit

let MobileTransferSetup_Account = "註冊帳號"

class MobileTransferSetupViewController: BaseViewController {

    @IBOutlet weak var labelBankName: UILabel!
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelMobile: UILabel!
    @IBOutlet weak var labelAccount: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelState: UILabel!
    @IBOutlet weak var labelNotice: UILabel!
    
    @IBOutlet weak var accountChooseView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    
    @IBOutlet weak var m_scrollView: UIScrollView!
    @IBOutlet weak var m_contentViewHeight: NSLayoutConstraint!
    
    private var mobilePhoneData: [String:Any]? = nil
    private var accountList:[AccountStruct]? = nil      // 帳號列表
    private var myMobileMail: String = ""
    private var myMobilePhone: String = ""
    private var originalAccount: String = ""
    
    private var loginInfo = LoginStrcture()
    private var BankCode = ""
    private var ID = ""
    private var mSetupType: SetupType = .NoSetup        //目前註冊狀態
    private var mSetupAction: ActionSetupType = .Update //目前註冊動作
    
    private enum SetupType: String {
        case NoSetup = "未註冊"
        case Setup = "已註冊"
        case ErrorSetup = "註冊錯誤"
    }
    
    private enum ActionSetupType: String {
        case Setup = "1"
        case Update = "2"
        case Delete = "3"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let info = AuthorizationManage.manage.GetLoginInfo(){
            BankCode = info.bankCode
            ID =  info.aot.uppercased()
            let start = ID.index(ID.startIndex,offsetBy: 4)
            let end = ID.index(ID.startIndex,offsetBy: 3+4)
            ID.replaceSubrange(start..<end, with: "***")
            labelID.text = ID
        }
        
        labelBankName.text = BankChineseName
        setShadowView(bottomView, .Top)
        // Do any additional setup after loading the view.
        
        setLoading(true)
        //取得身分證字號及手機門號
        postRequest("Usif/USIF0101", "USIF0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"110101","Operate":"queryData","TransactionId":transactionId], true), AuthorizationManage.manage.getHttpHead(true))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func onClickChooseAccount(_ sender: Any) {
        if mSetupType == .ErrorSetup || myMobilePhone.isEmpty {
            return
        }
        
        if accountList != nil && accountList?.count ?? 0 > 0 {
            let controller = UIAlertController(title: Choose_Title, message: nil, preferredStyle: .actionSheet)

            for index in accountList! {
                let action = UIAlertAction(title: index.accountNO, style: .default) { (action) in
                    self.labelAccount.text = index.accountNO
                }
                controller.addAction(action)
            }
            let cancelAction = UIAlertAction(title: Cancel_Title, style: .cancel, handler: nil)
            controller.addAction(cancelAction)
            present(controller, animated: true, completion: nil)
        } else {
            showErrorMessage(nil, "\(Get_Null_Title)\(MobileTransfer_InAccout_Title)")
        }
    }
    
    @IBAction func onClickUpdate(_ sender: Any) {
        switch mSetupType {
        case .NoSetup: //註冊帳號
            let checkResult = checkAccountEmptyMsg()
            if checkResult.isEmpty {
                sendSetup(actionType: ActionSetupType.Setup, actionAccount: checkResult.nowAccount)
            }
        case .Setup: //更新帳號
            let checkResult = checkAccountEmptyMsg()
            if checkResult.isEmpty {
                sendSetup(actionType: ActionSetupType.Update, actionAccount: checkResult.nowAccount)
            }
        case .ErrorSetup: //註冊錯誤不會顯示btn
            print("ErrorSetup Left Btn Click")
        }
    }
    
    @IBAction func onClickRight(_ sender: Any) {
        switch mSetupType {
        case .NoSetup: //返回首頁
            enterFeatureByID(.FeatureID_Home, false)
            print("NoSetup")
        case .Setup: //註銷帳號
            showCheckDeleteAgainDlg()
            print("Setup")
        case .ErrorSetup:
            showCheckDeleteAgainDlg()
            print("ErrorSetup") //註銷帳號
        }
    }
    
    override func didResponse(_ description: String, _ response: NSDictionary) {
        switch description {
        case "USIF0101":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any] {
                
                if let mobileMail = data["EMAIL"] as? String {
                    self.myMobileMail = mobileMail
                }
                
                if let mobilePhone = data["MPHONE"] as? String, !mobilePhone.isEmpty {
                    //手機號碼不為空，更新畫面打註冊手機門號資料api
                    myMobilePhone = mobilePhone
                    var phone = mobilePhone.trimmingCharacters(in: .whitespaces)
                    let start = phone.index(phone.startIndex,offsetBy: 4)
                    let end = phone.index(phone.startIndex,offsetBy: 3+4)
                    phone.replaceSubrange(start..<end, with: "***")
                    labelMobile.text = phone
                    
                    postRequest("TRAN/TRAN1001", "TRAN1001", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"15003","Operate":"queryData","TransactionId":transactionId,"MobilePhone":myMobilePhone], true), AuthorizationManage.manage.getHttpHead(true))
                    
                } else {
                    //手機號碼為空，關閉loading，只顯示一個按鈕
                    setLoading(false)
                    btnUpdate.isHidden = true
                    mSetupType = .NoSetup
                    changeBtnText()
                    labelNotice.text = "請注意開戶時未留手機號碼\n欲新增手機號碼請使用晶片金融卡至\nhttps://ebank.naffic.org.tw/ibank 網路銀行\n或臨櫃辦理"
                    restScrollHeight()
                }
                
            }
            else {
                super.didResponse(description, response)
            }
        case "TRAN1001":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any] {
                
                mobilePhoneData = data
                
                if let mobileAccount = data["Actno"] as? String {
                    originalAccount = mobileAccount.trimmingCharacters(in: .whitespaces)
                    labelAccount.text = originalAccount.isEmpty ? "請選擇" : originalAccount
                    if mobileAccount != "" {
                    let mobilebank = mobileAccount.substring(from: 0 ,length: 3)
                
                    if mobilebank != self.BankCode.substring(from: 0,length: 3){
                        let mmsg = "該手機門號" + myMobilePhone + "已設定" + mobilebank + "收款門號，若須變更收款門號請重新登入" + mobilebank + "，註銷原註冊的收款門號後，再重新登入" + self.BankCode.substring(from: 0,length: 3) + "設定收款門號。"
                        showAlert(title: UIAlert_Default_Title, msg: mmsg, confirmTitle: "確認", cancleTitle: nil, completionHandler: {
                            self.enterFeatureByID(.FeatureID_Home, true)
                        }, cancelHandelr: {()})
                    }
                }
                }
                if let mobileDate = data["SetDate"] as? String {
                    labelTime.text = mobileDate.trimmingCharacters(in: .whitespaces)
                }
                
                if let mobileState = data["Status"] as? String {
                    btnUpdate.isHidden = false
                    switch mobileState {
                    case "0":
                        mSetupType = .NoSetup
                        
                        //檢測修改隱碼
                       // myMobilePhone = mobilePhone
                        var phone = myMobilePhone.trimmingCharacters(in: .whitespaces)
                        let start = phone.index(phone.startIndex,offsetBy: 4)
                        let end = phone.index(phone.startIndex,offsetBy: 3+4)
                        phone.replaceSubrange(start..<end, with: "***")
                        labelMobile.text = phone
                        
                        
                       // labelMobile.text = myMobilePhone
                    case "1":
                        mSetupType = .Setup
                    case "2":
                        mSetupType = .ErrorSetup
                        btnUpdate.isHidden = true
                    default:
                        mSetupType = .NoSetup
                        btnUpdate.isHidden = true
                    }
                    labelState.text = mSetupType.rawValue
                    changeBtnText()
                    restScrollHeight()
                }
                
                
                
                //requestAcnt
                postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else {
                super.didResponse(description, response)
            }
            
        case "ACCT0101":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]]{
                for category in array {
                    if let type = category["ACTTYPE"] as? String, let result = category["AccountInfo"] as? [[String:Any]], type == Account_Saving_Type {
                        accountList = [AccountStruct]()
                        for actInfo in result {
                            if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? String, let ebkfg = actInfo["EBKFG"] as? String {
                                accountList?.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
                            }
                        }
                    }
                }
            }
            else {
                super.didResponse(description, response)
            }
            setLoading(false)
        case "TRAN1002":
            setLoading(false)
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String {
                if returnCode == ReturnCode_Success {
                    switch mSetupAction {
                    case .Update: //更新帳號
                        performSegue(withIdentifier: "ShowResult", sender: "恭喜您已成功更新註冊帳號！")
                    case .Setup: //註冊帳號
                        performSegue(withIdentifier: "ShowResult", sender: "恭喜您已成功註冊帳號！")
                    case .Delete: //註銷帳號
                        resetView()
                    }
                }
            }
        case "Mobile_Transfer":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                if let info = AuthorizationManage.manage.getResponseLoginInfo() {
                    setLoading(true)
                    VaktenManager.sharedInstance().authenticateOperation(withSessionID: (info.Token ?? "")) { resultCode in
                        if VIsSuccessful(resultCode) {
                            self.postRequest("Comm/COMM0802", "Mobile_BaseCOMM0802", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"15001","Operate":"KPDeviceCF","TransactionId":tranId,"userIp":self.getIP()], true), AuthorizationManage.manage.getHttpHead(true))
                        }
                        else {
                            self.showErrorMessage(nil, "\(ErrorMsg_Verification_Faild) \(resultCode.rawValue)")
                            self.setLoading(false)
                        }
                    }
                }
            } else {
                enterFeatureByID(.FeatureID_Home, false)
            }
        case "Mobile_BaseCOMM0802":
            //取得身分證字號及手機門號
            postRequest("Usif/USIF0101", "USIF0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"110101","Operate":"queryData","TransactionId":transactionId], true), AuthorizationManage.manage.getHttpHead(true))
        default:
            super.didResponse(description, response)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowResult" {
            let controller = segue.destination as? MobileTransferSetupResultViewController
            var barTitle:String? = nil
            barTitle = "註冊帳號"
            controller?.setBrTitle(barTitle)
            controller?.transactionId = tempTransactionId
            controller?.setMessage(sender as? String ?? "")
            curFeatureID = nil
            tempTransactionId = ""
        }
    }
    
    private func changeBtnText() {
        switch mSetupType {
        case .NoSetup: //返回首頁
            btnRight.setTitle("返回首頁", for: .normal)
            btnUpdate.setTitle("註冊帳號", for: .normal)
            labelNotice.text = "請注意原留手機號碼是否正確!\n欲修改手機號碼請使用晶片金融卡至\nhttps://ebank.naffic.org.tw/ibank 網路銀行\n或臨櫃辦理。\n提醒您：\n1.行動電話號碼為留存於本行系統之行動電話號碼，每一門號只能綁定一個收款帳號。\n2.請確認您所設定的號碼為本人持有，如需更新行動電話號碼，可透過網路銀行或臨櫃辦理。\n3.如變更留存本行之行動電話號碼，請先註銷手機門號轉帳服務。\n4.於他行註冊，本行系統將註銷本服務。\n5.提醒您，於本行留存行動電話號碼有異動時，請確認本服務設定狀態，以免轉帳時發生錯誤。\n6.使用他行「手機門號轉帳」交易，如畫面有銀行代號欄位，請選擇農會行庫代號，不要輸入600、不要點選600。"
        case .Setup: //註銷帳號
            btnRight.setTitle("註銷帳號", for: .normal)
            btnUpdate.setTitle("更新帳號", for: .normal)
            labelNotice.text = "提醒您：\n1.行動電話號碼為留存於本行系統之行動電話號碼，每一門號只能綁定一個收款帳號。\n2.請確認您所設定的號碼為本人持有，如需更新行動電話號碼，可透過網路銀行或臨櫃辦理。\n3.如變更留存本行之行動電話號碼，請先註銷手機門號轉帳服務。\n4.於他行註冊，本行系統將註銷本服務。\n5.提醒您，於本行留存行動電話號碼有異動時，請確認本服務設定狀態，以免轉帳時發生錯誤。\n6.使用他行「手機門號轉帳」交易，如畫面有銀行代號欄位，請選擇農會行庫代號，不要輸入600、不要點選600。"
        case .ErrorSetup:
            btnRight.setTitle("註銷帳號", for: .normal)
            labelNotice.text = "請注意註冊資料不一致!\n請註銷帳號後重新註冊帳號!"
        }
    }
    
    private func checkAccountEmptyMsg() -> (isEmpty: Bool, nowAccount: String) {
        guard let nowAccount = labelAccount.text, !nowAccount.isEmpty, nowAccount != "請選擇" else {
            showAlert(title: UIAlert_Default_Title, msg: "請選擇註冊帳號", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
            return (false, "")
        }
        
        return (true, nowAccount)
    }
    
    private func showCheckDeleteAgainDlg() {
        showAlert(title: UIAlert_Default_Title, msg: "請確認要註銷帳號！", confirmTitle: "確認送出", cancleTitle: Cancel_Title, completionHandler: {
            self.sendSetup(actionType: ActionSetupType.Delete, actionAccount: self.originalAccount)
        }, cancelHandelr: {()})
        
    }
    
    private func sendSetup(actionType: ActionSetupType, actionAccount: String) {
        setLoading(true)
        mSetupAction = actionType
        let actionTypeString = actionType.rawValue
        postRequest("TRAN/TRAN1002", "TRAN1002", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"15004","Operate":"commitTxn","TransactionId":transactionId,"MobilePhone":myMobilePhone,"Actno":actionAccount,"Actcls":actionTypeString,"Token":mobilePhoneData?["Token"] as? String ?? "","MAIL":myMobileMail], true), AuthorizationManage.manage.getHttpHead(true))
    }
    
    private func resetView() {
        mSetupType = .NoSetup
        changeBtnText()
        labelTime.text = ""
        labelAccount.text = "請選擇"
        labelState.text = mSetupType.rawValue
        restScrollHeight()
        
        setLoading(true)
        getTransactionID("15001", "Mobile_Transfer")
    }
    
    private func restScrollHeight() {
        m_contentViewHeight.constant = labelNotice.requiredHeight + labelNotice.frame.minY + 20
        
        m_scrollView.contentSize = CGSize(width: m_scrollView.frame.size.width, height: labelNotice.requiredHeight + labelNotice.frame.minY + 20)
    }
}

extension UILabel {
    
    /// UILabel根據文字的需要的高度
    public var requiredHeight: CGFloat {
        let label = UILabel(frame: CGRect(
            x: 0,
            y: 0,
            width: frame.width,
            height: CGFloat.greatestFiniteMagnitude)
        )
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = font
        label.text = text
        label.attributedText = attributedText
        label.sizeToFit()
        return label.frame.height
    }
}
