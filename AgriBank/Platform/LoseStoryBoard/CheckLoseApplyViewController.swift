//
//  CheckLoseApplyViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/6/28.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit
import LocalAuthentication

let CheckLoseApply_ChooseType_Title = "掛失類別"
let CheckLoseApply_TypeList = ["支票掛失止付","空白支票掛失"]
let CheckLoseApply_CheckAccount_Title = "支票帳號"
let CheckLoseApply_Date_Title = "發票日"
let CheckLoseApply_TransAccount_Title = "手續費轉帳帳號"
let CheckLoseApply_FEE_Title = "手續費"
let CheckLoseApply_Memo = "提出支票掛失後，須依照「票據掛失止付處理規範」之有關規定辦理。\n第四條：通知止付人應於提出止付通知書後五日內，向付款行庫提出已為聲請公示催告之證明，否則止付通知失其效力。嗣後通知止付人不得對同一票據為止付之通知。若票據掛失止付通知撤銷或未於規定時間內辦理公示催告，付款行社應通知票據交換所。" //chiu 2020/06/09


class CheckLoseApplyViewController: BaseViewController, OneRowDropDownViewDelegate, UIActionSheetDelegate, ImageConfirmViewDelegate, UITextFieldDelegate ,PodConfirmViewDelegate,GestureVerifyDelegate{
    
    
    @IBOutlet weak var m_vShadowView: UIView!
    @IBOutlet weak var m_vDDType: UIView!
    @IBOutlet weak var m_vDDAccount: UIView!
    @IBOutlet weak var m_vCheckNumber: UIView!
    @IBOutlet weak var m_tfCheckNumber: TextField!
    @IBOutlet weak var m_vCheckAmount: UIView!
    @IBOutlet weak var m_tfCheckAmount: TextField!
    @IBOutlet weak var m_consCheckAmountHeight: NSLayoutConstraint!
    @IBOutlet weak var m_vCheckDate: UIView!
    @IBOutlet weak var m_consCheckDateHeight: NSLayoutConstraint!
    @IBOutlet weak var m_vFeeAccount: UIView!
    @IBOutlet weak var m_consFeeAccountHeight: NSLayoutConstraint!
    @IBOutlet weak var m_vFeeCash: UIView! //chiu 1090819
    @IBOutlet weak var m_vFeeCashHeight:NSLayoutConstraint! //chiu 1090819  注意 拉好storebard 後將設定之height=60 以constraint取代,即拉 IBOulet 到Constraint 高度設定那 取代掉
    @IBOutlet weak var m_tfFeeCash: UILabel! //chiu 1090819
    @IBOutlet weak var m_vImageConfirmView: UIView!
    @IBOutlet weak var bottomView: UIView!
    private var m_DDType: OneRowDropDownView? = nil
    private var m_DDAccount: OneRowDropDownView? = nil
    private var m_CheckDate: OneRowDropDownView? = nil
    private var m_FeeAccount: OneRowDropDownView? = nil
    private var m_FeeCash: OneRowDropDownView? = nil //chiu 1090819
    private var m_curDropDownView: OneRowDropDownView? = nil
    private var m_ImageConfirmView: ImageConfirmView? = nil
    private var m_PodConfirmView: PodConfirmView? = nil
    
    private var accountList:[AccountStruct]? = nil      // 帳號列表
    private var pod = ""
    private var checkAccountList:[AccountStruct]? = nil // 支票帳號列表
    private var curTextfield:UITextField? = nil
    private var podTextfield:UITextField? = nil //密碼用
    private var lostCheckFeeInfo: [String: String] = [:]
    private var JCICFee = ""
    private var LOSTFee = ""
    
    
    //20220325-檢測修改密碼及塊登驗證
    let CheckLoseApply_Bill_Max_Length:Int = 10
    var GestureVerifyView:GestureVerify? = nil        // 圖形密碼頁
    var PodConfirmFlag = false
    var context = LAContext()
    
