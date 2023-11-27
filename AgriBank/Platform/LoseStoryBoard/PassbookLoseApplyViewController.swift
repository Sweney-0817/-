//
//  LosePassbookViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/6/23.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit
import LocalAuthentication

let PsbookLoseApply_Aot_Title = "存摺帳號"
let PsbookLoseApply_Memo = "請您本人攜帶身分證及原留印鑑來行辦理取消掛失或重新申請作業"

class PassbookLoseApplyViewController: BaseViewController, OneRowDropDownViewDelegate, UIActionSheetDelegate, ImageConfirmViewDelegate,PodConfirmViewDelegate,GestureVerifyDelegate {
    func clickGestureVerCloseBtn(_ ClossStatus: Bool) {
        // 開啟手勢滑動選單
  //       if ClossStatus == true {
  //           if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
  //               (rootViewController as! SideMenuViewController).SetGestureStatus(true)
  //           }}
          GestureVerifyView?.removeFromSuperview()
          GestureVerifyView = nil
          GestureVerifyView?.setNeedsDisplay()
        
      }
    
    func GestureVerifyBtn(bankCode:String,success:NSInteger ) {
        // AuthorizationManage.manage.SetLoginInfo(info)
        switch success
        {
        case 1:
            SendLostInfo()
    //失敗改密碼登入
      case 0:
            self.clickGestureVerCloseBtn(true)
            PodConfirmFlag = true
            setPodConfirmView()
           // SendFastLogInError(bankCode)
        default:
            break
        }
    }
    
    @IBOutlet weak var m_vShadowView: UIView!
    @IBOutlet weak var m_vDropDownView: UIView!
    @IBOutlet weak var m_vImageConfirmView: UIView!
    @IBOutlet weak var bottomView: UIView!
    private var m_OneRow:OneRowDropDownView? = nil
    private var m_ImageConfirmView:ImageConfirmView? = nil
    private var m_PodConfirmView: PodConfirmView? = nil
    private var accountList:[AccountStruct]? = nil      // 帳號列表
    private var accountIndex:Int? = nil                 // 目前選擇轉出帳號
    private var pod = ""
    private var curTextfield:UITextField? = nil
    private var podTextfield:UITextField? = nil //密碼用
    
    //20220325-檢測修改密碼及塊登驗證
    let CheckLoseApply_Bill_Max_Length:Int = 10
    var GestureVerifyView:GestureVerify? = nil        // 圖形密碼頁
    var PodConfirmFlag = false
    var context = LAContext()
    
