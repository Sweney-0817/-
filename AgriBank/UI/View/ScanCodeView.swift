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
    var scanning : Bool = false
    var m_delegate : ScanCodeViewDelegate!

    func set(_ frame : CGRect, _ delegate : ScanCodeViewDelegate) {
        self.frame = frame
        self.layoutIfNeeded()
        self.m_delegate = delegate
    }
    
    func startScan() {
        guard scanning == false else {
            return
        }
        NSLog("======== ScanCodeView startScan ========")
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        var input: AVCaptureDeviceInput? = nil
        do {
            input = try AVCaptureDeviceInput.init(device: captureDevice)
        }
        catch {
            self.m_delegate.noPermission()
            return
        }
        
        captureSession = AVCaptureSession.init()
        captureSession?.addInput(input)
        output = AVCaptureMetadataOutput.init()
        captureSession?.addOutput(output)
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
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
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
        fillLayer.fillRule = kCAFillRuleEvenOdd
        fillLayer.fillColor = UIColor.init(red: 73.0/255.0, green: 73.0/255.0, blue: 73.0/255.0, alpha: 0.58).cgColor
        fillLayer.opacity = 0.8
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
    func captureOutput(_ output: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
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
            NSLog("掃到[%@]", StringCodeValue)
            self.stopScan()
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
                let strNeed : String = strInput.substring(from: (ranTWQRP.lowerBound))
                return strNeed
            }
            else {
                for strSubString : String in arrInput {
                    if ((strSubString.range(of: "TWQRP", options: String.CompareOptions.caseInsensitive)) != nil) {
                        let strNeed = strSubString.replacingOccurrences(of: "\r", with: "")
                        return strNeed
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
        let url : NSURL = NSURL(string: nsURL)!
        if (url.scheme == PayTax_URL_scheme && url.host == PayTax_URL_host) {
            let urlComponents : [String] = url.query!.components(separatedBy:"&")
            for keyValuePair : String in urlComponents {
                let pairComponents : [String] = keyValuePair.components(separatedBy:"=")
                let key : String = pairComponents.first!.removingPercentEncoding!
                if (key == "par") {
                    return pairComponents.last!.removingPercentEncoding!
                }
            }
        }
        return nil
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
    static func analysisQRCode(_ strData : String) -> (type : String, tax : PayTax?, qrp : MWQRPTransactionInfo?, error : String?) {
        var type : String = ""
        var tax : PayTax? = nil
        var qrp : MWQRPTransactionInfo? = nil
        var error : String? = nil
        
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
//                    type = "01"
//                    self.send_checkQRCode()
                    type = ""
                    error = "尚未提供消費扣款服務(QRS-002)"
//                    showAlert(title: nil, msg: "尚未提供消費扣款服務(QRS-002)", confirmTitle: "確認", cancleTitle: nil, completionHandler: startScan, cancelHandelr: {()})
                case .p2PTransfer:
//                    type = "02"
//                    self.send_checkQRCode()
                    type = ""
                    error = "尚未提供P2P轉帳服務(QRS-005)"
//                    showAlert(title: nil, msg: "尚未提供P2P轉帳服務(QRS-005)", confirmTitle: "確認", cancleTitle: nil, completionHandler: startScan, cancelHandelr: {()})
                case .bill:
//                    type = "03"
//                    self.send_checkQRCode()
                    type = ""
                    error = "尚未提供繳費服務(QRS-003)"
//                    showAlert(title: nil, msg: "尚未提供繳費服務(QRS-003)", confirmTitle: "確認", cancleTitle: nil, completionHandler: startScan, cancelHandelr: {()})
                case .transferPurchase:
                    type = "51"
//                    self.send_checkQRCode()
                default:
                    type = ""
                    error = "尚未提供此服務(QRS-006)"
//                    showAlert(title: nil, msg: "尚未提供此服務(QRS-006)", confirmTitle: "確認", cancleTitle: nil, completionHandler: startScan, cancelHandelr: {()})
                }
            }
        }
        else if let a = self.isPayTaxFormat(strData) {
            type = a.type
            tax = a.tax
            //            self.send_checkPayTaxCode()
            type = ""
            error = "尚未提供繳稅服務(QRS-004)"
//            showAlert(title: nil, msg: "尚未提供繳稅服務(QRS-004)", confirmTitle: "確認", cancleTitle: nil, completionHandler: startScan, cancelHandelr: {()})
        }
        else {
            type = ""
            error = "QRCODE格式有誤(QRS-001)"
//            showAlert(title: nil, msg: "QRCODE格式有誤(QRS-001)", confirmTitle: "確認", cancleTitle: nil, completionHandler: startScan, cancelHandelr: {()})
        }
        
        return (type, tax, qrp, error)
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
