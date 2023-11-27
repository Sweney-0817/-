//
//  QuintupleViewController.swift
//  AgriBank
//
//  Created by ABOT on 2021/9/14.
//  Copyright © 2021 Systex. All rights reserved.
//

import UIKit
let GetFirstQuintuple_Segue = "GoGetFirstQuintupleSeq"
 let GetQuintupleShowView1_Segue = "goQuintupleShowView1"
 let GetQuintupleShowView2_Segue = "goQuintupleShowView2"
let rewardType_TitleQ = "領取方式"
//let reward_TypeListQ = ["入帳","ATM領現金","捐贈碼(不具名)","捐贈碼(具名)"];
let reward_TypeListQ = ["入帳"] //chiu 20210915
var isBackQ = ""
let QuintupleTitle = "振興五倍券綁定"
var readStatusQ = ""
private var errorMessage = ""
var rebind_flagQ = false
var readkindQ = "" //1090928 chris
class QuintupleViewController: BaseViewController,OneRowDropDownViewDelegate,UIActionSheetDelegate,UITextFieldDelegate {
    @IBOutlet weak var RewardTypeView: UIView! //chiu 0623
    @IBOutlet weak var Label_MobilePhone: UILabel!
    @IBOutlet weak var Label_BirthDay: UILabel!
    @IBOutlet weak var Label_ID: UILabel!
    @IBOutlet weak var Text_MobilePhone: UITextField!
    @IBOutlet weak var Label_donateCode: UITextField!
    @IBOutlet weak var BindingBtn: UIButton!
    var ArContent: [String:AnyObject]? = nil
    var readContent: [String:AnyObject]? = nil
    var triplePhone = ""
    var rewardTp = ""
    var ReadQ = ""
    
    private var QuintupleCodeInfo: [String: AnyObject] = [:]
    private var m_DDType: OneRowDropDownView? = nil  //chiu 0623
    private var m_curDropDownView: OneRowDropDownView? = nil //chiu 0623
    private var curTextfield:UITextField? = nil //chiu 0623
    private var m_txnNo = ""
    private var m_hsNo = ""
    private var m_couponCode = ""
    private var m_Action = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObserverToKeyBoard()
        addGestureForKeyBoard()
        Text_MobilePhone.delegate = self
        Label_donateCode.delegate = self
//        Text_MobilePhone.keyboardType = .numberPad
//        Label_donateCode.keyboardType = .numberPad
        setDDTypeView()
        getTransactionID("09008", TransactionID_Description)
      
