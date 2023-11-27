//
//  QRPayViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/6/26.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import Photos

class QRPayViewController: BaseViewController {
    @IBOutlet var m_vScanView: UIView!
    @IBOutlet weak var btn_PayCode: UIButton!
    var m_uiScanView : ScanCodeView? = nil
//    var m_vcScanView : ScanCodeViewController? = nil
    var m_strType : String = ""
    private var m_qrpInfo : MWQRPTransactionInfo? = nil
    var m_taxInfo : PayTax? = nil
    var m_dicSecureData : [String:String]? = nil
    var m_bIsLoadFromAlbum : Bool = false
    var m_MobileNo: String = ""

 
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if AuthorizationManage.manage.getCanShowQRCode0(){
//            btn_PayCode.isHidden = false
//        }
        getTransactionID("09002", TransactionID_Description)
    }
    func appWillEnterBackground(_ notification:NSNotification) {
        stopScan()
    }
    func appWillEnterForeground(_ notification:NSNotification) {
        if (m_bIsLoadFromAlbum == false) {
            startScan()
        }
        m_bIsLoadFromAlbum = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NSLog("======== QRPayViewController viewDidAppear ========")
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterBackground(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        super.viewDidAppear(animated)
        if (m_bIsLoadFromAlbum == false) {
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
    private func initScanView() {
        m_uiScanView = Bundle.main.loadNibNamed("ScanCodeView", owner: self, options: nil)?.first as? ScanCodeView
        m_uiScanView!.set(CGRect(origin: .zero, size: m_vScanView.bounds.size), self)
        m_vScanView.addSubview(m_uiScanView!)
    }
    
    // MARK:- UI Methods
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
       // m_spower64no = result.power64NO //台電
        
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
        //台電 add by sweney 2012//12/17
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
        #warning("need test")
//        let strSC = CFURLCreateStringByAddingPercentEscapes(nil, sc as CFString, nil, "!*'();:@&=$,/?%#[]" as CFString, CFStringBuiltInEncodings.UTF8.rawValue)
        let strSC = sc.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=$,/?%#[]"))
        return strSC! as String
    }

    // MARK:- WebService Methods
    private func send_checkQRCode() {
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
        //北市水及驗證繳費 chiu
        body["timestamp"] = m_oriURL    //chiu 109/04/20
        body["msgTAC"] = m_qrpInfo?.msgTAC()
        body["noticeNbr"] = m_qrpInfo?.noticeNbr()
        body["feeInfo"] = m_qrpInfo?.feeInfo()
        body["txnAmt"] = m_qrpInfo?.txnAmt()
        /*
         if (m_qrpInfo?.timestamp() != nil && m_qrpInfo?.timestamp().isEmpty == false) {
                   body["timestamp"] =  m_qrpInfo?.timestamp()
               }
         if (m_qrpInfo?.msgTAC() != nil && m_qrpInfo?.msgTAC().isEmpty == false) {
               body["msgTAC"] = m_qrpInfo?.msgTAC()
           }
         if (m_qrpInfo?.noticeNbr() != nil && m_qrpInfo?.noticeNbr().isEmpty == false) {
               body["noticeNbr"] = m_qrpInfo?.noticeNbr()
           }
 
         if (m_qrpInfo?.feeInfo() != nil && m_qrpInfo?.feeInfo().isEmpty == false) {
               body["feeInfo"] = m_qrpInfo?.feeInfo()
           }
       */
        postRequest("QR/QR0202", "QR0202", AuthorizationManage.manage.converInputToHttpBody2(body, true), AuthorizationManage.manage.getHttpHead(true)) //QR0201改為QR0202 chiu
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
    private func send_checkPayTaxCode() {
        m_taxInfo?.m_strPayTaxYear = "公元5000年"
        m_taxInfo?.m_strPayTaxMonth = "滿月"
        self.didResponse("checkPayTaxCode", [String:String]() as NSDictionary)
    }
    override func didResponse(_ description:String, _ response: NSDictionary) {
        self.setLoading(false)
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                //五倍卷  by sweney
                postRequest("Usif/USIF0101", "USIF0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"08001","Operate":"queryData","TransactionId":transactionId], true), AuthorizationManage.manage.getHttpHead(true))
                
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
                  if let mobilePhone = data["MPHONE"]  as? String {
                      m_MobileNo = mobilePhone
                  }
               //postRequest("QR/QR1001", "QR1001", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"11002","Operate":"getTerms","TransactionId":transactionId,"uid": AgriBank_DeviceID,"rebind":"0","born": birday
     // ], true), AuthorizationManage.manage.getHttpHead(true))
               
              }
          case "QR1001":
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode == ReturnCode_Success {
               if let data = response.object(forKey: ReturnData_Key) as? [String:AnyObject]{
                   
                   if (data["Read"] as? String == "3") {
                  
                      QuintupleFlag = false
                    
                   // self.initScanView()
                   }
                
                self.initScanView()   //chiu 20211004
                self.viewDidAppear(false) //chiu 2021 1004
                
               }}
        case "QR0202"://checkQRCode  //QR0202改為QR0202
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String {
                if returnCode == ReturnCode_Success {
                    if let dicData = response.object(forKey: ReturnData_Key) as? [String:Any] {
                        if let strSecureData = dicData["secureData"] as? String {
                            do {
                                let jsonDic = try JSONSerialization.jsonObject(with: strSecureData.data(using: .utf8)!, options: .mutableContainers) as? [String:Any]
                                m_dicSecureData = jsonDic as? [String : String]
                            }
                            catch {
                                showAlert(title: UIAlert_Default_Title, msg: error.localizedDescription, confirmTitle: "確認", cancleTitle: nil, completionHandler: startScan, cancelHandelr: {()})
                            }
                        }
                        if let strOtherInfo = dicData["otherInfo"] as? String {
                            do {
                                let jsonDic = try JSONSerialization.jsonObject(with: strOtherInfo.data(using: .utf8)!, options: .mutableContainers) as? [String:Any]
                                let dicOtherInfo : [String : String] = (jsonDic as? [String : String])!
                                if let noticeNbr = dicOtherInfo["tag21"] {
                                    m_qrpInfo?.setNoticeNbr(noticeNbr)
                                }
                                if let deadlinefinal = dicOtherInfo["tag22"] {
                                    m_qrpInfo?.setDeadlinefinal(deadlinefinal)
                                }
                                // chiu 北市水及驗證繳費 23 or 27
                                if let txnAmt = dicOtherInfo["tag23"] {
                                    m_qrpInfo?.setTxnAmt(txnAmt)
                                }
                                
                                //北市水及驗證繳費 chiu start
                                if let sPayType = dicOtherInfo["tag25"] {
                                    m_qrpInfo?.setsPayType(sPayType)
                                }
                                if let sBillSID = dicOtherInfo["tag26"] {
                                    m_qrpInfo?.setsBillSID(sBillSID)
                                }
                                if let txnAmt = dicOtherInfo["tag27"] {
                                    m_qrpInfo?.setTxnAmt(txnAmt)
                                }
                                //北市水及驗證繳費 chiu end
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
            
        case "checkPayTaxCode":
            performSegue(withIdentifier: "GoScanResult", sender: nil)
        default: super.didResponse(description, response)
        }
    }
    // MARK:- Handle Actions

}
// MARK:- extension
extension QRPayViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
            #if DEBUG
            NSLog("偵測圖片[%@][%.1f]", strQRCode, scale)
            #endif
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
extension QRPayViewController : ScanCodeViewDelegate {
    func GoPayCodeView() {
        performSegue(withIdentifier: "GoPayCode", sender: nil)
    }
    
    func clickBtnAlbum() {
        //m_bIsLoadFromAlbum = true
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
