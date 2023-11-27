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

var QRCodeInfo: [String: String] = [:]

class QRPayViewController0:BaseViewController {

    
    @IBOutlet var m_vReceiptView: UIView!
    @IBOutlet var m_vTopView: UIView!
    @IBOutlet var m_vActView: UIView!
    @IBOutlet var m_vQRCodeArea: UIView!
    @IBOutlet var vBarCodeArea: UIView!
    @IBOutlet var m_ivQRCode: UIImageView!
    @IBOutlet var m_ivBarCode: UIImageView!
    @IBOutlet weak var m_QuintupleImg: UIImageView!
    
    @IBOutlet weak var LabelTimer: UILabel!
    @IBOutlet var m_vPaymentView: UIView!//scanView
    
    @IBOutlet weak var einvoiceImg: UIImageView!
    @IBOutlet weak var einvoiceText: UILabel!
    
   // @IBOutlet weak var TwPayImg: UIImageView!
    @IBOutlet weak var LabelBarCode: UILabel!
    var m_uiActView : OneRowDropDownView? = nil
    //var m_uiScanView : ScanCodeView? = nil
    
    private var m_strType : String = ""
    private var m_qrpInfo : MWQRPTransactionInfo? = nil
    private var m_taxInfo : PayTax? = nil
    private var currentIndex = 0                 // chiu push test pushResultList Index
    var m_dicSecureData : [String:String]? = nil
    var m_bIsLoadFromAlbum : Bool = false
    
    var m_arrActList : [AccountStruct] = [AccountStruct]()
    
    //倒數計時180秒
    var counter = 180
    var MaxTime = 180
    var timer = Timer()
    var isPlaying = false
    var countertime = Date()//改用時間算才不會被暫停
    
    var brightness: CGFloat? // 明亮度
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initActView()
        self.initQRCodeArea()
        self.addGestureForKeyBoard()
        getTransactionID("09004", TransactionID_Description)
        //        self.send_getActList()
        
        LabelTimer.text = ""
        