        if isBackQ == ""  && readStatusQ == ""{
            readStatusQ = "0"
        }else{
           
        }
            
    }
    
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
   
        
    override func didResponse(_ description:String, _ response: NSDictionary) {
           switch description {
           case "QR1001": //chiu 改用[string:AnyObject]因read=1時有object項目（捐贈碼） QuintupleCodeInfo
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {
                  if let message = response.object(forKey: ReturnMessage_Key) as? String {
                      errorMessage = message
                      showAlert(title: "綁定檢查時發生錯誤", msg:errorMessage, confirmTitle: "確定", cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                  }
               }
            else
                {
                if let data = response.object(forKey: ReturnData_Key) as? [String:AnyObject]{
                    if (data["Read"] as? String == "0") {
                        readStatusQ = "0"
                        readkindQ = "0"  //1090928 chris
                    
                        //  if let data = response.object(forKey: ReturnData_Key) as? [String:String]{
                              ArContent = data
                      //  }
                           transactionId = tempTransactionId
                        ReadQ = ""
                           performSegue(withIdentifier: GetFirstQuintuple_Segue, sender: nil)
                       }
                    
//                    if (data["Read"] as? String == "1") {
//                        readStatusQ = "1"
//                        readkindQ = "1"  //1090928 chris
//                        if let data = response.object(forKey: ReturnData_Key) as? [String:AnyObject]{
//                           readContent = data
//                        }
//                        for item in data {
//                            if  ((item.value as? String) != nil){
//                                QuintupleCodeInfo[item.key] = item.value
//                            }
//                        }
//
//                        ArContent = QuintupleCodeInfo
//                        transactionId = tempTransactionId
//                        if isBackQ == "REBIND"{
//                            rebind_flagQ = true
//                            readStatusQ = ""
//                             performSegue(withIdentifier: GetFirstQuintuple_Segue, sender: nil)
//                        }else{
//                            if rebind_flagQ == true{
//                                rebind_flagQ = false
//                            }else{
//                                performSegue(withIdentifier: GetQuintupleShowView1_Segue, sender: nil)
//                            }
//
//                        }
//
//                    }
                    if (data["Read"] as? String == "2") {
                        readStatusQ = "2"
                        readkindQ = "2"  //1090928 chris
                      
                        for item in data {
                            
                            if (item.key == "payInfo"){
                                if  item.value is NSMutableArray   {
                                    if  let array = item.value as? [[String:String]]{
                                        var ArIndex = 0
                                        for item in array {
                                           // let StrIndex  = ArIndex as? String
                                           if  ((item["couponTp"]) != nil){
                                            let Key: String = "couponTp" + String(ArIndex)
                                                let Value: String = item["couponTp"]!
                                                QuintupleCodeInfo[Key] = Value as AnyObject
                                            }
                                            if  ((item["maxPayAmount"]) != nil){
                                                let Key: String = "maxPayAmount" + String(ArIndex)
                                                let Value: String = item["maxPayAmount"]!
                                                QuintupleCodeInfo[Key] = Value as AnyObject
                                            }
                                            if  ((item["payedAmount"]) != nil){
                                                let Key: String = "payedAmount" + String(ArIndex)
                                                let Value: String = item["payedAmount"]!
                                                QuintupleCodeInfo[Key] = Value as AnyObject
                                            }
                                            ArIndex = ArIndex + 1
                                        }
                                        
                                    }
                               }
                            }else{
                                if  ((item.value as? String) != nil){
                            QuintupleCodeInfo[item.key] = item.value
                                }
                            }
                        }
                        
                        ArContent = QuintupleCodeInfo
                        transactionId = tempTransactionId
                       
                        performSegue(withIdentifier: GetQuintupleShowView1_Segue, sender: nil)
                    }
                    if (data["Read"] as? String == "3") {
                        readStatusQ = "3"
                        readkindQ = "3"  //1090928 chris
                       // if let data = response.object(forKey: ReturnData_Key) as? [[String:String]]{
                           readContent = data
                      //  }
                        for item in data {
                           
                                if (item.key == "payInfo"){
                                    if  item.value is NSMutableArray   {
                                        if  let array = item.value as? [[String:String]]{
                                            var ArIndex = 0
                                            for item in array {
                                               // let StrIndex  = ArIndex as? String
                                               if  ((item["couponTp"]) != nil){
                                                let Key: String = "couponTp" + String(ArIndex)
                                                    let Value: String = item["couponTp"]!
                                                    QuintupleCodeInfo[Key] = Value as AnyObject
                                                }
                                                if  ((item["maxPayAmount"]) != nil){
                                                    let Key: String = "maxPayAmount" + String(ArIndex)
                                                    let Value: String = item["maxPayAmount"]!
                                                    QuintupleCodeInfo[Key] = Value as AnyObject
                                                }
                                                if  ((item["payedAmount"]) != nil){
                                                    let Key: String = "payedAmount" + String(ArIndex)
                                                    let Value: String = item["payedAmount"]!
                                                    QuintupleCodeInfo[Key] = Value as AnyObject
                                                }
                                                ArIndex = ArIndex + 1
                                            }
                                            
                                        }
                                   }
                                }else{
                                    if  ((item.value as? String) != nil){
                                QuintupleCodeInfo[item.key] = item.value
                                    }
                                }
                            
                            }
                        
                        
                        ArContent = QuintupleCodeInfo
                        transactionId = tempTransactionId
                       
                            performSegue(withIdentifier: GetQuintupleShowView2_Segue, sender: nil)
  
                    }
                }
            }
                
            case "QR1003":
               if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {
                   if let message = response.object(forKey: ReturnMessage_Key) as? String {
                       errorMessage = message
                       showAlert(title: "綁定時發生錯誤", msg:errorMessage, confirmTitle: "確定", cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                   }
                }
               else
                {
                    
                    if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]]{
                        for item in array {
                            let Key: String = item["Key"] as! String
                            let Value: String = item["Value"] as! String
                            QuintupleCodeInfo[Key] = Value as AnyObject
                        }
                       
                    }
                    transactionId = tempTransactionId
                    
                   performSegue(withIdentifier: "goQuintupleResultView", sender: nil)
                       }
                
//                   let controller = getControllerByID(.FeatureID_TripleResult)
//                   navigationController?.pushViewController(controller, animated: true)
               
           case "USIF0101":
               if let data = response.object(forKey: ReturnData_Key) as? [String:Any] {
                   
                   if let mobilePhone = data["MPHONE"] as? String {
                     //  Label_MobilePhone.text = mobilePhone.trimmingCharacters(in: .whitespaces) + "(簡訊通知用)"
                       var phone = mobilePhone.trimmingCharacters(in: .whitespaces)
                       let start = phone.index(phone.startIndex,offsetBy: 4)
                       let end = phone.index(phone.startIndex,offsetBy: 3+4)
                       phone.replaceSubrange(start..<end, with: "***")
                       Label_MobilePhone.text = phone + "(簡訊通知用)"
                       Label_MobilePhone.adjustsFontSizeToFitWidth = true
                       
                    triplePhone = mobilePhone
                    
                   }
                 
                   if let birthday = data["BIRTHDAY"] as? String {
                    Label_BirthDay.text = birthday
                   }
                    if let CIFID = data["CIFERR"] as? String {
                        var ID = ""
                        ID =  CIFID.uppercased()
                        let start = ID.index(ID.startIndex,offsetBy: 4)
                        let end = ID.index(ID.startIndex,offsetBy: 3+4)
                        ID.replaceSubrange(start..<end, with: "***")
                        Label_ID.text = ID
                    // Label_ID.text = CIFID
                    }
                
//                if isBackQ == "ChangeReward"{
//                    isBackQ = "next"
//                    getTransactionID("09008", TransactionID_Description)
//                }
                if( ReadQ == "" ) {
               // postRequest("QR/QR1001", "QR1001", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"11002","Operate":"getTerms","TransactionId":transactionId,"uid": AgriBank_DeviceID,"rebind":"0","born": Label_BirthDay.text
//], true), AuthorizationManage.manage.getHttpHead(true))
                }else{
                    super.didResponse(description, response)
                }
               }
               else {
                   super.didResponse(description, response)
               }
           case TransactionID_Description:
               if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                tempTransactionId = tranId
                transactionId = tempTransactionId
                   setLoading(true)
              //  if isBackQ == "YES" || isBackQ == "ChangeReward" {
              //      if isBackQ == "YES"{
               //         isBackQ = ""
               //     }
                    
                    postRequest("Usif/USIF0101", "USIF0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"08001","Operate":"queryData","TransactionId":tranId], true), AuthorizationManage.manage.getHttpHead(true))
               // }else
                // {
//                    if readStatusQ != ""{
//                        var ibind = ""
//                        if readStatusQ == "0" || readStatusQ == "2" {
//                            ibind = "0"
//                            readStatusQ = ""
//                        }
//                        if readStatusQ == "1" {
//                            ibind = "1"
//                            readStatusQ = ""
//                        }
//                        if m_Action != "BIND" {
//                            postRequest("QR/QR1001", "QR1001", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"11002","Operate":"getTerms","TransactionId":tranId,"uid": AgriBank_DeviceID,"rebind":ibind,"born": Label_BirthDay.text
//], true), AuthorizationManage.manage.getHttpHead(true))
//                        }
//
//                    }
                    
               // }
//                if m_Action == "BIND"{
//                  m_Action = ""
//                  setLoading(true)
//                  self.postRequest("QR/QR1003", "QR1003", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"11001","Operate":"CommitTxn","TransactionId":transactionId,"born":Label_BirthDay.text,"phone":triplePhone,"rewardTp":rewardTp,"donateCode":Label_donateCode.text,"kind":readkindQ], true), AuthorizationManage.manage.getHttpHead(true))
//                }// 1090928 chris "kind" > readkindQ
//                if isBackQ == "REBIND"{
//                    isBackQ = ""
//                    readStatusQ = ""
//                                   performSegue(withIdentifier: GetFirstQuintuple_Segue, sender: nil)
//                              }
//               }
//               else {
//                   super.didResponse(description, response)
              }
               
           default: super.didResponse(description, response)
           }
       }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Read ="0"
        if segue.identifier == GetFirstQuintuple_Segue {
            let controller = segue.destination as! GetFirstQuintupleViewController
            var barTitle:String? = nil
            barTitle = "振興五倍券綁定條款"
            controller.setBrTitle(barTitle)
            controller.m_dicAcceptData = ArContent
            controller.m_nextFeatureID = curFeatureID
            controller.transactionId = transactionId // tempTransactionId
            curFeatureID = nil
            tempTransactionId = ""
            isBackQ = "YES"
        }
        var list = [[String:String]]()
        if readStatusQ == "1" || readStatusQ == "2" || readStatusQ == "3"{
               if let CIFERR = ArContent?[("CIFERR")] as? String {
                if CIFERR == "" {}else{
                    var ID = ""
                    ID =  CIFERR.uppercased()
                    let start = ID.index(ID.startIndex,offsetBy: 4)
                    let end = ID.index(ID.startIndex,offsetBy: 3+4)
                    ID.replaceSubrange(start..<end, with: "***")
                  // list.append([Response_Key: "身份證字號", Response_Value:CIFERR ])
                    list.append([Response_Key: "身份證字號", Response_Value:ID ])
                }}
//               else {
//                   list.append([Response_Key: "身份證字號", Response_Value:""])
//               }
               if let Content = ArContent?[("Content")]as? String {
                if Content == "" {} else{
                   list.append([Response_Key: "狀態", Response_Value:Content ])
                }}
//               else {
//                   list.append([Response_Key: "狀態", Response_Value:""])
//               }
               if let txnNo = ArContent?[("txnNo")]as? String {
                if txnNo == "" {} else{
                   list.append([Response_Key: "綁定序號", Response_Value:txnNo ])
                   m_txnNo = txnNo
                }}
//               else {
//                   list.append([Response_Key: "綁定序號", Response_Value:""])
//               }
            if let bindingTime = ArContent?[("bindingTime")]as? String {
                if bindingTime == "" {} else {
                list.append([Response_Key: "綁定時間", Response_Value:bindingTime ])
                }}
//            else {
//                list.append([Response_Key: "綁定時間", Response_Value:""])
//            }
            if let raiseCount = ArContent?[("raiseCount")]as? String {
                if  raiseCount  == "" {} else {
                list.append([Response_Key: "共同綁定數", Response_Value:raiseCount ])
                }}
//            else {
//                list.append([Response_Key: "共同綁定數", Response_Value:""])
//            }
            if let raiseBindingTime = ArContent?[("raiseBindingTime")]as? String {
                if raiseBindingTime == "" {} else{
                if raiseBindingTime != "" {
                    list.append([Response_Key: "共同綁定時間", Response_Value:raiseBindingTime ])
                }}
                
            }
            
            if let couponCode = ArContent?[("couponCode")] as? String {
                if couponCode == "" {} else {
                list.append([Response_Key: "優惠代碼", Response_Value:couponCode ])
                m_couponCode = couponCode
                }}
//            else {
//                list.append([Response_Key: "優惠代碼", Response_Value:""])
//            }
            
            if let hsNo = ArContent?[("hsNo")] as? String {
                if hsNo == "" {} else {
                list.append([Response_Key: "好食券序號", Response_Value:hsNo ])
                m_hsNo = hsNo
                }}
//            else {
//                list.append([Response_Key: "好食券序號", Response_Value:""])
//            }
            
            for item in 0..<ArContent!.count {
                let icouponTp = "couponTp" + String(item)
                if let couponTp = ArContent?[icouponTp] as? String {
                    list.append([Response_Key: "優惠券種", Response_Value:couponTp ])
                    m_couponCode = couponTp
                }
                let imaxPayAmount = "maxPayAmount" + String(item)
                if let maxPayAmount = ArContent?[imaxPayAmount] as? String {
                    list.append([Response_Key: "可回饋總金額", Response_Value:maxPayAmount ])
                    m_couponCode = maxPayAmount
                }
               
                let ipayedAmount = "payedAmount" + String(item)
                if let payedAmount = ArContent?[ipayedAmount] as? String {
                    list.append([Response_Key: "已回饋總金額", Response_Value:payedAmount ])
                    m_couponCode = payedAmount
                }
                
            }
            
        }
        // Read ="1" or "3"
        if segue.identifier == GetQuintupleShowView1_Segue {
            //var list = [[String:String]]()
            let controller = segue.destination as! QuintupleShowDetailViewController
           
            controller.transactionId = tempTransactionId
            curFeatureID = nil
            tempTransactionId = ""
            //isBackQ = "YES"

            controller.setList(QuintupleTitle, list, readStatusQ)
        }
        // Read="2"
        if segue.identifier == GetQuintupleShowView2_Segue {
            //var list = [[String:String]]()
            let controller = segue.destination as! QuintupleShow2DetailViewController

            controller.transactionId = tempTransactionId
            curFeatureID = nil
            tempTransactionId = ""
            
           
            controller.setList(QuintupleTitle, list,readStatusQ,m_txnNo)
        }
        //綁定成功
        if segue.identifier == "goQuintupleResultView"
            {
                let controller = segue.destination as! QuintupleResultViewController
                var list = [[String:String]]()
                if let IDNO =  QuintupleCodeInfo[("身份證字號")] as? String {
                    list.append([Response_Key: "身份證字號", Response_Value:IDNO ])
                }
                else {
                    list.append([Response_Key: "身份證字號", Response_Value:""])
                }
                if let MPHONE =  QuintupleCodeInfo[("行動電話")] as? String {
                    list.append([Response_Key: "行動電話", Response_Value:MPHONE ])
                }
                else {
                    list.append([Response_Key: "行動電話", Response_Value:""])
                }
//                if let REWARD =  QuintupleCodeInfo[("領取方式")]{
//                    list.append([Response_Key: "領取方式", Response_Value:REWARD ])
//                }
//                else {
//                    list.append([Response_Key: "領取方式", Response_Value:""])
//                }
                if let BINDNO =  QuintupleCodeInfo[("綁定序號")] as? String {
                    list.append([Response_Key: "綁定序號", Response_Value:BINDNO ])
                }
                else {
                    list.append([Response_Key: "綁定序號", Response_Value:""])
                }
            if let BINDNO =  QuintupleCodeInfo[("授權時間")] as? String {
                list.append([Response_Key: "授權時間", Response_Value:BINDNO ])
            }
            else {
                list.append([Response_Key: "授權時間", Response_Value:""])
            }
            if let couponCode =  QuintupleCodeInfo[("優惠代碼")] as? String {
                list.append([Response_Key: "優惠代碼", Response_Value:couponCode ])
            }
            else {
                list.append([Response_Key: "優惠代碼", Response_Value:""])
            }
            if let hsNo =  QuintupleCodeInfo[("好食券序號")] as? String {
                list.append([Response_Key: "好食券序號", Response_Value:hsNo ])
            }
            else {
                list.append([Response_Key: "好食券序號", Response_Value:""])
            }
            
       
            
                controller.setList(QuintupleTitle, list)
            }
    }
    @IBAction func clickBindingBtn(_ sender: Any) {
        //show Bind msg
        let confirmHandler : ()->Void = { [self] in
           
                if inputIsCorrect() {
                    setLoading(true)
                    self.postRequest("QR/QR1003", "QR1003", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"11001","Operate":"CommitTxn","TransactionId":transactionId,"born":Label_BirthDay.text ?? "","phone":triplePhone,"rewardTp":"","donateCode":"","kind":"0"], true), AuthorizationManage.manage.getHttpHead(true))
                    }
        }
        let cancelHandler : ()->Void = {()}
        showAlert(title: "注意", msg: "請注意綁定後無法取消！請確定是否要執行綁定？" , confirmTitle: "確認", cancleTitle: "取消", completionHandler: confirmHandler, cancelHandelr: cancelHandler)
        
    }
