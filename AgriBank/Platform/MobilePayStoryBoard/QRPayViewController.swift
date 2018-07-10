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
    //掃描畫面
    @IBOutlet var m_vScanView: UIView!
    @IBOutlet var m_vCameraArea: UIView!
    @IBOutlet var m_vScanArea: UIView!

    //掃描結果
    @IBOutlet var m_vScanResultView: UIView!
    @IBOutlet var m_vActView: UIView!
    @IBOutlet var m_tvScanResult: UITableView!
    @IBOutlet var m_consScanResultHeight: NSLayoutConstraint!
    @IBOutlet var m_btnConfirm: UIButton!
    
    @IBOutlet var m_vButtonView: UIView!
    var m_uiActView : TwoRowDropDownView? = nil
    var m_strType : String = ""
    var m_strInputAmount : String = ""
    var m_dicDecrypt : [String:String] = [String:String]()
    var m_arrResultData : [[String:String]] = [[String:String]]()
    var m_arrActList : [[String:String]] = [[String:String]]()
    //scan QRCode
    private var m_qrpInfo : MWQRPTransactionInfo? = nil
    private var captureSession: AVCaptureSession? = nil
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer? = nil
    private var output: AVCaptureMetadataOutput? = nil
    //PayTax
    var m_taxInfo : PayTax? = nil
    var m_strPayTaxYear : String? = nil
    var m_strPayTaxMonth : String? = nil

    private var scanning : Bool = false
    // MARK:- Init Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.makeActView()
        self.initTableView()
        self.addObserverToKeyBoard()
        self.addGestureForKeyBoard()
        self.setShadowView(m_vButtonView)
        self.checkBtnConfirm()
        self.getTransactionID("03001", TransactionID_Description)
    }
    private func startNotification() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil, queue: OperationQueue.current, using: avCaptureInputPortFormatDescriptionDidChangeNotification)
    }
    private func stopNotification() {
//        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil)
    }
    private func initTableView() {
        m_tvScanResult.register(UINib(nibName: UIID.UIID_ResultCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultCell.NibName()!)
        m_tvScanResult.register(UINib(nibName: UIID.UIID_ResultEditCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultEditCell.NibName()!)
        m_tvScanResult.isScrollEnabled = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startScan()
    }
    override func viewDidDisappear(_ animated: Bool) {
        stopScan()
        super.viewDidDisappear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- UI Methods
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
    private func makeActView() {
        m_uiActView = getUIByID(.UIID_TwoRowDropDownView) as? TwoRowDropDownView
        m_uiActView?.setTwoRow(NTTransfer_OutAccount, Choose_Title, NTTransfer_Balance, "")
        m_uiActView?.frame = m_vActView.frame
        m_uiActView?.frame.origin = .zero
        m_uiActView?.delegate = self
        m_vActView.addSubview(m_uiActView!)
        setShadowView(m_vActView)
    }
    func hiddenScanView(_ hidden : Bool) {
        if (hidden) {
            stopScan()
        }
        else {
            startScan()
        }
        m_vScanView.isHidden = hidden
        m_vScanResultView.isHidden = !hidden
    }
    func startScan() {
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        var input: AVCaptureDeviceInput? = nil
        do {
            input = try AVCaptureDeviceInput.init(device: captureDevice)
        }
        catch {
            showErrorMessage(error.localizedDescription, "裝置無法啟用掃描功能，請稍後再試。")
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
        videoPreviewLayer?.frame = m_vCameraArea.layer.bounds
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
    func avCaptureInputPortFormatDescriptionDidChangeNotification(_ notification: Notification?) {
        guard scanning else {
            return
        }
        let rect : CGRect = m_vScanArea.frame
        output?.rectOfInterest = (videoPreviewLayer?.metadataOutputRectOfInterest(for: rect))!
    }
    private func checkType(_ tag : String) -> String {
        var strType : String = "N"
        if (m_qrpInfo?.dTypeDic()[tag] != nil) {
            strType = "D"
        }
        else if (m_qrpInfo?.mTypeDic()[tag] != nil) {
            strType = "M"
        }
        return strType
    }
    private func makeShowData() {
        m_arrResultData.removeAll()
        switch m_strType {
        case "01":
            makePurchaseData()
        case "02":
            makeP2PTransferData()
        case "03":
            makeBillData()
        case "51":
            makePurchaseData()
        case PayTax_Type11_Type:
            makePayTaxType11Data()
        case PayTax_Type15_Type:
            makePayTaxType15Data()
        default:
            break
        }
        m_consScanResultHeight.constant = CGFloat(60 * m_arrResultData.count)
        m_tvScanResult.reloadData()
    }
    private func makePurchaseData() {
        var temp : [String:String] = [String:String]()

        temp[Response_Key] = "類別"
        temp[Response_Value] = "消費購物"
        m_arrResultData.append(temp)

        if ((m_qrpInfo?.merchantName()) != nil) {
            temp[Response_Key] = "商店名稱"
            temp[Response_Value] = m_qrpInfo?.merchantName()
            temp[Response_Type] = "N"
            m_arrResultData.append(temp)
        }
        if ((m_qrpInfo?.merchantId()) != nil) {
            temp[Response_Key] = "特店代號"
            temp[Response_Value] = m_qrpInfo?.merchantId()
            temp[Response_Type] = "N"
            m_arrResultData.append(temp)
        }
//        if ((m_qrpInfo?.txnAmt()) != nil) {
            temp[Response_Key] = "金額"
            temp[Response_Value] = m_qrpInfo?.txnAmt() ?? ""
            m_strInputAmount = m_qrpInfo?.txnAmt() ?? ""
            temp[Response_Type] = self.checkType("1")
            m_arrResultData.append(temp)
//        }
        // 購物轉帳(51) - 轉入帳號
        if (m_strType == "51") {
            if ((m_qrpInfo?.transfereeAccountForPurchasing()) != nil) {
                temp[Response_Key] = "轉入帳號"
                temp[Response_Value] = m_qrpInfo?.transfereeAccountForPurchasing()
                temp[Response_Type] = self.checkType("11")
                m_arrResultData.append(temp)
            }
        }
        if ((m_qrpInfo?.orderNumber()) != nil) {
            temp[Response_Key] = "訂單編號"
            temp[Response_Value] = m_qrpInfo?.orderNumber()
            temp[Response_Type] = self.checkType("2")
            m_arrResultData.append(temp)
        }
        else if (m_dicDecrypt["E2"] != nil) {
            temp[Response_Key] = "訂單編號"
            temp[Response_Value] = m_dicDecrypt["E2"]
            temp[Response_Type] = "E"
            m_arrResultData.append(temp)
        }
    }
    private func makeP2PTransferData() {
        var temp : [String:String] = [String:String]()

        temp[Response_Key] = "類別"
        temp[Response_Value] = "轉帳"
        m_arrResultData.append(temp)

        if ((m_qrpInfo?.merchantName()) != nil) {
            temp[Response_Key] = "名稱"
            temp[Response_Value] = m_qrpInfo?.merchantName()
            temp[Response_Type] = "N"
            m_arrResultData.append(temp)
        }
        if ((m_qrpInfo?.transfereeBank()) != nil) {
            temp[Response_Key] = "轉入行代碼"
            temp[Response_Value] = m_qrpInfo?.transfereeBank()
            temp[Response_Type] = self.checkType("5")
            m_arrResultData.append(temp)
        }
        if ((m_qrpInfo?.transfereeAccount()) != nil) {
            temp[Response_Key] = "轉入帳號"
            temp[Response_Value] = m_qrpInfo?.transfereeAccount()
            temp[Response_Type] = self.checkType("6")
            m_arrResultData.append(temp)
        }
//        if ((m_qrpInfo?.txnAmt()) != nil) {
            temp[Response_Key] = "金額"
            temp[Response_Value] = m_qrpInfo?.txnAmt() ?? ""
            m_strInputAmount = m_qrpInfo?.txnAmt() ?? ""
            temp[Response_Type] = self.checkType("1")
            m_arrResultData.append(temp)
//        }
        if ((m_qrpInfo?.note()) != nil) {
            temp[Response_Key] = "備註"
            temp[Response_Value] = m_qrpInfo?.note()
            temp[Response_Type] = self.checkType("9")
            m_arrResultData.append(temp)
        }
    }
    private func makeBillData() {
        var temp : [String:String] = [String:String]()

        temp[Response_Key] = "類別"
        temp[Response_Value] = "繳費"
        m_arrResultData.append(temp)

        if ((m_qrpInfo?.feeName()) != nil) {
            temp[Response_Key] = "費用名稱"
            temp[Response_Value] = m_qrpInfo?.feeName()
            temp[Response_Type] = self.checkType("16")
            m_arrResultData.append(temp)
        }
        else if ((m_qrpInfo?.feeInfo()) != nil) {
            let arrInfo : [String]? = (m_qrpInfo?.feeInfo().components(separatedBy: ","))
            var fName : String = ""
            if (arrInfo != nil && arrInfo!.count > 1 ) {
                if (arrInfo![0] == "0") {
                    fName = "全國繳費網"
                }
                else if (arrInfo![0] == "1") {
                    fName = "汽燃費"
                }
                else if (arrInfo![0] == "2") {
                    fName = "台灣自來水費"
                }
                else if (arrInfo![0] == "3") {
                    fName = "電費"
                }
                else {
                    fName = "瓦斯費"
                }
            }
            temp[Response_Key] = "費用名稱"
            temp[Response_Value] = fName
            temp[Response_Type] = self.checkType("14")
            m_arrResultData.append(temp)
        }
        else if ((m_qrpInfo?.merchantName()) != nil) {
            temp[Response_Key] = "費用名稱"
            temp[Response_Value] = m_qrpInfo?.merchantName()
            temp[Response_Type] = "N"
            m_arrResultData.append(temp)
        }
//        if ((m_qrpInfo?.txnAmt()) != nil) {
            temp[Response_Key] = "金額"
            temp[Response_Value] = m_qrpInfo?.txnAmt() ?? ""
            m_strInputAmount = m_qrpInfo?.txnAmt() ?? ""
            temp[Response_Type] = self.checkType("1")
            m_arrResultData.append(temp)
//        }
        if ((m_qrpInfo?.noticeNbr()) != nil) {
            temp[Response_Key] = "銷帳編號"
            temp[Response_Value] = m_qrpInfo?.noticeNbr()
            temp[Response_Type] = self.checkType("7")
            m_arrResultData.append(temp)
        }
        else if (m_dicDecrypt["E7"] != nil) {
            temp[Response_Key] = "銷帳編號"
            temp[Response_Value] = m_dicDecrypt["E2"]
            temp[Response_Type] = "E"
            m_arrResultData.append(temp)
        }
        if ((m_qrpInfo?.charge()) != nil) {
            if ((m_qrpInfo?.acqBank() == "007" && m_qrpInfo?.feeInfo() != nil) ||
                (m_qrpInfo?.acqBank() != "007")) {
                temp[Response_Key] = "使用者支付手續費"
                temp[Response_Value] = m_qrpInfo?.charge()
                temp[Response_Type] = self.checkType("15")
                m_arrResultData.append(temp)
            }
        }
        if ((m_qrpInfo?.deadlinefinal()) != nil) {
            temp[Response_Key] = "繳納期限"
            temp[Response_Value] = m_qrpInfo?.deadlinefinal()
            temp[Response_Type] = self.checkType("4")
            m_arrResultData.append(temp)
        }
    }
    private func makePayTaxType11Data() {
        var temp : [String:String] = [String:String]()

        temp[Response_Key] = "類別"
        temp[Response_Value] = "繳稅11"
        m_arrResultData.append(temp)

        if ((m_taxInfo?.taxType) != nil) {
            temp[Response_Key] = PayTax_Type11_ShowTitle[0]
            temp[Response_Value] = m_taxInfo?.taxType
            temp[Response_Type] = "N"
            m_arrResultData.append(temp)
        }
        if ((m_taxInfo?.number) != nil) {
            temp[Response_Key] = PayTax_Type11_ShowTitle[1]
            temp[Response_Value] = m_taxInfo?.number
            temp[Response_Type] = "N"
            m_arrResultData.append(temp)
        }
        if ((m_taxInfo?.amount) != nil) {
            temp[Response_Key] = PayTax_Type11_ShowTitle[2]
            temp[Response_Value] = m_taxInfo?.amount
            temp[Response_Type] = "N"
            m_arrResultData.append(temp)
        }
        if ((m_taxInfo?.deadLine) != nil) {
            temp[Response_Key] = PayTax_Type11_ShowTitle[3]
            temp[Response_Value] = m_taxInfo?.deadLine
            temp[Response_Type] = "N"
            m_arrResultData.append(temp)
        }
        if ((m_taxInfo?.periodCode) != nil) {
            temp[Response_Key] = PayTax_Type11_ShowTitle[4]
            temp[Response_Value] = m_taxInfo?.periodCode
            temp[Response_Type] = "N"
            m_arrResultData.append(temp)
        }
    }
    private func makePayTaxType15Data() {
        var temp : [String:String] = [String:String]()

        temp[Response_Key] = "類別"
        temp[Response_Value] = "繳稅15"
        m_arrResultData.append(temp)
        
        if ((m_taxInfo?.taxType) != nil) {
            temp[Response_Key] = PayTax_Type15_ShowTitle[0]
            temp[Response_Value] = m_taxInfo?.taxType
            temp[Response_Type] = "N"
            m_arrResultData.append(temp)
        }
        if ((m_strPayTaxYear) != nil) {
            temp[Response_Key] = PayTax_Type15_ShowTitle[1]
            temp[Response_Value] = m_strPayTaxYear
            temp[Response_Type] = "N"
            m_arrResultData.append(temp)
        }
    }
    func detectQRCode(_ image : UIImage) -> String {
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
    func getFirstTWQRP(_ strData : String) -> String {
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
    func getPayTaxData(_ nsURL : String) -> String? {
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
    func getTypeName(_ type : String, setDate date : String?) -> String {
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
    func setPayTaxData(_ nsData : String) -> Bool {
        var bIsCorrect : Bool = false
        // QRCode規格如下:
        // 1.查(核)定類稅款：https://paytax.nat.gov.tw/QRCODE.aspx?par= + (5位繳款類別) + (16位銷帳編號)+ (10位繳款金額) + (6繳納截止日)+ (5位期別代號)+ (6位識別碼)，共48字元。
        // 2.綜所稅：https://paytax.nat.gov.tw/QRCODE.aspx?par= + (5位繳款類別，固定值:15001) 共5字元
        
        // 先檢核長度是否正確
        if (nsData.count == PayTax_Type11_Length) {
            bIsCorrect = true
            m_strType = PayTax_Type11_Type
            m_taxInfo = PayTax()
            m_taxInfo?.taxType = nsData.substring(from: 0, length: 5)
            m_taxInfo?.number = nsData.substring(from: 5, length: 16)
            m_taxInfo?.amount = nsData.substring(from: 21, length: 10)
            m_taxInfo?.deadLine = nsData.substring(from: 31, length: 6)
            m_taxInfo?.periodCode = nsData.substring(from: 37, length: 5)

        }
        else if (nsData.count == PayTax_Type15_Length) {
            bIsCorrect = true
            m_strType = PayTax_Type15_Type
            m_taxInfo?.taxType = nsData.substring(from: 0, length: 5)
            m_taxInfo?.number = nil
            m_taxInfo?.amount = nil
            m_taxInfo?.deadLine = nil
            m_taxInfo?.periodCode = nil
        }
        if (self.getTypeName((m_taxInfo?.taxType)!, setDate:m_taxInfo?.deadLine).isEmpty == true) {
            bIsCorrect = false
            m_taxInfo?.taxType = nil
            m_taxInfo?.number = nil
            m_taxInfo?.amount = nil
            m_taxInfo?.deadLine = nil
            m_taxInfo?.periodCode = nil
        }
        else {
            self.send_checkPayTaxCode()
        }
        return bIsCorrect
    }
    func isPayTaxFormat(_ nsURL : String) -> Bool {
        let nsData : String? = getPayTaxData(nsURL)
        guard nsData != nil else {
            return false
        }
        return setPayTaxData(nsData!)
    }
    func setScanCodeData(_ strData : String) {
        let strInput : String = getFirstTWQRP(strData)
        m_qrpInfo = MWQRPTransactionInfo(qrCodeURL: strInput)
        if (m_qrpInfo?.isValidQRCodeFromat())! {
            if m_qrpInfo?.txnCurrencyCode() != nil && m_qrpInfo?.txnCurrencyCode() != "901" {
                m_strType = ""
                self.makeShowData()
                showErrorMessage(nil, String(format: "尚不支援此交易幣別(%@)", (m_qrpInfo?.txnCurrencyCode())!))
            }
            else {
                switch (m_qrpInfo?.transactionType)! {
                case .purchase:
//                    m_strType = "01"
//                    self.send_checkQRCode()
                    m_strType = ""
                    self.makeShowData()
                    showErrorMessage(nil, "尚未提供消費扣款服務(QRS-002)")
                case .p2PTransfer:
//                    m_strType = "02"
//                    self.makeShowData()
                    m_strType = ""
                    self.makeShowData()
                    showErrorMessage(nil, "尚未提供P2P轉帳服務(QRS-005)")
                case .bill:
//                    m_strType = "03"
//                    self.send_checkQRCode()
                    m_strType = ""
                    self.makeShowData()
                    showErrorMessage(nil, "尚未提供繳費服務(QRS-003)")
                case .transferPurchase:
                    m_strType = "51"
                    self.send_checkQRCode()
                default:
                    m_strType = ""
                    self.makeShowData()
                    showErrorMessage(nil, "尚未提供此服務(QRS-006)")
                }
            }
            
        }
        else if (self.isPayTaxFormat(strData)) {
            m_strType = ""
            self.makeShowData()
            showErrorMessage(nil, "尚未提供繳稅服務(QRS-004)")
        }
        else {
            m_strType = ""
            self.makeShowData()
            showErrorMessage(nil, "QRCODE格式有誤(QRS-001)")
        }
    }
    func checkBtnConfirm() {
        if ((m_uiActView?.getContentByType(.First) != Choose_Title) &&
            (m_strInputAmount.isEmpty == false)) {
            m_btnConfirm.isEnabled = true
        }
        else {
            m_btnConfirm.isEnabled = false
        }
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
        self.makeShowData()
    }
    private func send_checkPayTaxCode() {
        m_strPayTaxYear = "公元5000年"
        m_strPayTaxMonth = "滿月"
        self.makeShowData()
    }
    private func send_confirm() {
        setLoading(true)
//        var inAccount = ""
//        var inBank = ""
//        if isCustomizeAct {
//            inAccount = enterAccountTextfield.text ?? ""
//            inBank = showBankDorpView?.getContentByType(.First) ?? ""
//        }
//        else {
//            inAccount = showBankAccountDropView?.getContentByType(.Second) ?? ""
//            inBank = showBankAccountDropView?.getContentByType(.First) ?? ""
//        }
//        postRequest("TRAN/TRAN0103", "TRAN0103", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03001","Operate":"dataConfirm","TransactionId":transactionId,"CARDACTNO":topDropView?.getContentByType(.First) ?? "","INACT":inAccount,"INBANK":inBank,"TXAMT":transAmountTextfield.text!,"TXMEMO":memoTextfield.text!,"MAIL":emailTextfield.text!], true), AuthorizationManage.manage.getHttpHead(true))
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
//        case "ACCT0101":
//            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]]{
//                for category in array {
//                    if let type = category["ACTTYPE"] as? String, let result = category["AccountInfo"] as? [[String:Any]], type == Account_Saving_Type {
//                        accountList = [AccountStruct]()
//                        for actInfo in result {
//                            if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? String, let ebkfg = actInfo["EBKFG"] as? String, ebkfg == Account_EnableTrans {
//                                accountList?.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
//                            }
//                        }
//                    }
//                }
//
//                if inputAccount != nil {
//                    for index in 0..<(accountList?.count)! {
//                        if let info = accountList?[index], info.accountNO == inputAccount! {
//                            accountIndex = index
//                            topDropView?.setThreeRow(NTTransfer_OutAccount, info.accountNO, NTTransfer_Currency, (info.currency == Currency_TWD ? Currency_TWD_Title:info.currency), NTTransfer_Balance, String(info.balance).separatorThousand())
//                            break
//                        }
//                    }
//                    inputAccount = nil
//                }
//            }
//            else {
//                super.didResponse(description, response)
//            }
//
//        case "COMM0401":
//            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:String]] {
//                bankNameList = array
//                showBankList()
//            }
//            else {
//                super.didResponse(description, response)
//            }
//            
//        case "ACCT0102":
//            if let data = response.object(forKey: ReturnData_Key) as? [String:Any] {
//                if let array = data["Result"] as? [[String:Any]] {
//                    agreedAccountList = array
//                }
//                showInAccountList(isPredesignated)
//            }
//            else {
//                super.didResponse(description, response)
//            }
//            
//        case "ACCT0104":
//            if let data = response.object(forKey: ReturnData_Key) as? [String:Any] {
//                if let array = data["Result2"] as? [[String:Any]] {
//                    commonAccountList = array
//                }
//                showInAccountList(isPredesignated)
//            }
//            else {
//                super.didResponse(description, response)
//            }
//            
//        case "COMM0802":
//            showNonPredesignated()
//            
//        case "TRAN0103":
//            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let Id = data["taskId"] as? String {
//                VaktenManager.sharedInstance().getTasksOperation{ resultCode, tasks  in
//                    if VIsSuccessful(resultCode) && tasks != nil {
//                        self.transNonPredesignated(tasks! as! [VTask], Id)
//                    }
//                    else {
//                        self.showErrorMessage(nil, "\(ErrorMsg_GetTasks_Faild) \(resultCode.rawValue)")
//                    }
//                }
//            }
//            else {
//                showErrorMessage(nil, ErrorMsg_No_TaskId)
//            }
            
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
    @IBAction func m_btnCancelClick(_ sender: Any) {
        dismissKeyboard()
        m_strInputAmount = ""
        hiddenScanView(false)
    }
    @IBAction func m_btnConfirmClick(_ sender: Any) {
        dismissKeyboard()
        NSLog("Input[%@]", m_strInputAmount)
    }
}
// MARK:- extension
extension QRPayViewController : AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ output: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects.count == 0 {
            showErrorMessage(nil, "no objects returned")
            return
        }
        
        let metaDataObject = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
        guard let StringCodeValue = metaDataObject?.stringValue else {
            showErrorMessage(nil, "掃到空的")
            return
        }
        AudioServicesPlayAlertSound(1016)//震動
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {() in
            self.hiddenScanView(true)
            self.setScanCodeData(StringCodeValue)
        })
    }
}
extension QRPayViewController : TwoRowDropDownViewDelegate {
    func clickTwoRowDropDownView(_ sender: TwoRowDropDownView) {
        if (m_arrActList.count == 0) {
            self.send_getActList()
        }
        else {
            self.showActList()
        }
    }
}
extension QRPayViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_arrResultData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (((m_arrResultData[indexPath.row][Response_Key])!.range(of: "金額") != nil) &&
            (m_arrResultData[indexPath.row][Response_Value]?.isEmpty == true)) {
            let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultEditCell.NibName()!, for: indexPath) as! ResultEditCell
            cell.set(m_arrResultData[indexPath.row][Response_Key]!, m_strInputAmount)
            cell.m_tfEditData.delegate = self
            cell.selectionStyle = .none
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell
            cell.set((m_arrResultData[indexPath.row][Response_Key])!, (m_arrResultData[indexPath.row][Response_Value])!)
            cell.selectionStyle = .none
            return cell
        }

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ResultCell.GetStringHeightByWidthAndFontSize((m_arrResultData[indexPath.row][Response_Value])!, tableView.frame.size.width)
    }

}
extension QRPayViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image : UIImage = info["UIImagePickerControllerOriginalImage"] as! UIImage
        let strQRCode : String = detectQRCode(image)
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {() in
            self.hiddenScanView(true)
            self.setScanCodeData(strQRCode)
        })
    }
}
extension QRPayViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        guard DetermineUtility.utility.isAllNumber(newString) else {
            return false
        }
        
        let newLength = (textField.text?.count)! - range.length + string.count
        let maxLength = Max_MobliePhone_Length
        if newLength <= maxLength {
            m_strInputAmount = newString
            self.checkBtnConfirm()
            return true
        }
        else {
            return false
        }
    }
}
extension QRPayViewController : UIActionSheetDelegate {
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet.cancelButtonIndex != buttonIndex {
            switch (actionSheet.tag) {
            case ViewTag.View_AccountActionSheet.rawValue:
                let iIndex : Int = buttonIndex - 1
                let info : [String:String] = m_arrActList[iIndex]
                let act : String = info["Act"]!
                let amount : String = info["Amount"]!
                m_uiActView?.setTwoRow(NTTransfer_OutAccount, act, NTTransfer_Balance, amount)
                self.checkBtnConfirm()
            default:
                break
            }
        }
    }
}
