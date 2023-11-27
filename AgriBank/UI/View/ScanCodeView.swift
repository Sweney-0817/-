//
//  ScanCodeView.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/7/6.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit
import AVFoundation
protocol ScanCodeViewDelegate {
    func clickBtnAlbum()
    func getQRCodeString(_ strQRCode : String)
    func noPermission()
    func GoPayCodeView()
}

class ScanCodeView: UIView {
    @IBOutlet var m_vCameraArea: UIView!
    @IBOutlet var m_vScanArea: UIView!
    @IBAction func m_btnAlbumClick(_ sender: Any) {
        m_delegate.clickBtnAlbum()
    }
    private var m_qrpInfo : MWQRPTransactionInfo? = nil
    private var captureSession: AVCaptureSession? = nil
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer? = nil
    private var output: AVCaptureMetadataOutput? = nil
    //台電
     var sPower64No = ""
    
    var scanning : Bool = false
    var m_delegate : ScanCodeViewDelegate!
    
    @IBOutlet weak var btn_PayCode: UIButton!
    @IBOutlet weak var PayCodeLabel: UILabel!
    @IBOutlet weak var img_Quintuple: UIImageView!
    @IBAction func btn_PayCode(_ sender: Any) {
        if pushReceiveFlag == "PAY"{
            pushReceiveFlag = ""
        }
        pushResultList = nil;
        self.m_delegate.GoPayCodeView()
    }
    func set(_ frame : CGRect, _ delegate : ScanCodeViewDelegate) {
        self.frame = frame
        self.layoutIfNeeded()
        self.m_delegate = delegate
        img_Quintuple.isHidden = QuintupleFlag
        if AuthorizationManage.manage.getCanShowQRCode0() == true {
            btn_PayCode.isHidden = false
            PayCodeLabel.isHidden = false
        }else
        {
            btn_PayCode.isHidden = true
            PayCodeLabel.isHidden = true
        }
    }
    
    func startScan() {
        guard scanning == false else {
            return
        }
        NSLog("======== ScanCodeView startScan ========")
        m_oriURL = ""   //chiu
        let captureDevice = AVCaptureDevice.default(for: .video)
        var input: AVCaptureDeviceInput? = nil
        do {
            input = try AVCaptureDeviceInput.init(device: captureDevice!)
        }
        catch {
            self.m_delegate.noPermission()
            return
        }
        
        captureSession = AVCaptureSession.init()
        captureSession?.addInput(input!)
        output = AVCaptureMetadataOutput.init()
        captureSession?.addOutput(output!)
//        let captureQueue = DispatchQueue.init(label: "captureQueue")
//        output?.setMetadataObjectsDelegate(self, queue: captureQueue)
        output?.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output?.metadataObjectTypes = output?.availableMetadataObjectTypes
        
        //計算中間可探測區域
        let windowSize = m_vCameraArea.bounds.size
        var scanRect = m_vScanArea.frame
        //計算rectOfInterest 注意x,y交換位置
        scanRect = CGRect(x:scanRect.origin.y/windowSize.height,
                          y:scanRect.origin.x/windowSize.width,
                          width:scanRect.size.height/windowSize.height,
                          height:scanRect.size.width/windowSize.width);
        
        //設置可探測區域
        output?.rectOfInterest = scanRect
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: captureSession!)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = m_vCameraArea.frame
        videoPreviewLayer?.frame.origin = CGPoint(x: 0, y: 0)
        
        m_vCameraArea.layer.addSublayer(videoPreviewLayer!)
        captureSession?.startRunning()
        