    var wkLogInCode = ""
    
    
    // MARK: - Override
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //開啟手勢滑動選單
        if let rootViewController =
            UIApplication.shared.keyWindow?.rootViewController {
            (rootViewController as! SideMenuViewController).SetGestureStatus(true)
        }
        
    }
    
    
    override func clickGestureShowBtn( _ info:LoginStrcture ) {
        AuthorizationManage.manage.SetLoginInfo(info)
        self.postRequest("Comm/COMM0110", "COMM0110",  AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10001","Operate":"termsConfirm","KINBR":info.bankCode,"uid": AgriBank_DeviceID], true), AuthorizationManage.manage.getHttpHead(true))
        // showGestureView( )
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PodConfirmFlag = false
        setAllSubView()
        setShadowView(m_vShadowView)
        setShadowView(bottomView, .Top)
        getTransactionID("04003", TransactionID_Description)
        addObserverToKeyBoard()
        addGestureForKeyBoard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func keyboardWillShow(_ notification: NSNotification) {
        if m_DDType?.getContentByType(.First) == CheckLoseApply_TypeList[0] && curTextfield != m_tfCheckNumber && curTextfield != m_tfCheckAmount {
            super.keyboardWillShow(notification)
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
                    if let type = category["ACTTYPE"] as? String, let result = category["AccountInfo"] as? [[String:Any]] {
                        if type == Account_Saving_Type {
                            accountList = [AccountStruct]()
                            for actInfo in result {
                                if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? String, let ebkfg = actInfo["EBKFG"] as? String {
                                    accountList?.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
                                }
                            }
                        }
                        else if type == Account_Check_Type {
                            checkAccountList = [AccountStruct]()
                            for actInfo in result {
                                if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? String, let ebkfg = actInfo["EBKFG"] as? String {
                                    checkAccountList?.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
                                }
                            }
                        }
                    }
                }
                setLoading(true)
                //chiu 1090819
                postRequest("COMM/COMM0702", "COMM0702", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"04004","Operate":"getCost","TransactionId":transactionId,"ItemCode":"07"], true), AuthorizationManage.manage.getHttpHead(true))
                //getImageConfirm(transactionId)
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
                if m_DDType?.m_lbFirstRowContent.text == CheckLoseApply_TypeList[0] {
                    //chiu 1090819
                    //                    postRequest("LOSE/LOSE0301", "LOSE0301", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"0403","Operate":"setLoseCheck1","TransactionId":transactionId,"TYPE":"13","REFNO":m_DDAccount?.getContentByType(.First) ?? "","CKNO":m_tfCheckNumber.text ?? "","TXAMT":m_tfCheckAmount.text ?? "","MACTNO":m_FeeAccount?.getContentByType(.First) ?? "","CKDAY":m_CheckDate?.getContentByType(.First).replacingOccurrences(of: "/", with: "") ?? ""], true), AuthorizationManage.manage.getHttpHead(true))
                    postRequest("LOSE/LOSE0303", "LOSE0303", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"04003","Operate":"commitTxn","TransactionId":transactionId,"TYPE":"13","REFNO":m_DDAccount?.getContentByType(.First) ?? "","CKNO":m_tfCheckNumber.text ?? "","TXAMT":m_tfCheckAmount.text ?? "","MACTNO":m_FeeAccount?.getContentByType(.First) ?? "","CKDAY":m_CheckDate?.getContentByType(.First).replacingOccurrences(of: "/", with: "") ?? "","JCICFee":JCICFee ,"LOSTFee":LOSTFee ], true), AuthorizationManage.manage.getHttpHead(true))
                    
                }
                else {
                    postRequest("LOSE/LOSE0302", "LOSE0302", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"0403","Operate":"setLoseCheck2","TransactionId":transactionId,"TYPE":"11","REFNO":m_DDAccount?.getContentByType(.First) ?? "","CKNO":m_tfCheckNumber.text ?? ""], true), AuthorizationManage.manage.getHttpHead(true))
                }
            }
            else {
                m_ImageConfirmView?.m_tfInput.text = ""
                getImageConfirm(transactionId)
                showErrorMessage(nil, ErrorMsg_Image_ConfirmFaild)
            }
            //chiu 1090819
        case "COMM0702":
            if let  data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]]  {
                for item in array {
                    
                    if let iFee = item["Fee"] as? String ,let iJCICFee = item["JCICFee"] as? String
                    {
                        JCICFee = iJCICFee
                        LOSTFee = iFee
                        
                        let sumFee:Int = Int(iFee)! + Int(iJCICFee)!
                        m_tfFeeCash.text = String(sumFee)
                    }
                    
                }
                getImageConfirm(transactionId)
            }else
            {
                super.didResponse(description, response)
            }
        case "USIF0304":
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode == ReturnCode_Success {
                
                SendLostInfo()
                
//                setLoading(true)
//                if m_DDType?.m_lbFirstRowContent.text == CheckLoseApply_TypeList[0] {
//                    postRequest("LOSE/LOSE0303", "LOSE0303", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"04003","Operate":"commitTxn","TransactionId":transactionId,"TYPE":"13","REFNO":m_DDAccount?.getContentByType(.First) ?? "","CKNO":m_tfCheckNumber.text ?? "","TXAMT":m_tfCheckAmount.text ?? "","MACTNO":m_FeeAccount?.getContentByType(.First) ?? "","CKDAY":m_CheckDate?.getContentByType(.First).replacingOccurrences(of: "/", with: "") ?? "","JCICFee":JCICFee ,"LOSTFee":LOSTFee ], true), AuthorizationManage.manage.getHttpHead(true))
//
//                }
//                else {
//                    postRequest("LOSE/LOSE0302", "LOSE0302", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"0403","Operate":"setLoseCheck2","TransactionId":transactionId,"TYPE":"11","REFNO":m_DDAccount?.getContentByType(.First) ?? "","CKNO":m_tfCheckNumber.text ?? ""], true), AuthorizationManage.manage.getHttpHead(true))
//                }
                
            }
        case "LOSE0301", "LOSE0302","LOSE0303":
            var result = ConfirmResultStruct()
            result.resultBtnName = "繼續交易"
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode == ReturnCode_Success {
                result.title = Lose_Successful_Title
                result.image = ImageName.CowSuccess.rawValue
                result.memo = CheckLoseApply_Memo
                if let data = response.object(forKey:ReturnData_Key) as? [String:String] {
                    result.list = [[String:String]]()
                    result.list?.append([Response_Key:"交易時間",Response_Value:data["TXTIME"] ?? ""])
                    result.list?.append([Response_Key:"掛失日期",Response_Value:data["TXDAY"] ?? ""])
                    //chiu 1090819
                    if let Fee = data["Fee"]  {
                        if Fee != ""{
                            result.list?.append([Response_Key:"手續費",Response_Value:data["Fee"] ?? ""])
                        }
                    }
                    
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
            //SendFastLogInError(bankCode)
        default:
            break
        }
    }
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
    
    func changeInputTextfield(_ input: String) {
        pod = input
    }
    
    func SendLostInfo() {
        setLoading(true)
        if m_DDType?.m_lbFirstRowContent.text == CheckLoseApply_TypeList[0] {
            postRequest("LOSE/LOSE0303", "LOSE0303", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"04003","Operate":"commitTxn","TransactionId":transactionId,"TYPE":"13","REFNO":m_DDAccount?.getContentByType(.First) ?? "","CKNO":m_tfCheckNumber.text ?? "","TXAMT":m_tfCheckAmount.text ?? "","MACTNO":m_FeeAccount?.getContentByType(.First) ?? "","CKDAY":m_CheckDate?.getContentByType(.First).replacingOccurrences(of: "/", with: "") ?? "","JCICFee":JCICFee ,"LOSTFee":LOSTFee ], true), AuthorizationManage.manage.getHttpHead(true))
            
        }
        else {
            postRequest("LOSE/LOSE0302", "LOSE0302", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"0403","Operate":"setLoseCheck2","TransactionId":transactionId,"TYPE":"11","REFNO":m_DDAccount?.getContentByType(.First) ?? "","CKNO":m_tfCheckNumber.text ?? ""], true), AuthorizationManage.manage.getHttpHead(true))
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
    
    
    // MARK: - Private
    private func setAllSubView() {
        setDDTypeView()
        setDDAccountView()
        setCheckNumberView()
        setCheckAmountView()
        setCheckDateView()
        setFeeAccountView()
        setFeeCachView()
        // setImageConfirmView()
        setPodConfirmView()
    }
    
    private func setDDTypeView() {
        if m_DDType == nil {
            m_DDType = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
            m_DDType?.delegate = self
            m_DDType?.setOneRow(CheckLoseApply_ChooseType_Title, CheckLoseApply_TypeList[0])
            m_DDType?.frame = CGRect(x:0, y:0, width:m_vDDType.frame.width, height:(m_DDType?.getHeight())!)
            m_vDDType.addSubview(m_DDType!)
        }
        m_vDDType.layer.borderColor = Gray_Color.cgColor
        m_vDDType.layer.borderWidth = 1
    }
    
    private func setDDAccountView() {
        if m_DDAccount == nil {
            m_DDAccount = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
            m_DDAccount?.delegate = self
            m_DDAccount?.setOneRow(CheckLoseApply_CheckAccount_Title, Choose_Title)
            m_DDAccount?.frame = CGRect(x:0, y:0, width:m_vDDAccount.frame.width, height:(m_DDAccount?.getHeight())!)
            m_vDDAccount.addSubview(m_DDAccount!)
        }
        m_vDDAccount.layer.borderColor = Gray_Color.cgColor
        m_vDDAccount.layer.borderWidth = 1
    }
    
    private func setCheckNumberView() {
        m_vCheckNumber.layer.borderColor = Gray_Color.cgColor
        m_vCheckNumber.layer.borderWidth = 1
    }
    
    private func setCheckAmountView() {
        m_vCheckAmount.layer.borderColor = Gray_Color.cgColor
        m_vCheckAmount.layer.borderWidth = 1
    }
    
    private func setCheckDateView() {
        if m_CheckDate == nil {
            m_CheckDate = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
            m_CheckDate?.delegate = self
            m_CheckDate?.setOneRow(CheckLoseApply_Date_Title, Choose_Title)
            m_CheckDate?.frame = CGRect(x:0, y:0, width:m_vCheckDate.frame.width, height:(m_CheckDate?.getHeight())!)
            m_vCheckDate.addSubview(m_CheckDate!)
        }
        
        m_vCheckDate.layer.borderColor = Gray_Color.cgColor
        m_vCheckDate.layer.borderWidth = 1
    }
    
    private func setFeeAccountView() {
        if m_FeeAccount == nil {
            m_FeeAccount = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
            m_FeeAccount?.delegate = self
            m_FeeAccount?.setOneRow(CheckLoseApply_TransAccount_Title, Choose_Title)
            m_FeeAccount?.frame = CGRect(x:0, y:0, width:m_vFeeAccount.frame.width, height:(m_FeeAccount?.getHeight())!)
            m_vFeeAccount.addSubview(m_FeeAccount!)
        }
        m_vFeeAccount.layer.borderColor = Gray_Color.cgColor
        m_vFeeAccount.layer.borderWidth = 1
    }
    private func setFeeCachView() {
        
        m_vFeeCash.layer.borderColor = Gray_Color.cgColor
        m_vFeeCash.layer.borderWidth = 1
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
    
    private func hideSomeSubviews() {
        m_vCheckAmount.isHidden = true
        m_vCheckDate.isHidden = true
        m_vFeeAccount.isHidden = true
        m_vFeeCash.isHidden = true
        m_consCheckAmountHeight.constant = 0
        m_consCheckDateHeight.constant = 0
        m_consFeeAccountHeight.constant = 0
        m_vFeeCashHeight.constant = 0 //chiu 1090819
    }
    
    private func showSomeSubviews() {
        m_vCheckAmount.isHidden = false
        m_vCheckDate.isHidden = false
        m_vFeeAccount.isHidden = false
        m_vFeeCash.isHidden = false
        m_consCheckAmountHeight.constant = 60
        m_consCheckDateHeight.constant = 60
        m_consFeeAccountHeight.constant = 60
        m_vFeeCashHeight.constant = 60 //chiu 1090819
    }
    
    private func inputIsCorrect() -> Bool {
        if m_DDAccount?.getContentByType(.First) == Choose_Title {
            showErrorMessage(nil, "\(Choose_Title)\(m_DDAccount?.m_lbFirstRowTitle.text ?? "")")
            return false
        }
        if (m_tfCheckNumber.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(m_tfCheckNumber.placeholder ?? "")")
            return false
        }
        if m_DDType?.m_lbFirstRowContent.text == CheckLoseApply_TypeList[0] {
            if (m_tfCheckAmount.text?.isEmpty)! {
                showErrorMessage(nil, "\(Enter_Title)\(m_tfCheckAmount.placeholder ?? "")")
                return false
            }
            if m_CheckDate?.getContentByType(.First) == Choose_Title {
                showErrorMessage(nil, "\(Choose_Title)\(m_CheckDate?.m_lbFirstRowTitle.text ?? "")")
                return false
            }
            if m_FeeAccount?.getContentByType(.First) == Choose_Title {
                showErrorMessage(nil, "\(Choose_Title)\(m_FeeAccount?.m_lbFirstRowTitle.text ?? "")")
                return false
            }
        }
        return true
    }
    
    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        view.endEditing(true)
        m_curDropDownView = sender
        if m_curDropDownView == m_CheckDate {
            if let datePicker = getUIByID(.UIID_DatePickerView) as? DatePickerView {
                datePicker.frame = CGRect(origin: .zero, size: view.frame.size)
                datePicker.showOneDatePickerView(true, nil) { start in
                    self.m_CheckDate?.setOneRow(CheckLoseApply_Date_Title, "\(start.year)/\(start.month)/\(start.day)")
                }
                view.addSubview(datePicker)
            }
        }
        else {
            var list = [String]()
            var errorMessage = ""
            if m_curDropDownView == m_DDType {
                list = CheckLoseApply_TypeList
            }
            else if m_curDropDownView == m_DDAccount {
                if checkAccountList != nil && (checkAccountList?.count)! > 0 {
                    for index in checkAccountList! {
                        list.append(index.accountNO)
                    }
                }
                else {
                    errorMessage = "\(Get_Null_Title)\(m_DDAccount?.m_lbFirstRowTitle.text ?? "")"
                }
            }
            else if m_curDropDownView == m_FeeAccount {
                if accountList != nil && (accountList?.count)! > 0 {
                    for index in accountList! {
                        list.append(index.accountNO)
                    }
                }
                else {
                    errorMessage = "\(Get_Null_Title)\(m_FeeAccount?.m_lbFirstRowTitle.text ?? "")"
                }
            }
            
            if errorMessage.isEmpty {
                let action = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
                list.forEach{title in action.addButton(withTitle: title)}
                action.show(in: self.view)
            }
            else {
                showErrorMessage(nil, errorMessage)
            }
        }
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet.cancelButtonIndex != buttonIndex {
            if m_curDropDownView == m_DDType {
                if (actionSheet.buttonTitle(at: buttonIndex) ?? "") == CheckLoseApply_TypeList[0] {
                    showSomeSubviews()
                }
                else {
                    hideSomeSubviews()
                }
            }
            m_curDropDownView?.setOneRow(m_curDropDownView?.m_lbFirstRowTitle.text ?? "", actionSheet.buttonTitle(at: buttonIndex) ?? "")
        }
        m_curDropDownView = nil
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        curTextfield = textField
        //podTextfield = textField
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.count)! - range.length + string.count
        if textField == m_tfCheckNumber {
            if newLength > CheckLoseApply_Bill_Max_Length {
                return false
            }
        }
        return true
    }
  
    // MARK: - ImageConfirmCellDelegate
    func clickRefreshBtn() {
        getImageConfirm(transactionId)
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
        let pdMd50 = (podTextfield?.text)! + loginDateTIme
        let pdMd5 = E2E.e2Epod(E2EKeyData, pod:pdMd50)
        //109-10-16 add by sweney for check e2e key
        
        //E2E
        setLoading(true)
            self.postRequest("Usif/USIF0304", "USIF0304",  AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"08006","Operate":"dataConfirm","TransactionId":transactionId,"DWP": pdMd5 as Any  ], true), AuthorizationManage.manage.getHttpHead(true))
        }}
    // MARK: - StoryBoard Touch Event
    @IBAction func m_btnSendClick(_ sender: Any) {
        if inputIsCorrect() {
            if wkLogInCode == "1" && PodConfirmFlag == false {
                showFaceIDConfirm()
            }else if wkLogInCode == "2" && PodConfirmFlag == false {
                if let info = AuthorizationManage.manage.GetLoginInfo(){
                    clickGestureShowBtn(info)
                }
            }else{
                SendPodVerify()
            }
            // checkImageConfirm(pod, transactionId)
        }
    }
    
}