private func inputIsCorrect() -> Bool {
//    if rewardTp == ""{
//        showErrorMessage(nil, "請選取綁定方式")
//        return false
//    }
//    if (rewardTp == "2" || rewardTp == "3") && Label_donateCode.text == "" {
//        showErrorMessage(nil, "請輸入捐贈碼")
//        return false
//    }
    if Text_MobilePhone.text != "" {
        triplePhone = Text_MobilePhone.text!
    }else{
        if( Label_MobilePhone.text == "(簡訊通知用)" ){
        showErrorMessage(nil, "請輸入行動電話")
        return false
        }
    }
    return true
    }
    
    private func setDDTypeView() {
              if m_DDType == nil {
                  m_DDType = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
                  m_DDType?.delegate = self
                  m_DDType?.setOneRow(rewardType_TitleQ,Choose_Title)
                  m_DDType?.frame = CGRect(x:0, y:0, width:RewardTypeView.frame.width, height:(m_DDType?.getHeight())!)
                  RewardTypeView.addSubview(m_DDType!)
              }
              RewardTypeView.layer.borderColor = Gray_Color.cgColor
              RewardTypeView.layer.borderWidth = 1
          }
    // MARK: - OneRowDropDownViewDelegate
       func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
           view.endEditing(true)
           m_curDropDownView = sender
            var list = [String]()
            if m_curDropDownView == m_DDType {
               list = reward_TypeListQ
           }
        if errorMessage.isEmpty {
            let action = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
            list.forEach{title in action.addButton(withTitle: title)}
            action.show(in: self.view)
        }
        else {
            showErrorMessage(nil, errorMessage)
        }
       }
       // MARK: - UITextFieldDelegate
          func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
              curTextfield = textField
              return true
          }
       // MARK: - UIActionSheetDelegate
       func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
           if actionSheet.cancelButtonIndex != buttonIndex {
               if m_curDropDownView == m_DDType {
                    rewardTp = (String)(buttonIndex - 1)
                //愛心碼欄位顯示
                if buttonIndex <= 2 {
                    Label_donateCode.isHidden = true
                    Label_donateCode.text = ""
                }else{
                    Label_donateCode.isHidden = false
                }
               }
               m_curDropDownView?.setOneRow(m_curDropDownView?.m_lbFirstRowTitle.text ?? "", actionSheet.buttonTitle(at: buttonIndex) ?? "")
           }
           m_curDropDownView = nil
       }
    
