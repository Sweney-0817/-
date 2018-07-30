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

class QRPayViewController: BaseViewController {
    @IBOutlet var m_vScanView: UIView!
    var m_uiScanView : ScanCodeView? = nil
    var m_strType : String = ""
    private var m_qrpInfo : MWQRPTransactionInfo? = nil
    var m_taxInfo : PayTax? = nil
    var m_bIsLoadFromAlbum : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initScanView()
    }
    override func viewDidAppear(_ animated: Bool) {
        NSLog("======== QRPayViewController viewDidAppear ========")
        super.viewDidAppear(animated)
        if (m_bIsLoadFromAlbum == false) {
            startScan()
        }
        m_bIsLoadFromAlbum = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK:- Init Methods
    private func initScanView() {
        m_uiScanView = Bundle.main.loadNibNamed("ScanCodeView", owner: self, options: nil)?.first as? ScanCodeView
        m_uiScanView!.set(CGRect(origin: .zero, size: m_vScanView.bounds.size), self)
        m_vScanView.addSubview(m_uiScanView!)
    }
    
    // MARK:- UI Methods
    func startScan() {
        self.m_uiScanView!.startScan()
        m_bIsLoadFromAlbum = false
    }
    func stopScan() {
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
        controller.setData(type: m_strType, qrp: m_qrpInfo, tax: m_taxInfo)
    }

    // MARK:- WebService Methods
    private func send_checkQRCode() {
        self.didResponse("checkQRCode", [String:String]() as NSDictionary)
    }
    private func send_checkPayTaxCode() {
        m_taxInfo?.m_strPayTaxYear = "公元5000年"
        m_taxInfo?.m_strPayTaxMonth = "滿月"
        self.didResponse("checkPayTaxCode", [String:String]() as NSDictionary)
    }
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case "checkQRCode":
            performSegue(withIdentifier: "GoScanResult", sender: nil)
        case "checkPayTaxCode":
            performSegue(withIdentifier: "GoScanResult", sender: nil)
        default: super.didResponse(description, response)
        }
    }
    
    // MARK:- Handle Actions
    @IBAction func m_btnAlbumClick(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            stopScan()
            let controller : UIImagePickerController = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(controller, animated: true, completion: nil)
            
        }
    }
}
// MARK:- extension
extension QRPayViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image : UIImage = info["UIImagePickerControllerOriginalImage"] as! UIImage
        let strQRCode : String = ScanCodeView.detectQRCode(image)
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {() in
            self.analysisQRCode(strQRCode)
        })
    }
}
extension QRPayViewController : ScanCodeViewDelegate {
    func clickBtnAlbum() {
        m_bIsLoadFromAlbum = true
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            stopScan()
            let controller : UIImagePickerController = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(controller, animated: true, completion: nil)
        }
    }
    func getQRCodeString(_ strQRCode : String) {
        self.analysisQRCode(strQRCode)
    }
    func noPermission() {
        let confirmHandler : ()->Void = {() in
            if (UIApplication.shared.canOpenURL(URL(string:"App-Prefs:root=com.agribank.mbank-sit")!)) {
                UIApplication.shared.openURL(URL(string: "App-Prefs:root=com.agribank.mbank-sit")!)
            }
        }
        let cancelHandler : ()->Void = {()}
        showAlert(title: "尚未授權相機功能", msg: "請先至設定啟用相機權限", confirmTitle: "設定", cancleTitle: "取消", completionHandler: confirmHandler, cancelHandelr: cancelHandler)
    }
}
