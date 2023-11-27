//
//  ConfirmViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/6/15.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit
import CoreLocation
import LocalAuthentication

let Confirm_ImageConfirm_Cell_Height:CGFloat = 60
let Confirm_Segue2 = "GoResult2"
let Confirm_Segue = "GoResult"
/* 「即時轉帳」確認頁特殊處理 */
let Predesignated_Title = "約定轉帳"
let NonPredesignated_Title = "非約定轉帳"
private var loginInfo = LoginStrcture()
var wkLogInCode = ""
var GestureVerifyView:GestureVerify? = nil        // 圖形密碼頁
var PodConfirmFlag = false

//無卡取消預約用
var CardlessCancelTime:String? = ""


class ConfirmViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource,PodConfirmViewDelegate,GestureVerifyDelegate/*, ImageConfirmViewDelegate, CLLocationManagerDelegate*/ {
   
    
    @IBOutlet weak var m_tvData: UITableView!
    @IBOutlet weak var m_vBottomView: UIView!
    @IBOutlet weak var m_btnConfirm: UIButton!
    private var data:ConfirmResultStruct? = nil
    private var dataOTP:ConfirmOTPStruct? = nil
    private var pod = ""
    private var imageConfirmView:ImageConfirmView? = nil
    private var podConfirmView:PodConfirmView? = nil
    private var checkRequest:RequestStruct? = nil
    private var curTextfield:UITextField? = nil
    private var isNeedOTP = false
    //    private var locationManager:CLLocationManager? = nil   // OTP需要開啟定位點
    var m_strTitle: String? = nil
    var context = LAContext()
    
    
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
                            PodConfirmFlag = true
                            self.SendConfirm()
                            }
                    }
                    else{
                        //回到主執行緒
                        OperationQueue.main.addOperation {
                        PodConfirmFlag = true
                        self.m_tvData.reloadData()
                        }
                    }
                        
                    }  } }
    }
    
    // MARK: - Public
    func setData(_ data:ConfirmResultStruct) {
        self.data = data
    }
    
    func setDataNeedOTP(_ dataOTP:ConfirmOTPStruct) {
        self.dataOTP = dataOTP
        isNeedOTP = true
    }
    
    // MARK: - Override
    
    override func clickGestureShowBtn( _ info:LoginStrcture ) {
        AuthorizationManage.manage.SetLoginInfo(info)
         self.postRequest("Comm/COMM0110", "COMM0110",  AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10001","Operate":"termsConfirm","KINBR":info.bankCode,"uid": AgriBank_DeviceID], true), AuthorizationManage.manage.getHttpHead(true))
       // showGestureView( )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PodConfirmFlag = false
        //20230413 重ＬＯＡＤ一次以防紀錄未清除by sweney
        if InitFastLogIncheck(){}
        if isNeedOTP {
            //            if CLLocationManager.authorizationStatus() == .notDetermined || CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            m_btnConfirm.setTitle(dataOTP?.confirmBtnName, for: .normal)
            // 開啟定位
            //                locationManager = CLLocationManager()
            //                locationManager?.delegate = self
            //                locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            //                locationManager?.requestWhenInUseAuthorization()
            //            }
            //            else {
            //                let alert = UIAlertController(title: UIAlert_Default_Title, message: ErrorMsg_NoPositioning, preferredStyle: .alert)
            //                alert.addAction(UIAlertAction(title: Determine_Title, style: .default) { _ in
            //                    self.navigationController?.popViewController(animated: true)
            //                })
            //                present(alert, animated: true, completion: nil)
            //            }
        }
        else {
            m_btnConfirm.setTitle(data?.confirmBtnName, for: .normal)
        }
        
        podConfirmView = getUIByID(.UIID_PodConfirmView )as? PodConfirmView
      podConfirmView?.delegate = self
       
        
        
     // imageConfirmView = getUIByID(.UIID_ImageConfirmView) as? ImageConfirmView
     // imageConfirmView?.delegate = self
//        imageConfirmView?.m_vSeparator.isHidden = false
        
        m_tvData.register(UINib(nibName: UIID.UIID_ResultCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultCell.NibName()!)
        m_tvData.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: SystemCell_Identify)
        m_tvData.allowsSelection = false
        m_tvData.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        setShadowView(m_vBottomView)
        addObserverToKeyBoard()
        addGestureForKeyBoard()
        
        //getImageConfirm(transactionId)
       // showFaceIDConfirm()
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case "COMM0501":
            if let responseImage = response[RESPONSE_IMAGE_KEY] as? UIImage {
                imageConfirmView?.m_ivShow.image = responseImage
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
        case "USIF0304":
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode == ReturnCode_Success {
               SendConfirm()
            }
           
        case "COMM0502":
            if let flag = response[RESPONSE_IMAGE_CONFIRM_RESULT_KEY] as? String, flag == ImageConfirm_Success {
                if !isNeedOTP {
                    if data?.checkRequest != nil {
                        setLoading(true)
                        postRequest((data?.checkRequest?.strMethod)!, (data?.checkRequest?.strSessionDescription)!, data?.checkRequest?.httpBody, data?.checkRequest?.loginHttpHead, data?.checkRequest?.strURL, (data?.checkRequest?.needCertificate)!, (data?.checkRequest?.isImage)!, (data?.checkRequest?.timeOut)!)
                    }
                }
                else {
                    setLoading(true)
                    VaktenManager.sharedInstance().signTaskOperation(with: dataOTP?.task) { resultCode in
                        if VIsSuccessful(resultCode) {
                            //                            let otp = VaktenManager.sharedInstance().generateGeoOTPCode()
                            //                            if VIsSuccessful((otp?.resultCode)!) {
                            //                                self.dataOTP?.httpBodyList?["otp"] = otp?.otp
                            self.dataOTP?.httpBodyList?["otp"] = ""
                            if ((self.dataOTP?.httpBodyList?["WorkCode"] as! String) == "09005") {
                                //掃qrcode的繳費交易的銷帳編號可能會有space，特別拉出來判斷
                                let httpBody: Data? = AuthorizationManage.manage.converInputToHttpBody2((self.dataOTP?.httpBodyList!)!, true)
                                self.dataOTP?.checkRequest?.httpBody = httpBody
                                //                                    self.dataOTP?.checkRequest?.httpBody = AuthorizationManage.manage.converInputToHttpBody2((self.dataOTP?.httpBodyList!)!, true)
                            }
                            else {
                                let httpBody: Data? = AuthorizationManage.manage.converInputToHttpBody((self.dataOTP?.httpBodyList!)!, true)
                                self.dataOTP?.checkRequest?.httpBody = httpBody
                                //                                    self.dataOTP?.checkRequest?.httpBody = AuthorizationManage.manage.converInputToHttpBody((self.dataOTP?.httpBodyList!)!, true)
                            }
                            self.postRequest((self.dataOTP?.checkRequest?.strMethod)!, (self.dataOTP?.checkRequest?.strSessionDescription)!, self.dataOTP?.checkRequest?.httpBody, self.dataOTP?.checkRequest?.loginHttpHead, self.dataOTP?.checkRequest?.strURL, (self.dataOTP?.checkRequest?.needCertificate)!, (self.dataOTP?.checkRequest?.isImage)!, (self.dataOTP?.checkRequest?.timeOut)!)
                            //                            }
                            //                            else {
                            //                                let alert = UIAlertController(title: UIAlert_Default_Title, message: "\(ErrorMsg_GenerateOTP_Faild) \((otp?.resultCode)!.rawValue)", preferredStyle: .alert)
                            //                                alert.addAction(UIAlertAction(title: Determine_Title, style: .default) { _ in
                            //                                    DispatchQueue.main.async {
                            //                                        self.enterFeatureByID(.FeatureID_Home, true)
                            //                                    }
                            //                                })
                            //                                self.present(alert, animated: false, completion: nil)
                            //                                self.setLoading(false)
                            //                            }
                            //                        }
                            //                        else {
                            //                            let alert = UIAlertController(title: UIAlert_Default_Title, message: "\(ErrorMsg_SignTask_Faild) \(resultCode.rawValue)", preferredStyle: .alert)
                            //                            alert.addAction(UIAlertAction(title: Determine_Title, style: .default) { _ in
                            //                                DispatchQueue.main.async {
                            //                                    self.enterFeatureByID(.FeatureID_Home, true)
                            //                                }
                            //                            })
                            //                            self.present(alert, animated: false, completion: nil)
                            //                            self.setLoading(false)
                        }
                    }
                }
            }
            else {
                imageConfirmView?.m_tfInput.text = ""
                pod = ""
                getImageConfirm(transactionId)
                showErrorMessage(nil, ErrorMsg_Image_ConfirmFaild)
            }
        case BaseTransactionID_Description, "BaseCOMM0802", "QR0101", "Gold0101","COMM0117"://在Base發的 丟回Base處理
            super.didResponse(description, response)
        case "QR0505": break
           // print("QR0505 OK ")
        default:
            if isNeedOTP {
                data = ConfirmResultStruct(image: "", title: "", list: nil, memo: "", confirmBtnName: dataOTP?.confirmBtnName ?? "", resultBtnName: dataOTP?.resultBtnName ?? "", checkRequest: nil)
            }
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode == ReturnCode_Success {
                if  (description == "QR0302") ||
                    (description == "QR0402") ||
                    (description == "QR0502") ||
                    (description == "QR0504") ||
                    (description == "Gold0301") ||
                    (description == "Gold0302") ||
                    (description == "Gold0401") ||
                    (description == "Gold0402") ||
                    (description == "Gold0403") ||
                    (description == "Gold0404") ||
                    (description == "TRAN1103")
                {
                    if let responseData = response.object(forKey: ReturnData_Key) as? [String:Any] {
                        if let responseResult = responseData["Result"] as? [[String:String]] {
                            data?.list = responseResult
                        }
                        if let memo = responseData["Memo"] as? String {
                            data?.memo = memo
                        }
                    }
                }
                else if let responseData = response.object(forKey: ReturnData_Key) as? [[String:Any]] {
                    data?.list = responseData
                }
                data?.title = Transaction_Successful_Title
                data?.image = ImageName.CowSuccess.rawValue
                if (description  == "TRAN0102")||(description  == "TRAN0101")||(description  == "QR0702")||(description == "TRAN1005"){
                    performSegue(withIdentifier: Confirm_Segue2, sender: nil)
                }else{
                    performSegue(withIdentifier: Confirm_Segue, sender: nil)
                    
                }
                if (description == "QR0504"){
                    let TransNo:String = (data?.list?[6][Response_Value] as? String ?? "")!
                
                    let paytype:String = dataOTP?.httpBodyList?["paytype"] as! String
                    let billSID:String = dataOTP?.httpBodyList?["billSID"] as! String
                    
                    postRequest("QR/QR0505", "QR0505", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"09012","Operate":"dataConfirm","TransactionId":transactionId,"appId": AgriBank_AppID,"TransNo":TransNo,"paytype": paytype,"billSID": billSID], true), AuthorizationManage.manage.getHttpHead(true))
                
                }}
            else {
                data?.title = Transaction_Faild_Title
                data?.image = ImageName.CowFailure.rawValue
                if let message = response.object(forKey:ReturnMessage_Key) as? String {
                    data?.list = [[String:String]]()
                    data?.list?.append([Response_Key:Error_Title,Response_Value:message])
                }
                performSegue(withIdentifier: Confirm_Segue, sender: nil)
            }
           
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let controller = segue.destination as! ResultViewController
        controller.setData(data!)
        /* 「即時轉帳」結果頁特殊處理 */
        if getCurrentFeatureID() == .FeatureID_NTTransfer {
            controller.setData(data!, isNeedOTP ? NonPredesignated_Title : Predesignated_Title)
        }
        /**「手機門號即時轉帳」結果頁特殊處理*/
        if getCurrentFeatureID() == .FeatureID_MobileTransfer
            || getCurrentFeatureID() == .FeatureID_MobileNTTransfer {
            controller.setData(data!, m_strTitle, isMobileTransfer: true)
        }
        else {
            controller.setData(data!, m_strTitle)
        }
    }
    
    override func clickBackBarItem() {
        if !isNeedOTP {
            navigationController?.popViewController(animated: true)
        }
        else {
            VaktenManager.sharedInstance().cancelTaskOperation(with: dataOTP?.task) { resultCode in
                if !VIsSuccessful(resultCode) {
                    self.showErrorMessage(nil, "\(ErrorMsg_CancelTask_Faild) \(resultCode.rawValue)")
                }
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        locationManager?.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //開啟手勢滑動選單
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            (rootViewController as! SideMenuViewController).SetGestureStatus(true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /* 「即時轉帳」確認頁特殊處理 */
        if getCurrentFeatureID() == .FeatureID_NTTransfer {
            navigationController?.navigationBar.topItem?.title = isNeedOTP ? NonPredesignated_Title : Predesignated_Title
        }
        if (m_strTitle != nil) {
            navigationController?.navigationBar.topItem?.title = m_strTitle
        }
    }
        func SendConfirm(){
            if !self.isNeedOTP {
                if self.data?.checkRequest != nil {
                    self.setLoading(true)
                    self.postRequest((self.data?.checkRequest?.strMethod)!, (self.data?.checkRequest?.strSessionDescription)!, self.data?.checkRequest?.httpBody, self.data?.checkRequest?.loginHttpHead, self.data?.checkRequest?.strURL, (self.data?.checkRequest?.needCertificate)!, (self.data?.checkRequest?.isImage)!, (self.data?.checkRequest?.timeOut)!)   }   }
            else {    self.setLoading(true)
                VaktenManager.sharedInstance().signTaskOperation(with: self.dataOTP?.task) { resultCode in
                    if VIsSuccessful(resultCode) {
                        self.dataOTP?.httpBodyList?["otp"] = ""
                        if ((self.dataOTP?.httpBodyList?["WorkCode"] as! String) == "09005") {
                            //掃qrcode的繳費交易的銷帳編號可能會有space，特別拉出來判斷
                            let httpBody: Data? = AuthorizationManage.manage.converInputToHttpBody2((self.dataOTP?.httpBodyList!)!, true)
                            self.dataOTP?.checkRequest?.httpBody = httpBody
                        }
                        else {
                            let httpBody: Data? = AuthorizationManage.manage.converInputToHttpBody((self.dataOTP?.httpBodyList!)!, true)
                            self.dataOTP?.checkRequest?.httpBody = httpBody
                        }
                        self.postRequest((self.dataOTP?.checkRequest?.strMethod)!, (self.dataOTP?.checkRequest?.strSessionDescription)!, self.dataOTP?.checkRequest?.httpBody, self.dataOTP?.checkRequest?.loginHttpHead, self.dataOTP?.checkRequest?.strURL, (self.dataOTP?.checkRequest?.needCertificate)!, (self.dataOTP?.checkRequest?.isImage)!, (self.dataOTP?.checkRequest?.timeOut)!)
                    }
                }}
        }
        
  
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let list = isNeedOTP ? dataOTP?.list : data?.list
        if indexPath.row == list?.count {
            return Confirm_ImageConfirm_Cell_Height
        }
        else {
            let height = ResultCell.GetStringHeightByWidthAndFontSize((list?[indexPath.row][Response_Value]) as? String ?? "", m_tvData.frame.size.width)
            return height
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return tableView.sectionFooterHeight
        }
        else {
            let memo = isNeedOTP ? dataOTP?.memo : data?.memo
            if (memo?.isEmpty)! {
                return 0
            }
            else {
                return MemoView.GetStringHeightByWidthAndFontSize(memo!, m_tvData.frame.width)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let head = getUIByID(.UIID_ShowMessageHeadView) as! ShowMessageHeadView
            if isNeedOTP {
                head.imageView.image = UIImage(named: dataOTP?.image ?? "")
                head.titleLabel.text = dataOTP?.title
            }
            else {
                head.imageView.image = UIImage(named: data?.image ?? "")
                head.titleLabel.text = data?.title
            }
            return head
        }
        else {
            let memo = isNeedOTP ? dataOTP?.memo : data?.memo
            if (memo?.isEmpty)! {
                return nil
            }
            else {
                let footer = getUIByID(.UIID_MemoView) as! MemoView
                footer.set(memo!)
                return footer
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }
        else {
            let list = isNeedOTP ? dataOTP?.list : data?.list
            return (list?.count)!+1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let list = isNeedOTP ? dataOTP?.list : data?.list
        if indexPath.row == (list?.count)! {
            if  !InitFastLogIncheck() || PodConfirmFlag == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: SystemCell_Identify, for: indexPath)
          //  imageConfirmView?.frame = CGRect(x:0, y:0, width:cell.contentView.frame.width, height:cell.contentView.frame.height)
          //  cell.contentView.addSubview(imageConfirmView!)
        
            podConfirmView?.frame = CGRect(x:0, y:0, width:cell.contentView.frame.width, height:cell.contentView.frame.height)
            cell.contentView.addSubview(podConfirmView!)
                return cell
            }else{
            
                if wkLogInCode == "1" {
                    let  cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell
                    cell.set("交易驗證", "生物辨識(FaceId/指紋)")
                    return cell
                }
                else if wkLogInCode  == "2" {
                    let  cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell
                    cell.set("交易驗證", "圖形密碼")
                    return cell
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: SystemCell_Identify, for: indexPath)
                    podConfirmView?.frame = CGRect(x:0, y:0, width:cell.contentView.frame.width, height:cell.contentView.frame.height)
                    cell.contentView.addSubview(podConfirmView!)
                        return cell
                }
               
            }
            
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell
            cell.set((list?[indexPath.row][Response_Key]) as? String ?? "", (list?[indexPath.row][Response_Value]) as? String ?? "")
            //無卡提款用
            if (list?[indexPath.row][Response_Key]) as? String ?? "" == "失效時間" {
                CardlessCancelTime =  list?[indexPath.row][Response_Value] as? String
            }
            return cell
        }
    }
  
    func SendPodVerify()
    {
        if self.curTextfield?.text == "" || self.curTextfield == nil {
            // let alert = UIAlertView(title: UIAlert_Default_Title, message: "請輸入使用者密碼！", delegate: nil, cancelButtonTitle:Determine_Title)
             // alert.show()
             let alert = UIAlertController(title: UIAlert_Default_Title, message: "請輸入使用者密碼！", preferredStyle: .alert)
             // 建立[取消]按鈕
             let cancelAction = UIAlertAction(
                 title:Determine_Title,
                 style: .cancel,
                 handler: nil)
             alert.addAction(cancelAction)
             self.present(
                 alert,
                 animated: true,
                 completion: nil)
        }else{
        //E2E
            // let fmt = DateFormatter()
             //let timeZone = TimeZone.ReferenceType.init(abbreviation:"UTC") as TimeZone?
             //fmt.timeZone = timeZone
             //fmt.dateFormat = "yyyy/MM/dd HH:mm:ss"
             //let loginDateTIme: String = fmt.string(from: Date())
             let loginDateTIme: String = Date().date2String(dateFormat: "yyyy/MM/dd HH:mm:ss")
       let pdMd50 = (curTextfield?.text)! + loginDateTIme
       let pdMd5 = E2E.e2Epod(E2EKeyData, pod:pdMd50)
       //109-10-16 add by sweney for check e2e key

       //E2E
       setLoading(true)
            self.postRequest("Usif/USIF0304", "USIF0304",  AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"08006","Operate":"dataConfirm","TransactionId":transactionId,"DWP": pdMd5!  ], true), AuthorizationManage.manage.getHttpHead(true))
        }
    }
    
    // MARK: - ImageConfirmCellDelegate
