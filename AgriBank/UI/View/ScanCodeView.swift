//
//  ScanCodeView.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/7/6.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit
import AVFoundation

class ScanCodeView: UIView {
    @IBOutlet var m_vCameraArea: UIView!
    @IBOutlet var m_vScanArea: UIView!
    @IBAction func m_btnAlbumClick(_ sender: Any) {
    }
    private var m_qrpInfo : MWQRPTransactionInfo? = nil
    private var captureSession: AVCaptureSession? = nil
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer? = nil
    private var output: AVCaptureMetadataOutput? = nil
    private var scanning : Bool = false
    var getQRCodeString : ((_ strQRCode : String) -> ())? = nil

    func set(_ frame : CGRect, _ callBack : @escaping ((_ strQRCode : String) -> ())) {
        self.frame = frame
        self.layoutIfNeeded()
        getQRCodeString = callBack
    }
    
    func startScan() {
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        var input: AVCaptureDeviceInput? = nil
        do {
            input = try AVCaptureDeviceInput.init(device: captureDevice)
        }
        catch {
//            showErrorMessage(error.localizedDescription, "裝置無法啟用掃描功能，請稍後再試。")
            print(error)
            return
        }
        
        captureSession = AVCaptureSession.init()
        captureSession?.addInput(input)
        output = AVCaptureMetadataOutput.init()
        captureSession?.addOutput(output)
        let captureQueue = DispatchQueue.init(label: "captureQueue")
        output?.setMetadataObjectsDelegate(self, queue: captureQueue)
        output?.metadataObjectTypes = output?.availableMetadataObjectTypes
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = m_vCameraArea.frame
        videoPreviewLayer?.frame.origin = CGPoint(x: 0, y: 0)
        
        m_vCameraArea.layer.addSublayer(videoPreviewLayer!)
        captureSession?.startRunning()
        
        drawrect()
        startNotification()
        scanning = true
    }
    func stopScan() {
        scanning = false
        stopNotification()
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
        fillLayer.fillColor = UIColor.black.cgColor
        fillLayer.opacity = 0.8
        m_vCameraArea.layer.addSublayer(fillLayer)
        
        m_vScanArea.layer.borderColor = Green_Color.cgColor
        m_vScanArea.layer.borderWidth = 2
    }
    private func startNotification() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil, queue: OperationQueue.current, using: avCaptureInputPortFormatDescriptionDidChangeNotification)
    }
    private func stopNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil)
    }
    func avCaptureInputPortFormatDescriptionDidChangeNotification(_ notification: Notification?) {
        guard scanning else {
            return
        }
        let rect : CGRect = m_vScanArea.frame
        output?.rectOfInterest = (videoPreviewLayer?.metadataOutputRectOfInterest(for: rect))!
    }
}
extension ScanCodeView : AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ output: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects.count == 0 {
//            showErrorMessage(nil, "no objects returned")
            NSLog("no objects returned")
            return
        }
        
        let metaDataObject = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
        guard let StringCodeValue = metaDataObject?.stringValue else {
//            showErrorMessage(nil, "掃到空的")
            NSLog("掃到空的")
            return
        }
        AudioServicesPlayAlertSound(1016)//震動
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {() in
//            self.hiddenScanView(true)
//            self.setScanCodeData(StringCodeValue)
            NSLog("掃到[%@]", StringCodeValue)
            self.stopScan()
            self.getQRCodeString!(StringCodeValue)
        })
    }
}
