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
    var m_uiScanView : ScanCodeView? = nil
//    var m_vcScanView : ScanCodeViewController? = nil
    var m_strType : String = ""
    private var m_qrpInfo : MWQRPTransactionInfo? = nil
    var m_taxInfo : PayTax? = nil
    var m_bIsLoadFromAlbum : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
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
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterBackground(_:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        super.viewDidAppear(animated)
        if (m_bIsLoadFromAlbum == false) {
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
            showAlert(title: nil, msg: result.error, confirmTitle: "確認", cancleTitle: nil, completionHandler: startScan, cancelHandelr: {()})
            return
        }
        m_strType = result.type
        m_qrpInfo = result.qrp
        m_taxInfo = result.tax
        switch m_strType {
        case "01", "03", "51":
            self.send_checkQRCode()
        case "02":
            performSegue(withIdentifier: "GoScanResult", sender: nil)
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
        controller.setData(type: m_strType, qrp: m_qrpInfo, tax: m_taxInfo, transactionId: transactionId)
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
            showAlert(title: nil, msg: "無相簿權限", confirmTitle: "確認", cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
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
        body["processingCode"] = "000163"
        
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
            body["secureCode"] = self.encodeSecureCode((m_qrpInfo?.secureCode())!)
        }
        if (m_qrpInfo?.secureData() != nil && m_qrpInfo?.secureData().isEmpty == false) {
            body["secureData"] = self.encodeSecureCode((m_qrpInfo?.secureData())!)
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
        self.setLoading(false)
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
            }
            else {
                super.didResponse(description, response)
            }
        case "QR0201"://checkQRCode
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String {
                if returnCode == ReturnCode_Success {
                    performSegue(withIdentifier: "GoScanResult", sender: nil)
                }
                else {
                    if let type = response.object(forKey: "ActionType") as? String {
                        switch type {
                        case "showMsg":
                            if let returnMsg = response.object(forKey: ReturnMessage_Key) as? String {
                                showAlert(title: UIAlert_Default_Title, msg: returnMsg, confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: { self.startScan() }, cancelHandelr: {()})
                                showErrorMessage(nil, returnMsg)
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
//    @IBAction func m_btnAlbumClick(_ sender: Any) {
//        let status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
//        if (status == .authorized) {
//            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
//                stopScan()
//                let controller : UIImagePickerController = UIImagePickerController()
//                controller.delegate = self
//                controller.sourceType = UIImagePickerControllerSourceType.photoLibrary
//                self.present(controller, animated: true, completion: nil)
//            }
//        }
//    }
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
                    self.showAlert(title: nil, msg: "QR Code解析錯誤-請協助確認條碼是否清晰並排除圖片中非條碼的圖片內容", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: { self.startScan() }, cancelHandelr: {()})
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
extension QRPayViewController : ScanCodeViewDelegate {
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
#if DEBUG
        let confirmHandler : ()->Void = {() in
            if (UIApplication.shared.canOpenURL(URL(string:"App-Prefs:root=com.agribank.mbank-sit")!)) {
                UIApplication.shared.openURL(URL(string: "App-Prefs:root=com.agribank.mbank-sit")!)
            }
        }
#else
        let confirmHandler : ()->Void = {() in
            if (UIApplication.shared.canOpenURL(URL(string:"App-Prefs:root=org.naffic.mbank")!)) {
                UIApplication.shared.openURL(URL(string: "App-Prefs:root=org.naffic.mbank")!)
            }
        }
#endif
        let cancelHandler : ()->Void = {()}
        showAlert(title: "尚未授權相機功能", msg: "請先至設定啟用相機權限", confirmTitle: "設定", cancleTitle: "取消", completionHandler: confirmHandler, cancelHandelr: cancelHandler)
    }
}