//    func clickRefreshBtn() {
//        getImageConfirm(transactionId)
//    }
    
    func changeInputTextfield(_ input: String) {
        pod = input
    }
    
//    func ImageConfirmTextfieldBeginEditing(_ textfield:UITextField) {
//        curTextfield = textfield
//    }
    func PODConfirmTextfieldBeginEditing(_ textfield: UITextField) {
        curTextfield = textfield
    }
    // MARK: - StoryBoard Touch Event
    @IBAction func clickCheckBtn(_ sender: Any) {
        //無卡提款取消檢查時效
        if data?.checkRequest?.strSessionDescription == "TRAN1103" {
            let fmt = DateFormatter()
            let timeZone = TimeZone.ReferenceType.init(abbreviation:"UTC") as TimeZone?
            fmt.timeZone = timeZone
            fmt.dateFormat = "yyyy/MM/dd HH:mm:ss"
            let DATE = fmt.date(from:CardlessCancelTime!)!
            let Now = fmt.date(from:Date().date2String(dateFormat: "yyyy/MM/dd HH:mm:ss"))
            if DATE < Now!{
                let mmsg = "此預約已失效"
                showAlert(title: UIAlert_Default_Title, msg: mmsg, confirmTitle: "確認", cancleTitle: nil, completionHandler: {
                    (sender as! UIButton).isHidden = true
                    return
                }, cancelHandelr: {()})
            }
                }
        
        curTextfield?.resignFirstResponder()
        if wkLogInCode == "1" && PodConfirmFlag == false {
            showFaceIDConfirm()
        }else if wkLogInCode == "2" && PodConfirmFlag == false {
            if let info = AuthorizationManage.manage.GetLoginInfo(){
                clickGestureShowVerifyBtn(info)
            }
        }else{
            SendPodVerify()
        }
        //checkImageConfirm(pod, transactionId)
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
   
    func clickGestureShowVerifyBtn( _ info:LoginStrcture ) {
        AuthorizationManage.manage.SetLoginInfo(info)
         self.postRequest("Comm/COMM0110", "COMM0110",  AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10001","Operate":"termsConfirm","KINBR":info.bankCode,"uid": AgriBank_DeviceID], true), AuthorizationManage.manage.getHttpHead(true))
       // showGestureView( )
    }
    func GestureVerifyBtn(bankCode:String, success:NSInteger ) {
        // AuthorizationManage.manage.SetLoginInfo(info)
        switch success
        {
        case 1:
            SendConfirm()
    //失敗改密碼登入
      case 0:
            self.clickGestureVerCloseBtn(true)
            PodConfirmFlag = true
           // SendFastLogInError(bankCode)
            self.m_tvData.reloadData()
            
        default:
            break
        }
    }
  
   
    // MARK: - CLLocationManagerDelegate
    //    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    //        if status != .notDetermined && status != .authorizedAlways && status != .authorizedWhenInUse {
    //            let alert = UIAlertController(title: UIAlert_Default_Title, message: ErrorMsg_NoPositioning, preferredStyle: .alert)
    //            alert.addAction(UIAlertAction(title: Determine_Title, style: .default) { _ in
    //                self.navigationController?.popViewController(animated: true)
    //            })
    //            present(alert, animated: true, completion: nil)
    //        }
    //    }
}
