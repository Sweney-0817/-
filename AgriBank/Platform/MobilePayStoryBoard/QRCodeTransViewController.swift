//
//  QRCodeTransViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/6/26.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit

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

    var m_arrActList : [[String:String]] = [[String:String]]()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initActView()
        self.initQRCodeArea()
        self.initScanView()
//        self.addObserverToKeyBoard()
        self.addGestureForKeyBoard()
        self.send_getActList()
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
        self.m_uiScanView!.startScan()
    }
    func stopScan() {
        self.m_uiScanView!.stopScan()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startScan()
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
        m_uiActView?.setOneRow("*帳戶", Choose_Title)
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
            for info in m_arrActList {
                if let act = info["Act"] {
                    actSheet.addButton(withTitle: act)
                }
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
    private func makeFakeData() {
        m_arrActList.removeAll()
        var temp : [String:String] = [String:String]()
        for i in 0..<20 {
            temp["Act"] = String.init(format: "%05d", i)
            temp["Amount"] = String.init(format: "%d", i*1000+100)
            m_arrActList.append(temp)
        }
    }
    func send_getActList() {
        self.makeFakeData()
        //        postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
    }
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
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                setLoading(true)
                self.send_getActList()
            }
            else {
                super.didResponse(description, response)
            }
        case "checkQRCode":
            performSegue(withIdentifier: "GoScanResult", sender: nil)
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
        let strAct : String = (m_uiActView?.getContentByType(.First))!
        let strAmount : String = m_tfAmount.text!
        let strQRCode : String = "[\(strAct)][\(strAmount)]"
        self.m_ivQRCode.image = MakeQRCodeUtility.utility.generateQRCode(from: strQRCode)
    }
}
// MARK:- extension
extension QRCodeTransViewController : ScanCodeViewDelegate {
    func clickBtnAlbum() {
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
                let info : [String:String] = m_arrActList[iIndex]
                let act : String = info["Act"]!
                m_uiActView?.setOneRow("*帳戶", act)
            default:
                break
            }
        }
    }
}
extension QRCodeTransViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image : UIImage = info["UIImagePickerControllerOriginalImage"] as! UIImage
        let strQRCode : String = ScanCodeView.detectQRCode(image)
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {() in
            self.analysisQRCode(strQRCode)
        })
    }
}