    var wkLogInCode = ""
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        setAllSubView()
        setShadowView(m_vShadowView)
        setShadowView(bottomView, .Top)
        getTransactionID("04001", TransactionID_Description)
        addGestureForKeyBoard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func keyboardWillShow(_ notification: NSNotification) {
            super.keyboardWillShow(notification)
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
        case "COMM0110":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any] , let GrpPod = data[GraphPWD_Key] as? String{
                if GrpPod == "" {
                    let alert = UIAlertView(title: UIAlert_Default_Title, message: "尚未設定快速登入！", delegate: nil, cancelButtonTitle:Determine_Title)
                    //寫入目前快登項目 0:pod 1:touchid/faceid 2:picture(1 byte)
                      if let info = AuthorizationManage.manage.GetLoginInfo(){
                    SecurityUtility.utility.writeFileByKey("0" + info.aot  , SetKey: info.bankCode , setEncryptKey: "\(SEA1)\(SEA2)\(SEA3)")
                        alert.show()}
                }else{
                    showGestureVerifyView(wkPod: GrpPod)}
            }
        case "ACCT0101":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]] {
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
                
                getImageConfirm(transactionId)
            }
            else {
                super.didResponse(description, response)
            }
            
        case "COMM0501":
            if let responseImage = response[RESPONSE_IMAGE_KEY] as? UIImage {
                m_ImageConfirmView?.m_ivShow.image = responseImage
            }
            
        case "COMM0502":
            if let flag = response[RESPONSE_IMAGE_CONFIRM_RESULT_KEY] as? String, flag == ImageConfirm_Success {
                setLoading(true)
                postRequest("LOSE/LOSE0101", "LOSE0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"04001","Operate":"setLoseAcnt","TransactionId":transactionId,"REFNO":accountList?[accountIndex!].accountNO ?? ""], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else {
                m_ImageConfirmView?.m_tfInput.text = ""
                getImageConfirm(transactionId)
                showErrorMessage(nil, ErrorMsg_Image_ConfirmFaild)
            }
        case "USIF0304":
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode == ReturnCode_Success {
                
                SendLostInfo()
//                setLoading(true)
//                postRequest("LOSE/LOSE0101", "LOSE0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"04001","Operate":"setLoseAcnt","TransactionId":transactionId,"REFNO":accountList?[accountIndex!].accountNO ?? ""], true), AuthorizationManage.manage.getHttpHead(true))
            }
        case "LOSE0101":
            var result = ConfirmResultStruct()
            result.resultBtnName = "繼續交易"
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode == ReturnCode_Success {
                result.title = Lose_Successful_Title
                result.image = ImageName.CowSuccess.rawValue
                result.memo = PsbookLoseApply_Memo
                if let data = response.object(forKey:ReturnData_Key) as? [String:String] {
                    result.list = [[String:String]]()
                    result.list?.append([Response_Key:"交易時間",Response_Value:data["TXTIME"] ?? ""])
                    result.list?.append([Response_Key:"掛失日期",Response_Value:data["TXDAY"] ?? ""])
                }
            }
            else {
                result.title = Lose_Faild_Title
                result.image = ImageName.CowFailure.rawValue
                if let message = response.object(forKey:ReturnMessage_Key) as? String {
                    result.list = [[String:String]]()
                    result.list?.append([Response_Key:Error_Title,Response_Value:message])
                }
            }
            enterConfirmResultController(false, result, true)
            
        default: super.didResponse(description, response)
        }
    }
    func clickGestureShowVerifyBtn( _ info:LoginStrcture ) {
        AuthorizationManage.manage.SetLoginInfo(info)
         self.postRequest("Comm/COMM0110", "COMM0110",  AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10001","Operate":"termsConfirm","KINBR":info.bankCode,"uid": AgriBank_DeviceID], true), AuthorizationManage.manage.getHttpHead(true))
       // showGestureView( )
    }
    func showGestureVerifyView(wkPod: String) {
        if GestureVerifyView == nil {
            //關掉手勢滑動選單
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                (rootViewController as! SideMenuViewController).SetGestureStatus(false)
            }
            GestureVerifyView = getUIByID(.UIID_GestureVerify) as? GestureVerify
            GestureVerifyView?.frame = CGRect(origin: .zero, size: view.frame.size)
            GestureVerifyView?.delegate = self as? GestureVerifyDelegate
            GestureVerifyView?.pod = wkPod
            if let info = AuthorizationManage.manage.GetLoginInfo() {
                GestureVerifyView?.m_BankCode = info.bankCode
                GestureVerifyView?.m_account = info.aot
            }
            view.addSubview(GestureVerifyView!)
            addObserverToKeyBoard()
            addGestureForKeyBoard()
        }
    }
    func InitFastLogIncheck() -> Bool {
#if DEBUG
#else
        if SecurityUtility.utility.isJailBroken() {
            //JB close faceid
            return false
        }
#endif
        var sAot  = ""
        var sbankcode = ""
        if let info = AuthorizationManage.manage.GetLoginInfo(){
            sAot = info.aot
            sbankcode = info.bankCode
        }
        var wkFastLogInFlag = "0"
        wkFastLogInFlag = SecurityUtility.utility.readFileByKey( SetKey: sbankcode, setDecryptKey: "\(SEA1)\(SEA2)\(SEA3)")  as? String ?? "0"
        wkLogInCode = wkFastLogInFlag.substring(from: 0, length: 1)
        let wkID = wkFastLogInFlag.substring(from: 1)
        if (wkFastLogInFlag == "00000000000"){
            return false
        }else
        if wkID.localizedUppercase != sAot.localizedUppercase  && wkID != "" {
            wkLogInCode = "0"
            return false
        }
        else{
            if wkLogInCode == "0"{
                return false
            } else {
                return true
            }
          
            //wkLogInCode 1 faceid 2圖形
        }
    }
    
    // 取得生物辨識
    func showFaceIDConfirm( ) {
        self.context = LAContext()
        if #available(iOS 10.0, *) {
            context.localizedCancelTitle = "取消"
        }
        var error: NSError?
        if #available(iOS 9.0, *) {
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "請使用指紋驗證交易"
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason )
                {
                    success, error in
                    if success {
                        //回到主執行緒
                        OperationQueue.main.addOperation {
                            self.SendLostInfo()
                        }
                    }
                    else{
                        //回到主執行緒
                        OperationQueue.main.addOperation {
                            self.PodConfirmFlag = true
                            self.setPodConfirmView()
                        }
                    }
                    
                }  } }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        curTextfield = textField
        //podTextfield = textField
        return true
    }
    
   
    // MARK: - Private
     private func setAllSubView() {
        setDropDownView()
        //setImageConfirmView()
         setPodConfirmView()
    }

    private func setDropDownView() {
        if m_OneRow == nil {
            m_OneRow = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
            m_OneRow?.delegate = self
            m_OneRow?.setOneRow(PsbookLoseApply_Aot_Title, Choose_Title)
            m_vDropDownView.addSubview(m_OneRow!)
        }
        m_OneRow?.frame = CGRect(x:0, y:0, width:m_vDropDownView.frame.width, height:(m_OneRow?.getHeight())!)
        m_vDropDownView.layer.borderColor = Gray_Color.cgColor
        m_vDropDownView.layer.borderWidth = 1
    }
    
    private func setImageConfirmView() {
        if m_ImageConfirmView == nil {
            m_ImageConfirmView = getUIByID(.UIID_ImageConfirmView) as? ImageConfirmView
            m_ImageConfirmView?.delegate = self
            m_vImageConfirmView.addSubview(m_ImageConfirmView!)
        }
        m_ImageConfirmView?.frame = CGRect(x:0, y:0, width:m_vImageConfirmView.frame.width, height:m_vImageConfirmView.frame.height)
        m_vImageConfirmView.layer.borderColor = Gray_Color.cgColor
        m_vImageConfirmView.layer.borderWidth = 1
    }
    
    private func inputIsCorrect() -> Bool {
        if accountIndex == nil {
            showErrorMessage(nil, "\(Choose_Title)\(m_OneRow?.m_lbFirstRowTitle.text ?? "")")
            return false
        }
        return true
    }
    
    private func setPodConfirmView() {
        if  !InitFastLogIncheck() || PodConfirmFlag == true {
       
            if m_PodConfirmView == nil {
                m_PodConfirmView = getUIByID(.UIID_PodConfirmView) as? PodConfirmView
                m_PodConfirmView?.delegate = self
                for view in m_vImageConfirmView.subviews {
                    view.removeFromSuperview()
                }
                m_vImageConfirmView.addSubview(m_PodConfirmView!)
                m_PodConfirmView?.frame = CGRect(x:0, y:0, width:m_vImageConfirmView.frame.width, height:m_vImageConfirmView.frame.height)
            }
        }else{
            if wkLogInCode == "1" {
                let  m_MemoView = getUIByID(.UIID_MemoView) as? MemoView
                m_MemoView?.set("  使用生物辨識(FaceId/指紋)驗證交易")
                for view in m_vImageConfirmView.subviews {
                    view.removeFromSuperview()
                }
                m_vImageConfirmView.addSubview(m_MemoView!)
                m_MemoView?.frame = CGRect(x:0, y:0, width:m_vImageConfirmView.frame.width, height:m_vImageConfirmView.frame.height)
            }
            else if wkLogInCode  == "2" {
                let  m_MemoView = getUIByID(.UIID_MemoView) as? MemoView
                for view in m_vImageConfirmView.subviews {
                    view.removeFromSuperview()
                }
                m_MemoView?.set("  使用圖形密碼驗證交易")
                m_vImageConfirmView.addSubview(m_MemoView!)
                m_MemoView?.frame = CGRect(x:0, y:0, width:m_vImageConfirmView.frame.width, height:m_vImageConfirmView.frame.height)
            }
        }
        m_vImageConfirmView.layer.borderColor = Gray_Color.cgColor
        m_vImageConfirmView.layer.borderWidth = 1
    }

    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        if accountList != nil {
            if (accountList?.count)! > 0 {
                let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
                accountList?.forEach{index in actSheet.addButton(withTitle: index.accountNO)}
                actSheet.tag = ViewTag.View_AccountActionSheet.rawValue
                actSheet.show(in: view)
            }
            else {
                showErrorMessage(nil, "\(Get_Null_Title)\(sender.m_lbFirstRowTitle.text!)")
            }
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
                if let info = accountList?[accountIndex!] {
                    m_OneRow?.setOneRow(PsbookLoseApply_Aot_Title, info.accountNO)
                }
                
            default: break
            }
        }
    }
    
    // MARK: - ImageConfirmCellDelegate
    func clickRefreshBtn() {
        getImageConfirm(transactionId)
    }
    
    func changeInputTextfield(_ input: String) {
        pod = input
    }
    func SendLostInfo() {
        setLoading(true)
            postRequest("LOSE/LOSE0101", "LOSE0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"04001","Operate":"setLoseAcnt","TransactionId":transactionId,"REFNO":accountList?[accountIndex!].accountNO ?? ""], true), AuthorizationManage.manage.getHttpHead(true))
    }
    
    func ImageConfirmTextfieldBeginEditing(_ textfield:UITextField) {
        podTextfield = textfield
    }
    func PODConfirmTextfieldBeginEditing(_ textfield: UITextField) {
        podTextfield = textfield
    }
    func SendPodVerify()
    {
        if self.podTextfield?.text == "" || self.podTextfield == nil {
            let alert = UIAlertView(title: UIAlert_Default_Title, message: "請輸入使用者密碼！", delegate: nil, cancelButtonTitle:Determine_Title)
             alert.show()
            
        }else{
        //E2E
            // let fmt = DateFormatter()
             //let timeZone = TimeZone.ReferenceType.init(abbreviation:"UTC") as TimeZone?
             //fmt.timeZone = timeZone
             //fmt.dateFormat = "yyyy/MM/dd HH:mm:ss"
             //let loginDateTIme: String = fmt.string(from: Date())
             let loginDateTIme: String = Date().date2String(dateFormat: "yyyy/MM/dd HH:mm:ss")
        let pdMd50 = pod + loginDateTIme
       let pdMd5 = E2E.e2Epod(E2EKeyData, pod:pdMd50)
       //109-10-16 add by sweney for check e2e key

       //E2E
       setLoading(true)
        self.postRequest("Usif/USIF0304", "USIF0304",  AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"08006","Operate":"dataConfirm","TransactionId":transactionId,"DWP": pdMd5  ], true), AuthorizationManage.manage.getHttpHead(true))
        }}
    // MARK: - StoryBoard Touch Event
    @IBAction func m_btnSendClick(_ sender: Any) {
      if inputIsCorrect() {
            //checkImageConfirm(pod, transactionId)
          if wkLogInCode == "1" && PodConfirmFlag == false {
              showFaceIDConfirm()
          }else if wkLogInCode == "2" && PodConfirmFlag == false {
              if let info = AuthorizationManage.manage.GetLoginInfo(){
                  clickGestureShowBtn(info)
              }
          }else{
              SendPodVerify()
          }
       }
    }
}
