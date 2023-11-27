//
//  QRCodeTransViewController.swift
//  AgriBankf
//
//  Created by SYSTEX on 2018/6/26.
//  Copyright © 2018年 Systex. All rights reserved.
//
// 2019-9-2 Change by sweney + 取預設轉出帳號
import UIKit
import Photos

class QRCodeTransViewController: BaseViewController {
    @IBOutlet var m_vButtonView: UIView!
    @IBOutlet var m_btnReceipt: UIButton!
    @IBOutlet var m_btnPayment: UIButton!

    @IBOutlet var m_vReceiptView: UIView!
    @IBOutlet var m_vTopView: UIView!
    @IBOutlet var m_vActView: UIView!
    @IBOutlet var m_tfAmount: TextField!
    @IBOutlet var m_lbCommand: UILabel!
    @IBOutlet var m_vQRCodeArea: UIView!
    @IBOutlet var m_ivQRCode: UIImageView!
    
   // @IBOutlet weak var btn_ShowPayCode: UIButton!
    @IBOutlet var m_vPaymentView: UIView!
    
    var m_uiActView : OneRowDropDownView? = nil
    var m_uiScanView : ScanCodeView? = nil
    
    var strQR: String? = nil //sweney

    private var m_strType : String = ""
    private var m_qrpInfo : MWQRPTransactionInfo? = nil
    private var m_taxInfo : PayTax? = nil
    var m_dicSecureData : [String:String]? = nil
    var m_bIsLoadFromAlbum : Bool = false
    var QRMac:String = ""
    var m_MobileNo: String = ""
    
    //台電手機綁定
    var sMobilePhone: String? = ""
    