//    override func keyboardWillShow(_ notification: NSNotification) {
//        if m_DDType?.getContentByType(.First) == reward_TypeListQ[0]  {
//            super.keyboardWillShow(notification)
//        }
//    }
    // MARK: - UITextFieldDelegate
       func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder()
           curTextfield = nil
           return true
       }
    // MARK: - KeyBoard
//       override func keyboardWillShow(_ notification:NSNotification) {
//           if curTextfield == Text_MobilePhone || curTextfield == Label_donateCode {
//               super.keyboardWillShow(notification)
//           }
//       }
   func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    _ = (textField.text?.count)! - range.length + string.count
//       if textField == m_tfCheckNumber {
//           if newLength > CheckLoseApply_Bill_Max_Length {
//               return false
//           }
//       }
       return true
   }
}


/*
 QuintupleCodeInfo    [String : String]    8 key/value pairs
 [0]    (key: String, value: String)
 key    String    "CIFERR"
 value    String    "D120998998"
 [1]    (key: String, value: String)
 key    String    "Version"
 value    String    ""
 [2]    (key: String, value: String)
 key    String    "txnNo"
 value    String    "0011759691"
 [3]    (key: String, value: String)
 key    String    "rewardTp"
 value    String    "0"
 [4]    (key: String, value: String)
 key    String    "Content"
 value    String    "已綁定"
 [5]    (key: String, value: String)
 key    String    "donateCode"
 value    String    ""
 [6]    (key: String, value: String)
 key    String    "phone"
 value    String    " " //chris0728
 [7]    (key: String, value: String)
 key    String    "Read"
 value    String    "2"
*/