        ///添加截圖通知
        NotificationCenter.default.addObserver(self, selector: #selector(self.userDidTakeScreenshot), name: NSNotification.Name.UIApplicationUserDidTakeScreenshot, object: nil)
        
       // m_QuintupleImg.isHidden = QuintupleFlag
        
    }
    deinit {
        ///移除通知
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationUserDidTakeScreenshot, object: nil)
        timer.invalidate()
        isPlaying = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         navigationController?.navigationBar.topItem?.title = "出示付款碼"
    }
    //截屏通知
    @objc func userDidTakeScreenshot() {
        var StrMsg =  "親愛的客戶您好：\n為維護您的個人資料及交易安全，使用截圖功能時，請謹慎並妥善保管，以免遭到不當使用。"
           showAlert(title: UIAlert_Default_Title, msg: StrMsg, confirmTitle: "確認", cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
      
        
    }
 
    func initQRCodeArea() {
        m_vQRCodeArea.layer.borderColor = UIColor.init(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: 1.0).cgColor
        m_vQRCodeArea.layer.borderWidth = 0//2.0
        
        m_ivBarCode.layer.borderColor = UIColor.init(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: 1.0).cgColor
        m_ivBarCode.layer.borderWidth = 0//2.0
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
            m_vReceiptView.isHidden = false
            m_vPaymentView.isHidden = true
           GetInfor()
        }
        else {
            self.m_ivBarCode.image = nil
            self.m_ivQRCode.image = nil
            self.LabelBarCode.text = ""
           // TwPayImg.isHidden = true
            counter = 180
            LabelTimer.text = ""
            timer.invalidate()
            isPlaying = false
         
            m_vReceiptView.isHidden = true
            m_vPaymentView.isHidden = false
       
            
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
    func send_getActList() {
        //        self.makeFakeData()
        postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        super.prepare(for: segue, sender: sender)
        //chiu push test start
//        let alert = UIAlertView(title: UIAlert_Default_Title , message: "prepare_Start", delegate: self, cancelButtonTitle: Determine_Title)
//        alert.show()
        if (segue.identifier != nil) {
        switch segue.identifier! {
            case "PayToPush":
                let controller = segue.destination as! PushDetailResultViewController
                var list = [[String:String]]()
                if pushReceiveFlag == "PAY" {
                    
                        if let SERNO =  pushResultList![AnyHashable("交易序號")] as? String{
                            list.append([Response_Key: "交易序號", Response_Value:SERNO ])
                        }
                        else {
                            list.append([Response_Key: "交易序號", Response_Value:""])
                        }
                  
                        if let TXDAY = pushResultList![AnyHashable("交易日期")] as? String {
                            list.append([Response_Key: "交易日期", Response_Value:TXDAY])
                        }
                        else {
                            list.append([Response_Key: "交易日期", Response_Value:""])
                        }
                   
                        if let TXTIME = pushResultList![AnyHashable("交易時間")] as? String {
                            list.append([Response_Key: "交易時間", Response_Value:TXTIME])
                        }
                        else {
                            list.append([Response_Key: "交易時間", Response_Value:""])
                        }
                    
                    //20101112- add by sweney 新增訂單編號
                    if let TXTIME = pushResultList![AnyHashable("訂單編號")] as? String {
                        list.append([Response_Key: "訂單編號", Response_Value:TXTIME])
                    }
                    else {
                        //沒有就不秀
                        //list.append([Response_Key: "訂單編號", Response_Value:""])
                    }
                    
                        if let MACTNO = pushResultList![AnyHashable("轉出帳號")] as? String {
                            list.append([Response_Key: "轉出帳號", Response_Value:MACTNO])
                        }
                        else {
                            list.append([Response_Key: "轉出帳號", Response_Value:""])
                        }
                    
                        if let TXAMT = pushResultList![AnyHashable("金額")] as? String {
                            list.append([Response_Key: "金額", Response_Value:TXAMT.separatorThousand()])
                        }
                        else {
                            list.append([Response_Key: "金額", Response_Value:""])
                        }
                    
                    controller.setList(QRBarTitle, list)
                    
                }
//                else
//                {
//                    //controller.setErrorMessage("交易失敗")
//                    //controller.setList("交易失敗", list)
//            }
     
        default:
        //chiu push test end
        let controller = segue.destination as! ScanResultViewController
        controller.setData(type: m_strType, qrp: m_qrpInfo, tax: m_taxInfo, transactionId: transactionId, secure: m_dicSecureData)
            }
 
        }

    }

    private func checkQRCodeData() -> Bool {
        let act: String? = m_uiActView?.getContentByType(.First)
        if (act == nil || act?.isEmpty == true || act == Choose_Title) {
            showAlert(title: UIAlert_Default_Title, msg: "請選擇帳戶", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
            return false
        }
        
        return true
    }
    // MARK:- WebService Methods
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case TransactionID_Description:
            //9004
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                setLoading(true)
                     self.send_getActList()
            }
            else {
                super.didResponse(description, response)
            }
        case "QR0801":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]]{
                for item in array {
                    let Key: String = item["Key"] as! String
                    if let Value = item["Value"] as? String {
                        QRCodeInfo[Key] = Value
                    }else
                    {
                         QRCodeInfo[Key] = ""
                    }
                    
                    
                }
                GetInfor()
            }else {
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
                
                
                //2019-9-2 add by sweney -取index=0轉出帳號
                if(m_arrActList.count) > 0 {
                    let info : AccountStruct = m_arrActList[0]
                    m_uiActView?.setOneRow("轉出帳號", info.accountNO)
                      SendQR0801()
                    break
                }
                
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
             //postRequest("QR/QR1001", "QR1001", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"11002","Operate":"getTerms","TransactionId":transactionId,"uid": AgriBank_DeviceID,"rebind":"0","born": birday
//], true), AuthorizationManage.manage.getHttpHead(true))

            }
            else {
                super.didResponse(description, response)
            }
        case "QR1001":
         if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {
            m_QuintupleImg.isHidden = true
            }
         else
             {
             if let data = response.object(forKey: ReturnData_Key) as? [String:AnyObject]{

                 if (data["Read"] as? String == "3") {
                    m_QuintupleImg.isHidden = false
         }  }}
        default: super.didResponse(description, response)
        }
    }
    // MARK:- Handle Actions
    func SendQR0801() {
//        postRequest("QR/QR0801", "QR0801", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"09004","Operate":"dataConfirm","TransactionId":transactionId], true), AuthorizationManage.manage.getHttpHead(true))
        let act = m_uiActView?.getContentByType(.First)
        postRequest("QR/QR0801", "QR0801", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"09009","Operate":"QRConfirm","cardNumber":act as! String,"TransactionId":transactionId,"appId": AgriBank_AppID,"uid": AgriBank_DeviceID], true), AuthorizationManage.manage.getHttpHead(true))
    }
  
    @IBAction func m_btnMakeQRCodeClick(_ sender: Any) {
    SendQR0801()
    }
    func GetInfor(){
        self.dismissKeyboard()
        //=====
        guard checkQRCodeData() == true else {
            return
        }
       //   TwPayImg.isHidden = false
        counter = 180
        LabelTimer.text = ""
        timer.invalidate()
        isPlaying = false
        countertime = Date()
        
        //QRCode
        let AppTemplate  = "6168" //Tag=61 長度=104(Hex(68))
        let AID  = "4F08A000000172950001" //4F Length:8  A000000172950001(固定值）
        var FISCCardTransData = "C15C" //C1 Length:92(5C)
        let TrNo = StringToHex(string: QRCodeInfo["TransCode"]!)//交易代碼，固定2541
        FISCCardTransData = FISCCardTransData  + TrNo!
//        let currnetDate = Date()
//        let dateFormatter = DateFormatter()
//        dateFormatter.timeZone = NSTimeZone.init(abbreviation:"UTC")! as TimeZone
//        dateFormatter.dateFormat = //"yyyyMMddHHmmss"
//        var TrxDateTime = dateFormatter.string(from: currnetDate)//交易日期時間
        let TrxDateTime = StringToHex(string:QRCodeInfo["TransTime"]!)
        FISCCardTransData = FISCCardTransData  + TrxDateTime!
        
        var act = QRCodeInfo["CardNumber"]//m_uiActView?.getContentByType(.First)
        let  BankCode  = StringToHex(string: QRCodeInfo["CardBank"]! + "00000")//act?.substring(to: 2)
        //BankCode = BankCode! + "00000" //String(format: "%08x", BankCode!)//發卡單位
        
        FISCCardTransData = FISCCardTransData  + BankCode!
        
        let FICRemark =  QRCodeInfo["TxMemo"]! //StringToHex(string: QRCodeInfo["TxMemo"]!)//晶片卡備註
        FISCCardTransData = FISCCardTransData  + FICRemark
        
        //let actNo =  StringToHex(string: String(format: "%016x", act!))//卡號
        let actNo = StringToHex(string: act!.leftPadding(toLength: 16, withPad: "0"))
        
        FISCCardTransData = FISCCardTransData  + actNo!
        
        let Tac = QRCodeInfo["TAC"]!  //StringToHex(string: QRCodeInfo["TAC"]!)//TAC
        FISCCardTransData = FISCCardTransData  + Tac
        
        let WalletKind =   StringToHex(string: QRCodeInfo["WalletType"]!)//錢包類型
        //let WalletKind =   StringToHex(string: "2")//錢包類型
        FISCCardTransData = FISCCardTransData  + WalletKind!
        
        let hexString = AppTemplate + AID + FISCCardTransData
        // let binaryData = hexString.dataFromHexadecimalString()
        let base64String = hexString.data(using: .bytesHexLiteral)?.base64EncodedString()
        
        if (base64String != nil) {
            self.m_ivQRCode.image = MakeQRCodeUtility.utility.generateQRCode(from: base64String!)
        }
        
        //BarCode
        let BarCodeType = "96" //95=金融卡雲支付 96=行動錢包支付
        let BarCodeVr = "1"  //版本代號＝1
        //dateFormatter.dateFormat = "mmss" //交易時間
        var BarCodeTime =   QRCodeInfo["TransTime"]!.substring(from: 10, length: 4)
        var BankCode2  = QRCodeInfo["CardBank"]//act?.substring(to: 2) //發卡單位
        // let actNo =  StringToHex(string: String(format: "%016x", act!))//卡號
        let TSN =  QRCodeInfo["TSN"]!.substring(from: QRCodeInfo["TSN"]!.characters.count - 4) //TSN後4碼
        let OTP =  QRCodeInfo["OTP"] //測試ＯＴＰ
        let Temp = "00" //保留
        
        
        let wkStr1 =  Int(BarCodeTime + BankCode2! + TSN)!
        var Str1 = String(wkStr1,radix: 16)
        Str1 = Str1.uppercased()
        Str1 = Str1.leftPadding(toLength: 9, withPad: "0")
        let wkStr2 = Int(act!)!
        var Str2 = String (wkStr2,radix: 16)
        Str2 = Str2.uppercased()
        Str2 = Str2.leftPadding(toLength: 14, withPad: "0")
        
        var BarCodeString = BarCodeVr + Str1 + Str2 + Temp + OTP!
        
        let BarCodebase64 =  BarCodeString.data(using: .bytesHexLiteral)?.base64EncodedString()
        BarCodeString = BarCodeType + BarCodebase64!
        LabelBarCode.text = BarCodeString
        if (BarCodeString != nil) {
            self.m_ivBarCode.image = MakeBarCode128Utility.utility.generateBarCode(from: BarCodeString)
        }
        //發票條碼
        let MBarCode = QRCodeInfo["MBarcode"]
        if MBarCode != "" {
        let imgwidth =  einvoiceImg.frame.width+100
        let imgheight = einvoiceImg.frame.height
         einvoiceImg.image = Code39.code39Image(from: MBarCode, width:  imgwidth, height: imgheight)
            self.einvoiceText.text = MBarCode! + "(發票載具)"
        }else{
            einvoiceText.text = ""
            einvoiceImg.image = nil
        }
        // 將瑩幕亮度調到最亮
        self.brightness = UIScreen.main.brightness // keep 住原本的亮度
         UIScreen.main.brightness = CGFloat(1)
        if(isPlaying) {
            timer.invalidate()
            isPlaying = false
            counter = 180
            LabelTimer.text = String(counter)
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
        isPlaying = true
        //五倍卷  by sweney
        postRequest("Usif/USIF0101", "USIF0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"08001","Operate":"queryData","TransactionId":transactionId], true), AuthorizationManage.manage.getHttpHead(true))
    }
    
    func UpdateTimer() {
        if (counter == 0 ){
            self.m_ivBarCode.image = nil
            self.m_ivQRCode.image = nil
            self.LabelBarCode.text = ""
           // TwPayImg.isHidden = true
            counter = 180
            LabelTimer.text = ""
            timer.invalidate()
            isPlaying = false
            return
        }
        //counter = counter - 1
        let now = Date()
        let SecInfo = Int(now.timeIntervalSince(countertime))
        counter = MaxTime - SecInfo
        LabelTimer.text = String(format: "有效時間剩：%d秒", counter)
        
        if pushReceiveFlag == "PAY"{
//            counter = 0
//            let alert = UIAlertView(title: UIAlert_Default_Title , message: pushReceiveFlag + "_timer", delegate: self, cancelButtonTitle: Determine_Title)
//            alert.show()
            performSegue(withIdentifier: "PayToPush", sender: nil)
        }
         //chiu push test end
        
    }
}



extension String {
    
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let newLength = self.characters.count
        if newLength < toLength {
            return String(repeatElement(character, count: toLength - newLength)) + self
        } else {
            return self.substring(from: index(self.startIndex, offsetBy: newLength - toLength))
        }
    }
    /// Expanded encoding
    ///
    /// - bytesHexLiteral: Hex string of bytes
    /// - base64: Base64 string
    enum ExpandedEncoding {
        /// Hex string of bytes
        case bytesHexLiteral
        /// Base64 string
        case base64
    }
    
    /// Convert to `Data` with expanded encoding
    ///
    /// - Parameter encoding: Expanded encoding
    /// - Returns: data
    func data(using encoding: ExpandedEncoding) -> Data? {
        switch encoding {
        case .bytesHexLiteral:
            guard self.characters.count % 2 == 0 else { return nil }
            var data = Data()
            var byteLiteral = ""
            for (index, character) in self.characters.enumerated() {
                if index % 2 == 0 {
                    byteLiteral = String(character)
                } else {
                    byteLiteral.append(character)
                    guard let byte = UInt8(byteLiteral, radix: 16) else { return nil }
                    data.append(byte)
                }
            }
            return data
        case .base64:
            return Data(base64Encoded: self)
        }
    }
}