    var m_arrActList : [AccountStruct] = [AccountStruct]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initActView()
        self.initQRCodeArea()
       self.initScanView()
//        self.addObserverToKeyBoard()
        self.addGestureForKeyBoard()
//        if AuthorizationManage.manage.getCanShowQRCode0(){
//            btn_ShowPayCode.isHidden = false
//        }
        getTransactionID("09002", TransactionID_Description)
       
//        self.send_getActList()
    }
    func appWillEnterBackground(_ notification:NSNotification) {
        stopScan()
    }
    func appWillEnterForeground(_ notification:NSNotification) {
        if (m_bIsLoadFromAlbum == false && m_vPaymentView.isHidden == false) {
            startScan()
        }
        m_bIsLoadFromAlbum = false
    }
    func initScanView() {
        m_uiScanView = Bundle.main.loadNibNamed("ScanCodeView", owner: self, options: nil)?.first as? ScanCodeView
        m_uiScanView!.set(CGRect(origin: .zero, size: m_vPaymentView.bounds.size), self)
        m_vPaymentView.addSubview(m_uiScanView!)
    }
    func initQRCodeArea() {
        
       m_vQRCodeArea.layer.borderColor = UIColor.init(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: 1.0).cgColor
        m_vQRCodeArea.layer.borderWidth = 2.0
    }

    func startScan() {
        if (m_uiScanView == nil) {
            self.initScanView()
        }
        self.m_uiScanView!.startScan()
        m_bIsLoadFromAlbum = false
    }
    func stopScan() {
        guard self.m_uiScanView != nil else {
            return
        }
        self.m_uiScanView!.stopScan()
    }
    override func viewDidAppear(_ animated: Bool) {
        NSLog("======== QRPayViewController viewDidAppear ========")
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterBackground(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        super.viewDidAppear(animated)
        if (m_bIsLoadFromAlbum == false && m_vPaymentView.isHidden == false) {
            startScan()
        }
        m_bIsLoadFromAlbum = false
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name:UIApplication.willResignActiveNotification, object:nil)
        NotificationCenter.default.removeObserver(self, name:UIApplication.didBecomeActiveNotification, object:nil)
        
        stopScan()
        super.viewDidDisappear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // MARK:- Init Methods
    func initActView() {
        m_uiActView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        m_uiActView?.delegate = self
        m_uiActView?.frame = m_vActView.frame
        m_uiActView?.frame.origin = .zero
        m_uiActView?.setOneRow("轉入帳號", Choose_Title)
        m_uiActView?.m_lbFirstRowTitle.textAlignment = .center
        m_vActView.addSubview(m_uiActView!)

//        setShadowView(m_vButtonView)
        setShadowView(m_vTopView)
    }
    // MARK:- UI Methods
    private func changeFunction(_ isReceipt:Bool) {
        if isReceipt {
            m_btnReceipt.backgroundColor = Green_Color
            m_btnReceipt.setTitleColor(.white, for: .normal)
            m_btnPayment.backgroundColor = .white
            m_btnPayment.setTitleColor(.black, for: .normal)
            m_vReceiptView.isHidden = false
            m_vPaymentView.isHidden = true
            self.stopScan()
        }
        else {
            m_btnPayment.backgroundColor = Green_Color
            m_btnPayment.setTitleColor(.white, for: .normal)
            m_btnReceipt.backgroundColor = .white
            m_btnReceipt.setTitleColor(.black, for: .normal)
            m_vReceiptView.isHidden = true
            m_vPaymentView.isHidden = false
            self.startScan()
        }
    }
    func showActList() {
        if (m_arrActList.count > 0) {
            let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
            for actInfo in m_arrActList {
                actSheet.addButton(withTitle: actInfo.accountNO)
            }
            actSheet.tag = ViewTag.View_AccountActionSheet.rawValue
            actSheet.show(in: view)
        }
        else {
            showErrorMessage(nil, ErrorMsg_GetList_InCommonAccount)
        }
    }
    // MARK:- Logic Methods
    func analysisQRCode(_ strData : String) {
        let result = ScanCodeView.analysisQRCode(strData)
        guard result.error == nil else {
            showAlert(title: UIAlert_Default_Title, msg: result.error, confirmTitle: "確認", cancleTitle: nil, completionHandler: startScan, cancelHandelr: {()})
            return
        }
        m_strType = result.type
        m_qrpInfo = result.qrp
        m_taxInfo = result.tax
        m_qrpInfo?.setspower64No(result.power64NO)
        switch m_strType {
        case "01", "51":
            self.send_checkQRCode()
        case "02":
            if (AuthorizationManage.manage.getCanEnterP2PTrans() == true) {
                if (m_qrpInfo?.timestamp() != nil && m_qrpInfo?.timestamp().isEmpty == false) {
                self.send_checkQRCode()
                }else{
                performSegue(withIdentifier: "GoScanResult", sender: nil)
                }
            }
            else {
                showAlert(title: UIAlert_Default_Title, msg: ErrorMsg_NoAuth, confirmTitle: "確認", cancleTitle: nil, completionHandler: startScan, cancelHandelr: {()})
            }
        case "03":
            //for test
//            performSegue(withIdentifier: "GoScanResult", sender: nil)
            self.send_checkQRCode()
        case PayTax_Type11_Type, PayTax_Type15_Type:
            self.send_checkPayTaxCode()
        case "F0":
            let sPower64No = m_qrpInfo?.sPower64No()
            self.send_checkTaipower(power64no: sPower64No!)
        default:
            self.stopScan()
            showAlert(title: "不明type", msg: m_strType, confirmTitle: "確認", cancleTitle: nil, completionHandler: startScan, cancelHandelr: {()})
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoPayCode" { return }
        
        super.prepare(for: segue, sender: sender)
        let controller = segue.destination as! ScanResultViewController
        controller.setData(type: m_strType, qrp: m_qrpInfo, tax: m_taxInfo, transactionId: transactionId, secure: m_dicSecureData)
    }
    func checkPhotoAuthorize() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            return true
            
        case .notDetermined:
            // 请求授权
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    self.clickBtnAlbum()
                })
            })
            
        default:
            showAlert(title: UIAlert_Default_Title, msg: "無相簿權限", confirmTitle: "確認", cancleTitle: nil, completionHandler: startScan, cancelHandelr: {()})
        }
        return false
    }
    func resizeImage(image: UIImage, ratio: CGFloat) -> UIImage? {
        let newWidth = image.size.width * ratio
        let newHeight = image.size.height * ratio
        let newSize: CGSize = CGSize(width: newWidth, height: newHeight)
        
        let rect: CGRect = CGRect(origin: .zero, size: newSize)
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        image.draw(in: rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    private func encodeSecureCode(_ sc: String) -> String {
        //一銀是 !*'();:@&=+$,/?%#[]
//        let strSC = CFURLCreateStringByAddingPercentEscapes(nil, sc as CFString, nil, "!*'();:@&=$,/?%#[]" as CFString, CFStringBuiltInEncodings.UTF8.rawValue)
        #warning("need Test")
        let strSC = sc.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=$,/?%#[]"))
        return strSC! as String
    }
    private func checkQRCodeData() -> Bool {
        let act: String? = m_uiActView?.getContentByType(.First)
        if (act == nil || act?.isEmpty == true || act == Choose_Title) {
            showAlert(title: UIAlert_Default_Title, msg: "請選擇帳戶", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
            return false
        }
        let amount: Int? = Int(m_tfAmount.text!)
        if (amount != nil) {
            if (amount! <= 0) {
                showAlert(title: UIAlert_Default_Title, msg: ErrorMsg_Input_Amount, confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                return false
            }
//            else if (amount! > 30000) {
//                showAlert(title: UIAlert_Default_Title, msg: ErrorMsg_NotPredesignated_Amount, confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
//                return false
//            }
        }
        return true
    }
    // MARK:- WebService Methods
    private func makeFakeData() {
        m_arrActList.removeAll()
        for i in 0..<20 {
            var actInfo: AccountStruct = AccountStruct()
            actInfo.accountNO = String.init(format: "%05d", i)
            actInfo.currency = "TWNTD"
            actInfo.balance = String.init(format: "%d", i*1000+100)
            actInfo.status = "?"
            m_arrActList.append(actInfo)
        }
    }
    func send_getActList() {
//        self.makeFakeData()
        postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
    }
    //台電
    private func send_checkTaipower(power64no : String ) {
        self.setLoading(true)
        var body: [String:String] = [String:String]()
        body["WorkCode"] = "09012"
        body["Operate"] = "getTaipowerData"
        body["TransactionId"] = transactionId
        body["appId"] = AgriBank_AppID
        body["power64No"] = power64no
         
        postRequest("QR/QR0203", "QR0203", AuthorizationManage.manage.converInputToHttpBody2(body, true), AuthorizationManage.manage.getHttpHead(true))
    }
    
    private func send_checkQRCode() {
        //self.didResponse("checkQRCode", [String:String]() as NSDictionary)
        self.setLoading(true)
        var body: [String:String] = [String:String]()
        body["WorkCode"] = "09002"
        body["Operate"] = "QRConfirm"
        body["TransactionId"] = transactionId
        body["appId"] = AgriBank_AppID
        body["countryCode"] = m_qrpInfo?.countryCode()
        body["transType"] = m_strType == "51" ? "01" : m_strType
        body["processingCode"] = m_strType == "02" ? "000162" : "000163"
        
        if (m_qrpInfo?.acqBank() != nil && m_qrpInfo?.acqBank().isEmpty == false) {
            body["acqBank"] = m_qrpInfo?.acqBank()
        }
        if (m_qrpInfo?.terminalId() != nil && m_qrpInfo?.terminalId().isEmpty == false) {
            body["terminalId"] = m_qrpInfo?.terminalId()
        }
        if (m_qrpInfo?.merchantId() != nil && m_qrpInfo?.merchantId().isEmpty == false) {
            body["merchantId"] = m_qrpInfo?.merchantId()
        }
        if (m_qrpInfo?.merchantName() != nil && m_qrpInfo?.merchantName().isEmpty == false) {
            body["merchantName"] = m_qrpInfo?.merchantName()//.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        }
       
        if (m_qrpInfo?.secureCode() != nil && m_qrpInfo?.secureCode().isEmpty == false) {
            body["secureCode"] = m_qrpInfo?.secureCode()
        }
        if (m_qrpInfo?.secureData() != nil && m_qrpInfo?.secureData().isEmpty == false) {
            body["secureData"] = m_qrpInfo?.secureData()
        }
        if (m_qrpInfo?.acqInfo() != nil && m_qrpInfo?.acqInfo().isEmpty == false) {
            body["acqBankInfo"] = m_qrpInfo?.acqInfo()
        }
        if (m_qrpInfo?.qrExpirydate() != nil && m_qrpInfo?.qrExpirydate().isEmpty == false) {
            body["qrExpirydate"] = m_qrpInfo?.qrExpirydate()
        }
        if (m_qrpInfo?.deadlinefinal() != nil && m_qrpInfo?.deadlinefinal().isEmpty == false) {
            body["deadlinefinal"] = m_qrpInfo?.deadlinefinal()
        }
        //北市水及驗證繳費 chiu
        if (m_qrpInfo?.timestamp() != nil && m_qrpInfo?.timestamp().isEmpty == false) {
            body["timestamp"] = m_oriURL
        }
        if (m_qrpInfo?.msgTAC() != nil && m_qrpInfo?.msgTAC().isEmpty == false) {
            body["msgTAC"] = m_qrpInfo?.msgTAC()
        }
       
        if(m_qrpInfo?.walletBaseCode() != nil && m_qrpInfo?.walletBaseCode()?.isEmpty == false)
        {
            body["walletBasecode"] = m_qrpInfo?.walletBaseCode()
        }
        if(m_qrpInfo?.transfereeBank()  != nil && m_qrpInfo?.transfereeBank()?.isEmpty == false)
        {
            body["transfereeBank"] = m_qrpInfo?.transfereeBank()
        }
        if(m_qrpInfo?.transfereeAccount() != nil && m_qrpInfo?.transfereeAccount()?.isEmpty == false)
        {
            body["transfereeAccount"] = m_qrpInfo?.transfereeAccount()
        }
        body["paymentType"] = "51" //m_qrpInfo?.paymentType()
         
        
        if (m_qrpInfo?.noticeNbr() != nil && m_qrpInfo?.noticeNbr().isEmpty == false) {
            body["noticeNbr"] = m_qrpInfo?.noticeNbr()
        }
        if (m_qrpInfo?.feeInfo() != nil && m_qrpInfo?.feeInfo().isEmpty == false) {
            body["feeInfo"] = m_qrpInfo?.feeInfo()
        }
        postRequest("QR/QR0202", "QR0202", AuthorizationManage.manage.converInputToHttpBody2(body, true), AuthorizationManage.manage.getHttpHead(true)) //QR0201改為QR0202 chiu
    }
    private func send_checkPayTaxCode() {
        m_taxInfo?.m_strPayTaxYear = "公元5000年"
        m_taxInfo?.m_strPayTaxMonth = "滿月"
        self.didResponse("checkPayTaxCode", [String:String]() as NSDictionary)
    }
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                //五倍卷  by sweney
                postRequest("Usif/USIF0101", "USIF0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"08001","Operate":"queryData","TransactionId":transactionId], true), AuthorizationManage.manage.getHttpHead(true))
                setLoading(true)
                self.send_getActList()
            }
            else {
                super.didResponse(description, response)
            }
        //五倍卷   by sweney
          case "USIF0101":
              if let data = response.object(forKey: ReturnData_Key) as? [String:Any] {
                  var birday = ""
                  if let birthday = data["BIRTHDAY"] as? String {
                      birday = birthday
                  }
                  if let mobilePhone = data["MPHONE"] as? String, !mobilePhone.isEmpty {
                      //手機號碼不為空，更新畫面打註冊手機門號資料api
                      sMobilePhone = mobilePhone
                  }
                        
               //postRequest("QR/QR1001", "QR1001", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"11002","Operate":"getTerms","TransactionId":transactionId,"uid": AgriBank_DeviceID,"rebind":"0","born": birday
      //], true), AuthorizationManage.manage.getHttpHead(true))
               
              }
          case "QR1001":
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {}else{
               if let data = response.object(forKey: ReturnData_Key) as? [String:AnyObject]{
                   
                   if (data["Read"] as? String == "3") {
                  
                      QuintupleFlag = false
                    
                    self.initScanView()
                   }}}
        case "ACCT0101":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]]{
                for category in array {
                    if let type = category["ACTTYPE"] as? String, let result = category["AccountInfo"] as? [[String:Any]], type == Account_Saving_Type {
                        m_arrActList.removeAll()
                        for actInfo in result {
                            if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? String, let ebkfg = actInfo["EBKFG"] as? String, ebkfg == Account_EnableTrans {
                                m_arrActList.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
                            }
                        }
                    }
                }
                
              
                //2019-9-2 add by sweney -取index=0轉出帳號
                if(m_arrActList.count) > 0 {
                        let info : AccountStruct = m_arrActList[0]
                         m_uiActView?.setOneRow("轉入帳號", info.accountNO)
                        break
                    }
              
            }
            else {
                super.didResponse(description, response)
            }
//        case "checkQRCode":
//            performSegue(withIdentifier: "GoScanResult", sender: nil)
        case "QR0202"://checkQRCode
                        //QR0201改為QR0202 北市水及驗證繳費
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String {
                if returnCode == ReturnCode_Success {
                    let dicData = response.object(forKey: ReturnData_Key) as? [String:Any]
                    if (dicData != nil) {
                        let strSecureData = dicData!["secureData"] as? String
                        if (strSecureData != nil) {
                            do {
                                let jsonDic = try JSONSerialization.jsonObject(with: strSecureData!.data(using: .utf8)!, options: .mutableContainers) as? [String:Any]
                                m_dicSecureData = jsonDic as? [String : String]
                               
                            }
                            catch {
                                showAlert(title: UIAlert_Default_Title, msg: error.localizedDescription, confirmTitle: "確認", cancleTitle: nil, completionHandler: startScan, cancelHandelr: {()})
                            }
                        }
                    }
                    performSegue(withIdentifier: "GoScanResult", sender: nil)
                }
                else {
                    if let type = response.object(forKey: "ActionType") as? String {
                        switch type {
                        case "showMsg":
                            if let returnMsg = response.object(forKey: ReturnMessage_Key) as? String {
                                showAlert(title: UIAlert_Default_Title, msg: returnMsg, confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: { self.startScan() }, cancelHandelr: {()})
                            }
                        default:
                            break
                        }
                    }
                }
            }
            //台電
        case "QR0203":
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String {
                if returnCode == ReturnCode_Success {
                    if let dicData = response.object(forKey: ReturnData_Key) as? [String:Any]  {
                        m_qrpInfo?.setsMobileNo(m_MobileNo)
                        if let strpowerNo = dicData["powerNo"] as? String {
                            m_qrpInfo?.setspowerNo(strpowerNo)
                        }
                        if let strMBarcode = dicData["MBarcode"] as? String {
                            m_qrpInfo?.setsMBarcode(strMBarcode)
                        }
                        if  var  strpowerInfo = dicData["powerInfo"] as? [[String:Any]]{
                          
                            m_qrpInfo?.setsTaipowerInfo(strpowerInfo)
                            
                            m_qrpInfo?.setsTotalCount(String(strpowerInfo.count))
                            //金額
                            var temptotalamout = 0
                            for i in 0..<strpowerInfo.count  {
                                temptotalamout =  strpowerInfo[i]["para3"] as! Int  + temptotalamout
                                strpowerInfo[i]["para3"] =  String(describing:strpowerInfo[i]["para3"] as? Int ?? 0) + "00"
                            }
                            m_qrpInfo?.setsTotalAmount(temptotalamout as NSNumber)
                            
                            let ItemJson = try? JSONSerialization.data(withJSONObject: strpowerInfo, options: [.sortedKeys])
                            let ItemList = String(data: ItemJson!, encoding: .utf8)
                            m_qrpInfo?.setsItemList(ItemList)
                            m_qrpInfo?.setsItemarrayList(strpowerInfo)
                            
                        }
                       
                        if let strOtherInfo = dicData["otherInfo"] as? String {
                            do {
                                let jsonDic = try JSONSerialization.jsonObject(with: strOtherInfo.data(using: .utf8)!, options: .mutableContainers) as? [String:Any]
                                let dicOtherInfo : [String : String] = (jsonDic as? [String : String])!
                                //paytype
                                if let sPayType = dicOtherInfo["tag25"] {
                                    m_qrpInfo?.setsPayType(sPayType)
                                }
                                //billsid
                                if let sBillSID = dicOtherInfo["tag26"] {
                                    m_qrpInfo?.setsBillSID(sBillSID)
                                }
                               
                            }
                            catch {
                                showAlert(title: UIAlert_Default_Title, msg: error.localizedDescription, confirmTitle: "確認", cancleTitle: nil, completionHandler: startScan, cancelHandelr: {()})
                            }
                        }
                        
 
                    }
                    performSegue(withIdentifier: "GoScanResult", sender: nil)
                }
                else {
                    if let type = response.object(forKey: "ActionType") as? String {
                        switch type {
                        case "showMsg":
                            if let returnMsg = response.object(forKey: ReturnMessage_Key) as? String {
                                showAlert(title: UIAlert_Default_Title, msg: returnMsg, confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {
                                    self.startScan() }, cancelHandelr: {()})
                            }
                        default:
                            break
                        }
                    }
                }
            }
            
        case "QR0703":
        if let returnCode = response.object(forKey: ReturnCode_Key) as? String {
            if returnCode == ReturnCode_Success {
                let dicData = response.object(forKey: ReturnData_Key) as? [String:Any]
                if (dicData != nil) {
                    let strMACData = dicData!["MAC"] as? String
                    if (strMACData != nil) {
                        QRMac = strMACData!
                        let strD99 = "&D99=" + QRMac
                        strQR! += strD99.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
                        showQRCode(_strQRcode: strQR!)
                    }
                }
            }else{
                if let returnMsg = response.object(forKey: ReturnMessage_Key) as? String {
                        showErrorMessage(nil, returnMsg)
                    }
            }
        }
        case "checkPayTaxCode":
            performSegue(withIdentifier: "GoScanResult", sender: nil)
        default: super.didResponse(description, response)
        }
    }
    // MARK:- Handle Actions
    @IBAction func m_btnReceiptClick(_ sender: Any) {
        self.dismissKeyboard()
        self.changeFunction(true)
    }
    @IBAction func m_btnPaymentClick(_ sender: Any) {
        self.dismissKeyboard()
        self.changeFunction(false)
    }
    @IBAction func m_btnMakeQRCodeClick(_ sender: Any) {
        self.dismissKeyboard()
        //=====
        guard checkQRCodeData() == true else {
            return
        }
        var dicData: [String:String] = [String:String]()
        dicData["merchantName"] = "農漁行動達人"//"農業金庫"
        dicData["countryCode"] = "158"
        dicData["qrVersion"] = "V1"
        dicData["shopType"] = "TRANSFER"
        let act = m_uiActView?.getContentByType(.First)
        dicData["transfereeBank"] = act?.substring(to: 2)//AuthorizationManage.manage.GetLoginInfo()?.bankCode.substring(to: (AuthorizationManage.manage.GetLoginInfo()?.bankCode.count)! - 3)
        dicData["transfereeAccount"] = act

        //var strQR: String? = nil
        let QRInfo: TPSMerchantInfo = TPSMerchantInfo(dictionary: dicData)
        let QRMag: TPSQRCodeManager = TPSQRCodeManager.sharedManager
        QRMag.merchantInfo = QRInfo

        if (m_tfAmount.text!.isEmpty) {
            strQR = QRMag.staticQRCodeString()
        }
        else {
            strQR = QRMag.dynamicQRCodeString(txnAmt: m_tfAmount.text!)
        }
        if (strQR != nil){
            if let strTransfereeAccount = dicData["transfereeAccount"] {
            var temp = strTransfereeAccount
            if temp.count < 16 {
                for _ in 0..<(16-temp.count) {
                    temp = "0" + temp
                }  }
                getMacCode(_inbank: dicData["transfereeBank"]! , _cardactno: temp , _strUrl: strQR! )
            }
        }
//        if (strQR != nil) {
//            self.m_ivQRCode.image = MakeQRCodeUtility.utility.generateQRCode(from: strQR!)
//        }
        //=====
//        let strAct : String = (m_uiActView?.getContentByType(.First))!
//        let strAmount : String = m_tfAmount.text!
//        let strQRCode : String = "[\(strAct)][\(strAmount)]"
//        self.m_ivQRCode.image = MakeQRCodeUtility.utility.generateQRCode(from: strQRCode)
    }
    private func getMacCode (_inbank :String,_cardactno :String,_strUrl:String)
    {
        postRequest("QR/QR0703", "QR0703", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"09010","Operate":"getP2PMac","TransactionId":transactionId,"INBANK":_inbank,"CARDACTNO": _cardactno,"UrlData": _strUrl], true), AuthorizationManage.manage.getHttpHead(true))
    }
    private func showQRCode(_strQRcode:String){
        if (_strQRcode != "") {
            self.m_ivQRCode.image = MakeQRCodeUtility.utility.generateQRCode(from: _strQRcode)
        }
    }
}