        drawrect()
//        startNotification()
        scanning = true
    }
    func stopScan() {
        guard scanning == true else {
            return
        }
        NSLog("======== ScanCodeView stopScan ========")
        scanning = false
//        stopNotification()
        captureSession?.stopRunning()
        captureSession = nil
        videoPreviewLayer?.removeFromSuperlayer()
        videoPreviewLayer = nil
    }
    private func drawrect() {
        let clearPath : UIBezierPath = UIBezierPath(rect: m_vScanArea.frame)
        let path : UIBezierPath = UIBezierPath(rect: m_vCameraArea.frame)
        path.append(clearPath)
        path.usesEvenOddFillRule = true
        
        let fillLayer : CAShapeLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = .evenOdd
//        fillLayer.fillColor = UIColor.init(red: 73.0/255.0, green: 73.0/255.0, blue: 73.0/255.0, alpha: 0.58).cgColor
     //   fillLayer.opacity = 0.8
           fillLayer.fillColor = UIColor.init(red: 233.0/255.0, green: 76.0/255.0, blue: 150.0/255.0, alpha: 1).cgColor
        fillLayer.opacity = 1
        m_vCameraArea.layer.addSublayer(fillLayer)
        
//        m_vScanArea.layer.borderColor = Green_Color.cgColor
//        m_vScanArea.layer.borderWidth = 2
    }
//    private func startNotification() {
//        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil, queue: OperationQueue.current, using: avCaptureInputPortFormatDescriptionDidChangeNotification)
//    }
//    private func stopNotification() {
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil)
//    }
//    func avCaptureInputPortFormatDescriptionDidChangeNotification(_ notification: Notification?) {
//        guard scanning else {
//            return
//        }
//        let rect : CGRect = m_vScanArea.frame
//        output?.rectOfInterest = (videoPreviewLayer?.metadataOutputRectOfInterest(for: rect))!
//    }
}
extension ScanCodeView : AVCaptureMetadataOutputObjectsDelegate {
//    func captureOutput(_ output: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard scanning else {
            return
        }

        if metadataObjects.count == 0 {
            NSLog("no objects returned")
            return
        }
        let metaDataObject = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
        guard let StringCodeValue = metaDataObject?.stringValue else {
            NSLog("掃到空的")
            return
        }
//        AudioServicesPlayAlertSound(1016)//震動
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {() in
            #if DEBUG
            NSLog("掃到[%@]", StringCodeValue)
            #endif
            self.stopScan()
            m_oriURL = StringCodeValue  //chiu 109/04/20 未decode ==> 請Android改回
            self.m_delegate.getQRCodeString(StringCodeValue)
        })
    }
}
extension ScanCodeView {
    static private func getFirstTWQRP(_ strData : String) -> String {
        let strInput : String = strData.removingPercentEncoding!
        if ((strInput.range(of: "TWQRP", options: String.CompareOptions.caseInsensitive)) != nil) {
            let arrInput : Array = strInput.components(separatedBy: CharacterSet.newlines)
            if arrInput.count == 1 {
                let ranTWQRP : Range = (strInput.range(of: "TWQRP", options: String.CompareOptions.caseInsensitive))!
                #warning("need Test")
                let strNeed = String(strInput[..<ranTWQRP.lowerBound])
                return strNeed
            }
            else {
                for strSubString : String in arrInput {
                    if (strSubString.hasPrefix("TWQRP")) {
//                    if ((strSubString.range(of: "TWQRP", options: String.CompareOptions.caseInsensitive)) != nil) {
                        let strNeed = strSubString.replacingOccurrences(of: "\r", with: "")
                        return strNeed
                    }
                    else
                    {
                        if ((strSubString.range(of: "TWQRP", options: String.CompareOptions.caseInsensitive)) != nil) {
                            let ranTWQRP : Range = (strSubString.range(of: "TWQRP", options: String.CompareOptions.caseInsensitive))!
                            #warning("need Test")
                            let strNeed = String(strSubString[..<ranTWQRP.lowerBound])
                            return strNeed
                        }
                    }
                }
            }
        }
        return ""
    }
    static private func isPayTaxFormat(_ nsURL : String) -> (type:String, tax:PayTax?)? {
        let nsData : String? = getPayTaxData(nsURL)
        guard nsData != nil else {
            return nil
        }
        return setPayTaxData(nsData!)
    }
 