func StringToHex (string:String)  -> String? {
    let data = Data([UInt8](string.utf8))
    let HexString = data.hexEncodedString()
    return HexString
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}



extension QRPayViewController0 : OneRowDropDownViewDelegate {
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

extension QRPayViewController0 : UIActionSheetDelegate {
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet.cancelButtonIndex != buttonIndex {
            switch (actionSheet.tag) {
            case ViewTag.View_AccountActionSheet.rawValue:
                let iIndex : Int = buttonIndex - 1
                let info : AccountStruct = m_arrActList[iIndex]
                let act : String = info.accountNO
                if (m_uiActView?.getContentByType(.First) != act) {
                    m_uiActView?.setOneRow("轉入帳號", act)
                    self.m_ivBarCode.image = nil
                    self.m_ivQRCode.image = nil
                    self.LabelBarCode.text = ""
                   // TwPayImg.isHidden = true
                    counter = 180
                    LabelTimer.text = ""
                    timer.invalidate()
                    isPlaying = false
                    SendQR0801()
                }
            default:
                break
            }
        }
    }
}

extension QRPayViewController0 : UITextFieldDelegate {
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
    
    override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
          
          // 將瑩幕亮度調回原設定
          if let brightness = self.brightness {
              UIScreen.main.brightness = brightness
          }
            }
}
