//
//  QRPayRefundViewController.swift
//  AgriBank
//
//  Created by ABOT on 2020/2/15.
//  Copyright © 2020 Systex. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import Photos


var QRRefundCodeInfo: [String: String] = [:]

class QRPayRefundViewController:BaseViewController {
    
    
    @IBOutlet var m_vReceiptView: UIView!
    @IBOutlet var m_vQRCodeArea: UIView!
    @IBOutlet var vBarCodeArea: UIView!
    @IBOutlet var m_ivQRCode: UIImageView!
    @IBOutlet var m_ivBarCode: UIImageView!
 
    
    @IBOutlet weak var LabelTimer: UILabel!
    
    // @IBOutlet weak var TwPayImg: UIImageView!
    @IBOutlet weak var LabelBarCode: UILabel!
    
    // - Public
    var wk_ActNo = ""
    var wk_seq = ""
    
    var m_uiActView : OneRowDropDownView? = nil
    var m_uiScanView : ScanCodeView? = nil
    
    private var m_strType : String = ""
    private var m_qrpInfo : MWQRPTransactionInfo? = nil
    private var m_taxInfo : PayTax? = nil
    var m_dicSecureData : [String:String]? = nil
    var m_bIsLoadFromAlbum : Bool = false
    
    var m_arrActList : [AccountStruct] = [AccountStruct]()
    
    
    //倒數計時180秒
    var counter = 180
    var MaxTime = 180
    var timer = Timer()
    var isPlaying = false
    var countertime = Date()//改用時間算才不會被警暫停
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initQRCodeArea()
        self.addGestureForKeyBoard()
        getTransactionID("09008", TransactionID_Description)
        //        self.send_getActList()
        
        LabelTimer.text = ""
        
        ///添加截圖通知
        NotificationCenter.default.addObserver(self, selector: #selector(self.userDidTakeScreenshot), name: NSNotification.Name.UIApplicationUserDidTakeScreenshot, object: nil)
        
        
        
    }
    deinit {
        ///移除通知
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationUserDidTakeScreenshot, object: nil)
        timer.invalidate()
        isPlaying = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.topItem?.title = "出示退款碼"
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
    
    // MARK:- UI Methods
    private func changeFunction(_ isReceipt:Bool) {
        if isReceipt {
            m_vReceiptView.isHidden = false
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
            
        }
    }
    
    
    // MARK:- WebService Methods
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                //chiu set
                //setLoading(true)

                GetInfor()
                //09004
//                postRequest("QR/QR0902", "QR0902", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"09008","Operate":"dataConfirm","TransactionId":transactionId,"ACTNO":wk_ActNo,"Serno":wk_seq], true), AuthorizationManage.manage.getHttpHead(true))
                
            }
            else {
                super.didResponse(description, response)
            }
        case "QR0902":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]]{
                for item in array {
                    let Key: String = item["Key"] as! String
                    let Value: String = item["Value"] as! String
                    QRCodeInfo[Key] = Value
                }
                GetInfor()
            }else {
                super.didResponse(description, response)
            }

        default: super.didResponse(description, response)
        }
    }
    // MARK:- Handle Actions
    
    @IBAction func BtnBackDetail(_ sender: Any) {
     navigationController?.popViewController(animated: true)
    }
    @IBAction func m_btnMakeQRCodeClick(_ sender: Any) {
        
        getTransactionID("09004", TransactionID_Description)
        // GetInfor()
    }
    func GetInfor(){
        self.dismissKeyboard()
        
        //   TwPayImg.isHidden = false
        counter = 180
        LabelTimer.text = ""
        timer.invalidate()
        isPlaying = false
        countertime = Date()
        
        //QRCode
        let AppTemplate  = "6140" //Tag=61 長度=64(Hex(40))
        let AID  = "4F08A000000172950001" //4F Length:8  A000000172950001(固定值）
        var FISCCardTransData = "C234" //C1 Length:52(Hex(34))
        let TrNo = StringToHex(string: QRCodeInfo["TransCode"]!)//交易代碼，固定2541
        FISCCardTransData = FISCCardTransData  + TrNo!
        //        let currnetDate = Date()
        //        let dateFormatter = DateFormatter()
        //        dateFormatter.timeZone = NSTimeZone.init(abbreviation:"UTC")! as TimeZone
        //        dateFormatter.dateFormat = //"yyyyMMddHHmmss"
        //        var TrxDateTime = dateFormatter.string(from: currnetDate)//交易日期時間
        let TrxDateTime = StringToHex(string:QRCodeInfo["TransTime"]!)
        FISCCardTransData = FISCCardTransData  + TrxDateTime!
        let act = QRCodeInfo["CardNumber"]
        let actNo = StringToHex(string: act!.leftPadding(toLength: 16, withPad: "0"))
        var BankCode  = QRCodeInfo["CardBank"]
        BankCode = BankCode! + "00000" //String(format: "%08x", BankCode!)//發卡單位
        BankCode = StringToHex(string: BankCode!)
        FISCCardTransData = FISCCardTransData  + BankCode!
        //let actNo =  StringToHex(string: String(format: "%016x", act))//卡號
        FISCCardTransData = FISCCardTransData  + actNo!
        //先寫死
        let Txn =  StringToHex(string: QRCodeInfo["TXN"]!)//application basic data 's TXN source institute ID (first 3 words)
        FISCCardTransData = FISCCardTransData  + Txn!
        
        let Stan =  StringToHex(string: QRCodeInfo["STAN"]!)//application basic data seq
        FISCCardTransData = FISCCardTransData  + Stan!
        let hexString = AppTemplate + AID + FISCCardTransData
        // let binaryData = hexString.dataFromHexadecimalString()
        let base64String = hexString.data(using: .bytesHexLiteral)?.base64EncodedString()
        
        if (base64String != nil) {
            self.m_ivQRCode.image = MakeQRCodeUtility.utility.generateQRCode(from: base64String!)
        }
        
        //BarCode
        let BarCodeType = "97" //95=金融卡雲支付 96=行動錢包支付
        let BarCodeVr = "0"  //版本代號＝0
        let BankCode2  = QRCodeInfo["CardBank"] //發卡單位
        var CardNo = QRCodeInfo["CardNumber"]
        CardNo = CardNo?.leftPadding(toLength:16, withPad: "0")
        let TXN2 =  QRCodeInfo["TXN"]
        let STAN2 =  QRCodeInfo["STAN"]
        
        let wkStr1 =  BarCodeVr + BankCode2! + CardNo! + TXN2! + STAN2!
        let BarCodebase64 =  wkStr1.data(using: .bytesHexLiteral)?.base64EncodedString()
        let BarCodeString = BarCodeType + BarCodebase64!
        LabelBarCode.text = BarCodeString
        if (BarCodeString != nil) {
            self.m_ivBarCode.image = MakeBarCode128Utility.utility.generateBarCode(from: BarCodeString)
        }
        
        
       
        if(isPlaying) {
            timer.invalidate()
            isPlaying = false
            counter = 180
            LabelTimer.text = String(counter)
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
        isPlaying = true
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
        
    }
}




extension QRPayRefundViewController : UIActionSheetDelegate {
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
                }
            default:
                break
            }
        }
    }
}

extension QRPayRefundViewController : UITextFieldDelegate {
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