    static private func getPayTaxData(_ nsURL : String) -> String? {
        let url : NSURL? = NSURL(string: nsURL)
        if (url != nil) {
        if (url!.scheme == PayTax_URL_scheme && url!.host == PayTax_URL_host) {
            let urlComponents : [String] = url!.query!.components(separatedBy:"&")
            for keyValuePair : String in urlComponents {
                let pairComponents : [String] = keyValuePair.components(separatedBy:"=")
                let key : String = pairComponents.first!.removingPercentEncoding!
                if (key == "par") {
                    return pairComponents.last!.removingPercentEncoding!
                }
            }
        }
        }
        return nil
    }
    
    //台電check add by sweney -2012/12/17
    static private func isTaipowerFormat(_ nsURL : String) -> (Bool)? {
        let url : NSURL? = NSURL(string: nsURL)
        if (url != nil) {
        if (url!.scheme == Taipower_URL_scheme && url!.host == Taipower_URL_host) {
           // let sURL = nsURL
           // let power64no = (String(sURL.suffix(from: sURL.index(sURL.endIndex, offsetBy: -64))) as  String )
           return true
        }
          return false
        }
        return false
    }
   
    
    static private func setPayTaxData(_ nsData : String) -> (type:String, tax:PayTax?)? {
        var type : String = ""
        var tax : PayTax? = nil
//        var bIsCorrect : Bool = false
        // QRCode規格如下:
        // 1.查(核)定類稅款：https://paytax.nat.gov.tw/QRCODE.aspx?par= + (5位繳款類別) + (16位銷帳編號)+ (10位繳款金額) + (6繳納截止日)+ (5位期別代號)+ (6位識別碼)，共48字元。
        // 2.綜所稅：https://paytax.nat.gov.tw/QRCODE.aspx?par= + (5位繳款類別，固定值:15001) 共5字元
        
        // 先檢核長度是否正確
        if (nsData.count == PayTax_Type11_Length) {
//            bIsCorrect = true
            type = PayTax_Type11_Type
            tax = PayTax()
            tax?.taxType = nsData.substring(from: 0, length: 5)
            tax?.number = nsData.substring(from: 5, length: 16)
            tax?.amount = nsData.substring(from: 21, length: 10)
            tax?.deadLine = nsData.substring(from: 31, length: 6)
            tax?.periodCode = nsData.substring(from: 37, length: 5)
            
        }
        else if (nsData.count == PayTax_Type15_Length) {
//            bIsCorrect = true
            type = PayTax_Type15_Type
            tax = PayTax()
            tax?.taxType = nsData.substring(from: 0, length: 5)
            tax?.number = nil
            tax?.amount = nil
            tax?.deadLine = nil
            tax?.periodCode = nil
        }
        if (self.getTypeName((tax?.taxType)!, setDate:tax?.deadLine).isEmpty == true) {
//            bIsCorrect = false
//            tax?.taxType = nil
//            tax?.number = nil
//            tax?.amount = nil
//            tax?.deadLine = nil
//            tax?.periodCode = nil
            return nil
        }
//        return bIsCorrect
        return (type, tax)
    }
    static private func getTypeName(_ type : String, setDate date : String?) -> String {
        // 正常 date = (6繳納截止日) = 民國年月日
        var name : String? = nil
        if (date != nil && date?.count == 6) {
            let temp : String = (date?.substring(from: 2, length: 2))!
            if (temp.isEmpty == false && Int(temp) != 0) {
                if (Int(temp)! <= 6) {// 上半年
                    name = PayTax.getTypeName(true)[type]
                }
                else {
                    name = PayTax.getTypeName(false)[type]
                }
            }
        }
        else {
            name = PayTax.getTypeName(true)[type]
        }
        return name ?? ""
    }
    static func analysisQRCode(_ strOriData : String) -> (type : String, tax : PayTax?, qrp : MWQRPTransactionInfo?, error : String?,power64NO : String?) {
        var strData = strOriData//.replacingOccurrences(of: "+", with: " ")
        var type : String = ""
        var tax : PayTax? = nil
        var qrp : MWQRPTransactionInfo? = nil
        var error : String? = nil
        var power64No : String? = ""
        
        //add for EMVCo   by sweney  ->實機才可以測so check targetEnvironment
        #if targetEnvironment(simulator)
        #else 
        let verifier = Verifier()
        verifier.txn_msg = strData
        
        let cksize = verifier.checkSize()
        // print("ckeck size=" + String(cksize))
       
        let ckpayload = verifier.checkPayload()
        //print("Payload=" + String(ckpayload))
        
        let crc = verifier.checkCRC()
        //print("crc=" + String(crc))
        if crc == true{
            let rcode = verifier.rootParse()
            //print("Root Parse=" + String(rcode))
            
            let rcode2 = verifier.fullParse()
            // print("Full Parse=" + String(rcode2))
        }
        
        let QrType = verifier.getQRtype()
        if QrType == -1 {
            strData = strData.replacingOccurrences(of: "+", with: " ")
        }else{
            strData = verifier.convertToTaiwanPay()
        }
        
        switch QrType {
        case -1:
            print("QrType = 非 EMVCo 或 TWPay")
            break;
        case 1:
            print("QrType=僅 EMVCo")
            break;
        case 2:
            print("QrType=含 EMVCo 及 TWPay")
            break;
        case 3:
            print("QrType=僅 TWPay")
            break;
        default:
            break;
        }
        
        //  let SupScheme = verifier.getSupportScheme()
        #endif
        
        //EMVCo
        
        let strInput : String = self.getFirstTWQRP(strData)
        qrp = MWQRPTransactionInfo(qrCodeURL: strInput)
        if (qrp?.isValidQRCodeFromat())! {
            if qrp?.txnCurrencyCode() != nil && qrp?.txnCurrencyCode() != "901" {
                type = ""
                error = String(format: "尚不支援此交易幣別(%@)", (qrp?.txnCurrencyCode())!)
            }
            else {
                switch (qrp?.transactionType)! {
                case .purchase:
                    type = "01"
//                    type = ""
//                    error = "尚未提供消費扣款服務(QRS-002)"
                case .p2PTransfer:
                    type = "02"
//                    type = ""
//                    error = "尚未提供P2P轉帳服務(QRS-005)"
                case .bill:
                    type = "03"
//                    type = ""
//                    error = "尚未提供繳費服務(QRS-003)"
                case .transferPurchase:
                    type = "51"
                default:
                    type = ""
                    error = "尚未提供此服務"
                }
            }
        }
        else if let a = self.isPayTaxFormat(strData) {
            type = a.type
            tax = a.tax
            //            self.send_checkPayTaxCode()
            type = ""
            error = "尚未提供繳稅服務"
//            showAlert(title: UIAlert_Default_Title, msg: "尚未提供繳稅服務(QRS-004)", confirmTitle: "確認", cancleTitle: nil, completionHandler: startScan, cancelHandelr: {()})
        }
        //台電check add by sweney 2012/12/17
        else if  self.isTaipowerFormat(strData) == true {
           type = "F0"
            let sURL = strData
            power64No = (String(sURL.suffix(from: sURL.index(sURL.endIndex, offsetBy: -64))) as  String )
        }
        else {
            type = ""
            error = "QRCODE格式有誤"
//            showAlert(title: UIAlert_Default_Title, msg: "QRCODE格式有誤(QRS-001)", confirmTitle: "確認", cancleTitle: nil, completionHandler: startScan, cancelHandelr: {()})
        }
        //檢核QRCode逾期
        if type == "02" {
        if let strtimestamp = qrp?.timestamp(){
            let now = Date()
            let befordate = now.addingTimeInterval(-60*60*24)
            let dateFormatter = DateFormatter()
             dateFormatter.dateFormat = "yyyyMMddHHmmss"
            let newdate = dateFormatter.string(from: befordate)
            
            if (strtimestamp < newdate ){
                type = ""
                error = "QRCode已經逾期"
            }
        }
        }
        
        return (type, tax, qrp, error,power64No)
    }
    static func detectQRCode(_ image : UIImage) -> String {
        let context : CIContext = CIContext()
        let detector : CIDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
        let imageQRCode : CIImage = CIImage(cgImage: image.cgImage!)
        let features : [Any] = detector.features(in: imageQRCode)
        if (features.count > 0) {
            let feature : CIQRCodeFeature = features.first as! CIQRCodeFeature
            return feature.messageString!
        }
        else {
            return ""
        }
    }
}
