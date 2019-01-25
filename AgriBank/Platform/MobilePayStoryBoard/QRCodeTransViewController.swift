//
//  QRCodeTransViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/6/26.
//  Copyright © 2018年 Systex. All rights reserved.
//

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
    
    @IBOutlet var m_vPaymentView: UIView!
    
    var m_uiActView : OneRowDropDownView? = nil
    var m_uiScanView : ScanCodeView? = nil

    private var m_strType : String = ""
    private var m_qrpInfo : MWQRPTransactionInfo? = nil
    private var m_taxInfo : PayTax? = nil
    var m_dicSecureData : [String:String]? = nil
    var m_bIsLoadFromAlbum : Bool = false

    var m_arrActList : [AccountStruct] = [AccountStruct]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initActView()
        self.initQRCodeArea()
        self.initScanView()
//        self.addObserverToKeyBoard()
        self.addGestureForKeyBoard()
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
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterBackground(_:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        super.viewDidAppear(animated)
        if (m_bIsLoadFromAlbum == false && m_vPaymentView.isHidden == false) {
            startScan()
        }
        m_bIsLoadFromAlbum = false
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIApplicationWillResignActive, object:nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIApplicationDidBecomeActive, object:nil)
        
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
        switch m_strType {
        case "01", "51":
            self.send_checkQRCode()
        case "02":
            if (AuthorizationManage.manage.getCanEnterP2PTrans() == true) {
                performSegue(withIdentifier: "GoScanResult", sender: nil)
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
        default:
            self.stopScan()
            showAlert(title: "不明type", msg: m_strType, confirmTitle: "確認", cancleTitle: nil, completionHandler: startScan, cancelHandelr: {()})
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
                    _ = self.clickBtnAlbum()
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
        let strSC = CFURLCreateStringByAddingPercentEscapes(nil, sc as CFString, nil, "!*'();:@&=$,/?%#[]" as CFString, CFStringBuiltInEncodings.UTF8.rawValue)
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
        body["paymentType"] = m_qrpInfo?.paymentType()
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
        postRequest("QR/QR0201", "QR0201", AuthorizationManage.manage.converInputToHttpBody2(body, true), AuthorizationManage.manage.getHttpHead(true))
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
                setLoading(true)
                self.send_getActList()
            }
            else {
                super.didResponse(description, response)
            }
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
            }
            else {
                super.didResponse(description, response)
            }
//        case "checkQRCode":
//            performSegue(withIdentifier: "GoScanResult", sender: nil)
        case "QR0201"://checkQRCode
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

        var strQR: String? = nil
        let QRInfo: TPSMerchantInfo = TPSMerchantInfo(dictionary: dicData)
        let QRMag: TPSQRCodeManager = TPSQRCodeManager.sharedManager
        QRMag.merchantInfo = QRInfo

        if (m_tfAmount.text!.isEmpty) {
            strQR = QRMag.staticQRCodeString()
        }
        else {
            strQR = QRMag.dynamicQRCodeString(txnAmt: m_tfAmount.text!)
        }
        if (strQR != nil) {
            self.m_ivQRCode.image = MakeQRCodeUtility.utility.generateQRCode(from: strQR!)
        }
        //=====
//        let strAct : String = (m_uiActView?.getContentByType(.First))!
//        let strAmount : String = m_tfAmount.text!
//        let strQRCode : String = "[\(strAct)][\(strAmount)]"
//        self.m_ivQRCode.image = MakeQRCodeUtility.utility.generateQRCode(from: strQRCode)
    }
}
// MARK:- extension
extension QRCodeTransViewController : ScanCodeViewDelegate {
    func clickBtnAlbum() {
        m_bIsLoadFromAlbum = true
        if (self.checkPhotoAuthorize()) {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                let controller : UIImagePickerController = UIImagePickerController()
                controller.delegate = self
                controller.sourceType = UIImagePickerControllerSourceType.photoLibrary
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    func getQRCodeString(_ strQRCode : String) {
        self.analysisQRCode(strQRCode)
    }
    func noPermission() {
        let confirmHandler : ()->Void = {() in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
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