// MARK:- extension
extension QRCodeTransViewController : ScanCodeViewDelegate {
    func GoPayCodeView() {
      performSegue(withIdentifier: "GoPayCode", sender: nil)
    }
    
    func clickBtnAlbum() {
        m_bIsLoadFromAlbum = true
        if (self.checkPhotoAuthorize()) {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
                let controller : UIImagePickerController = UIImagePickerController()
                controller.delegate = self
                controller.sourceType = UIImagePickerController.SourceType.photoLibrary
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    func getQRCodeString(_ strQRCode : String) {
        self.analysisQRCode(strQRCode)
    }
    func noPermission() {
        let confirmHandler : ()->Void = {() in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl)  {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    })
                }
                else  {
                    UIApplication.shared.openURL(settingsUrl)
                }
            }
        }
        let cancelHandler : ()->Void = {()}
        showAlert(title: "尚未授權相機功能", msg: "請先至設定啟用相機權限", confirmTitle: "設定", cancleTitle: "取消", completionHandler: confirmHandler, cancelHandelr: cancelHandler)
    }
}
extension QRCodeTransViewController : OneRowDropDownViewDelegate {
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        self.dismissKeyboard()
        if (m_arrActList.count == 0) {
            self.send_getActList()
        }
        else {
            self.showActList()
        }
    }
}
extension QRCodeTransViewController : UIActionSheetDelegate {
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet.cancelButtonIndex != buttonIndex {
            switch (actionSheet.tag) {
            case ViewTag.View_AccountActionSheet.rawValue:
                let iIndex : Int = buttonIndex - 1
                let info : AccountStruct = m_arrActList[iIndex]
                let act : String = info.accountNO
                if (m_uiActView?.getContentByType(.First) != act) {
                    m_uiActView?.setOneRow("轉入帳號", act)
                    self.m_ivQRCode.image = nil
                }
            default:
                break
            }
        }
    }
}
extension QRCodeTransViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        self.setLoading(true)
        DispatchQueue.main.async {
            let image : UIImage = info["UIImagePickerControllerOriginalImage"] as! UIImage
            var strQRCode : String = ScanCodeView.detectQRCode(image)
            //0.75 0.5 0.4
            var scale: CGFloat = 1.0
            while strQRCode.isEmpty == true {
                if (scale == 1.0) {
                    scale = 0.75
                }
                else if (scale == 0.75) {
                    scale = 0.5
                }
                else if (scale == 0.5) {
                    scale = 0.4
                }
                else if (scale == 0.4) {
                    scale = -1.0
                }
                
                if (scale > 0) {
                    //                scale -= 0.1
                    let tempImage = self.resizeImage(image: image, ratio: scale)
                    if (tempImage != nil) {
                        strQRCode = ScanCodeView.detectQRCode(tempImage!)
                    }
                    else {
                        break
                    }
                }
                else {
                    self.showAlert(title: UIAlert_Default_Title, msg: "QR Code解析錯誤-請協助確認條碼是否清晰並排除圖片中非條碼的圖片內容", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: { self.startScan() }, cancelHandelr: {()})
                    self.setLoading(false)
                    return
                }
            }
            self.setLoading(false)
            m_oriURL = strQRCode //add by sweney for 市水
            NSLog("偵測圖片[%@][%.1f]", strQRCode, scale)
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {() in
                self.analysisQRCode(strQRCode)
            })
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        m_bIsLoadFromAlbum = false
    }
}
extension QRCodeTransViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        guard DetermineUtility.utility.isAllNumber(newString) else {
            return false
        }
        
        let newLength = (textField.text?.count)! - range.length + string.count
        let maxLength = Max_GetAmount_Length
        if newLength <= maxLength {
//            m_tfAmount.text = newString
            self.m_ivQRCode.image = nil
            return true
        }
        else {
            return false
        }
    }
}
