//
//  TripleViewController.swift
//  AgriBank
//
//  Created by abot on 2020/6/17.
//  Copyright © 2020 Systex. All rights reserved.
//

import UIKit
let GetFirstTriple_Segue = "GoGetFirstTripSeq"
let GetTripleShowView1_Segue = "goTripleShowView1"
let GetTripleShowView2_Segue = "goTripleShowView2"
let rewardType_Title = "領取方式"
let reward_TypeList = ["入帳","ATM領現金","捐贈碼(不具名)","捐贈碼(具名)"];
var isBack = "";
let TripleTitle = "振興三倍券綁定"
var readStatus = ""
private var errorMessage = ""
var rebind_flag = false
var readkind = "" //1090928 chris
class TripleViewController: BaseViewController,OneRowDropDownViewDelegate,UIActionSheetDelegate,UITextFieldDelegate {
    @IBOutlet weak var RewardTypeView: UIView! //chiu 0623
    @IBOutlet weak var Label_MobilePhone: UILabel!
    @IBOutlet weak var Label_BirthDay: UILabel!
    @IBOutlet weak var Label_ID: UILabel!
    @IBOutlet weak var Text_MobilePhone: UITextField!
    @IBOutlet weak var Label_donateCode: UITextField!
    @IBOutlet weak var BindingBtn: UIButton!
    var ArContent: [String:String]? = nil
    var readContent: [[String:String]]? = nil
    var triplePhone = ""
    var rewardTp = ""
    
    private var TripleCodeInfo: [String: String] = [:]
    private var m_DDType: OneRowDropDownView? = nil  //chiu 0623
    private var m_curDropDownView: OneRowDropDownView? = nil //chiu 0623
    private var curTextfield:UITextField? = nil //chiu 0623
    private var m_txnNo = ""
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

        if isBack == ""  && readStatus == ""{
            readStatus = "0"
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
           case "QR1001": //chiu 改用[string:AnyObject]因read=1時有object項目（捐贈碼） TripleCodeInfo
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
                        readStatus = "0"
                        readkind = "0"  //1090928 chris
                    
                           if let data = response.object(forKey: ReturnData_Key) as? [String:String]{
                              ArContent = data
                           }
                           transactionId = tempTransactionId
                           performSegue(withIdentifier: GetFirstTriple_Segue, sender: nil)
                       }
                    
                    if (data["Read"] as? String == "1") {
                        readStatus = "1"
                        readkind = "1"  //1090928 chris
                        if let data = response.object(forKey: ReturnData_Key) as? [[String:String]]{
                           readContent = data
                        }
                        for item in data {
                            if  ((item.value as? String) != nil){
                                TripleCodeInfo[item.key] = item.value as? String
                            }
                        }
                        
                        ArContent = TripleCodeInfo
                        transactionId = tempTransactionId
                        if isBack == "REBIND"{
                            rebind_flag = true
                            readStatus = ""
                             performSegue(withIdentifier: GetFirstTriple_Segue, sender: nil)
                        }else{
                            if rebind_flag == true{
                                rebind_flag = false
                            }else{
                                performSegue(withIdentifier: GetTripleShowView1_Segue, sender: nil)
                            }
                           
                        }
                        
                    }
                    if (data["Read"] as? String == "2") {
                        readStatus = "2"
                        readkind = "2"  //1090928 chris
                        BindingBtn.titleLabel?.adjustsFontSizeToFitWidth = true;
                        BindingBtn.titleLabel?.minimumScaleFactor = 1
                        BindingBtn.titleLabel?.text = "更改領取方式"
                        for item in data {
                            if  ((item.value as? String) != nil){
                                TripleCodeInfo[item.key] = item.value as? String
                            }
                        }
                        
                        ArContent = TripleCodeInfo
                        transactionId = tempTransactionId
                        if isBack == "next"{
                            if let CIFERR = ArContent?[("CIFERR")]{
                                 Label_ID.text = CIFERR
                             }
                             if let phone = ArContent?[("phone")]{
                                Label_MobilePhone.text = phone + "(簡訊通知用)"
                                triplePhone = phone
                             }
                            isBack = ""
                            readStatus = ""
                           // getTransactionID("09008", TransactionID_Description)
                        }
                        else
                        {
                            performSegue(withIdentifier: GetTripleShowView2_Segue, sender: nil)
                        }

                        }
                    if (data["Read"] as? String == "3") {
                        readStatus = "3"
                        readkind = "3"  //1090928 chris
                        if let data = response.object(forKey: ReturnData_Key) as? [[String:String]]{
                           readContent = data
                        }
                        for item in data {
                            if  ((item.value as? String) != nil){
                                TripleCodeInfo[item.key] = item.value as? String
                            }
                        }
                        
                        ArContent = TripleCodeInfo
                        transactionId = tempTransactionId
                       
                            performSegue(withIdentifier: GetTripleShowView1_Segue, sender: nil)
  
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
                            TripleCodeInfo[Key] = Value
                        }
                       
                    }
                    transactionId = tempTransactionId
                    
                   performSegue(withIdentifier: "goTripleResultView", sender: nil)
                       }
                
//                   let controller = getControllerByID(.FeatureID_TripleResult)
//                   navigationController?.pushViewController(controller, animated: true)
               
           case "USIF0101":
               if let data = response.object(forKey: ReturnData_Key) as? [String:Any] {
                   
                   if let mobilePhone = data["MPHONE"] as? String {
                       Label_MobilePhone.text = mobilePhone.trimmingCharacters(in: .whitespaces) + "(簡訊通知用)"
                    triplePhone = mobilePhone
                    
                   }
                 
                   if let birthday = data["BIRTHDAY"] as? String {
                    Label_BirthDay.text = birthday
                   }
                    if let CIFID = data["CIFERR"] as? String {
                     Label_ID.text = CIFID
                    }
                if isBack == "ChangeReward"{
                    isBack = "next"
                    getTransactionID("09008", TransactionID_Description)
                }
               }
               else {
                   super.didResponse(description, response)
               }
           case TransactionID_Description:
               if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                   transactionId = tranId
                   setLoading(true)
                if isBack == "YES" || isBack == "ChangeReward" {
                    if isBack == "YES"{
                       isBack = ""
                    }
                    
                    postRequest("Usif/USIF0101", "USIF0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"08001","Operate":"queryData","TransactionId":tranId], true), AuthorizationManage.manage.getHttpHead(true))
                }else
                 {
                    if readStatus != ""{
                        var ibind = ""
                        if readStatus == "0" || readStatus == "2" {
                            ibind = "0"
                            readStatus = ""
                        }
                        if readStatus == "1" {
                            ibind = "1"
                            readStatus = ""
                        }
                        if m_Action != "BIND" {
                           // postRequest("QR/QR1001", "QR1001", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"110011","Operate":"dataContirm","TransactionId":tranId,"uid": AgriBank_DeviceID,"rebind":ibind], true), AuthorizationManage.manage.getHttpHead(true))
                        }
                        
                    }
                    
                }
                if m_Action == "BIND"{
                  m_Action = ""
                  setLoading(true)
                    self.postRequest("QR/QR1003", "QR1003", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"11001","Operate":"CommitTxn","TransactionId":transactionId,"born":Label_BirthDay.text ?? "","phone":triplePhone,"rewardTp":rewardTp,"donateCode":Label_donateCode.text ?? "","kind":readkind], true), AuthorizationManage.manage.getHttpHead(true))
                }// 1090928 chris "kind" > readkind
                if isBack == "REBIND"{
                                  isBack = ""
                                  readStatus = ""
                                   performSegue(withIdentifier: GetFirstTriple_Segue, sender: nil)
                              }
               }
               else {
                   super.didResponse(description, response)
               }
               
           default: super.didResponse(description, response)
           }
       }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Read ="0"
        if segue.identifier == GetFirstTriple_Segue {
            let controller = segue.destination as! GetFirstTripleViewController
            var barTitle:String? = nil
            barTitle = "振興三倍券綁定條款"
            controller.setBrTitle(barTitle)
            controller.m_dicAcceptData = ArContent
            controller.m_nextFeatureID = curFeatureID
            controller.transactionId = tempTransactionId
            curFeatureID = nil
            tempTransactionId = ""
            isBack = "YES"
        }
        var list = [[String:String]]()
        if readStatus == "1" || readStatus == "2" || readStatus == "3"{
               if let CIFERR = ArContent?[("CIFERR")]{
                   list.append([Response_Key: "身份證字號", Response_Value:CIFERR ])
               }
               else {
                   list.append([Response_Key: "身份證字號", Response_Value:""])
               }
               if let Content = ArContent?[("Content")]{
                   list.append([Response_Key: "狀態", Response_Value:Content ])
               }
               else {
                   list.append([Response_Key: "狀態", Response_Value:""])
               }
               if let txnNo = ArContent?[("txnNo")]{
                   list.append([Response_Key: "綁定序號", Response_Value:txnNo ])
                   m_txnNo = txnNo
               }
               else {
                   list.append([Response_Key: "綁定序號", Response_Value:""])
               }
               if let rewardTp = ArContent?[("rewardTp")]{
                   if rewardTp == "0" {
                       list.append([Response_Key: "領取方式", Response_Value:"入帳" ])
                   }
                   if rewardTp == "1" {
                       list.append([Response_Key: "領取方式", Response_Value:"ATM領現金" ])
                   }
                   if rewardTp == "2" {
                       list.append([Response_Key: "領取方式", Response_Value:"捐贈碼(不具名)" ])
                   }
                   if rewardTp == "3" {
                       list.append([Response_Key: "領取方式", Response_Value:"捐贈碼(具名)" ])
                   }
                   
                   if rewardTp == "2" || rewardTp == "3" {
                       if let donatName = ArContent?[("donatName")]{
                       list.append([Response_Key: "捐贈機構", Response_Value:donatName ])
                           }else {
                               list.append([Response_Key: "捐贈機構", Response_Value:""])
                           }
                   }
               }
               else {
                   list.append([Response_Key: "領取方式", Response_Value:""])
               }
        }
        // Read ="1" or "3"
        if segue.identifier == GetTripleShowView1_Segue {
            //var list = [[String:String]]()
            let controller = segue.destination as! TripleShowDetailViewController
           
            controller.transactionId = tempTransactionId
            curFeatureID = nil
            tempTransactionId = ""
            //isBack = "YES"

            controller.setList(TripleTitle, list, readStatus)
        }
        // Read="2"
        if segue.identifier == GetTripleShowView2_Segue {
            //var list = [[String:String]]()
            let controller = segue.destination as! TripleShow2DetailViewController

            controller.transactionId = tempTransactionId
            curFeatureID = nil
            tempTransactionId = ""
            //isBack = "YES"
            //controller.setList(TripleTitle, [ArContent!])
           
            controller.setList(TripleTitle, list,readStatus,m_txnNo)
        }
        //綁定成功
        if segue.identifier == "goTripleResultView"
            {
                let controller = segue.destination as! TripleResultViewController
                var list = [[String:String]]()
                if let IDNO =  TripleCodeInfo[("身份證字號")]{
                    list.append([Response_Key: "身份證字號", Response_Value:IDNO ])
                }
                else {
                    list.append([Response_Key: "身份證字號", Response_Value:""])
                }
                if let MPHONE =  TripleCodeInfo[("行動電話")]{
                    list.append([Response_Key: "行動電話", Response_Value:MPHONE ])
                }
                else {
                    list.append([Response_Key: "行動電話", Response_Value:""])
                }
                if let REWARD =  TripleCodeInfo[("領取方式")]{
                    list.append([Response_Key: "領取方式", Response_Value:REWARD ])
                }
                else {
                    list.append([Response_Key: "領取方式", Response_Value:""])
                }
                if let BINDNO =  TripleCodeInfo[("綁定序號")]{
                    list.append([Response_Key: "綁定序號", Response_Value:BINDNO ])
                }
                else {
                    list.append([Response_Key: "綁定序號", Response_Value:""])
                }
                if let BINDNO =  TripleCodeInfo[("授權時間")]{
                    list.append([Response_Key: "授權時間", Response_Value:BINDNO ])
                }
                else {
                    list.append([Response_Key: "授權時間", Response_Value:""])
                }
                controller.setList(TripleTitle, list)
            }
    }
    @IBAction func clickBindingBtn(_ sender: Any) {
    
            if inputIsCorrect() {
                
                m_Action = "BIND"
                getTransactionID("09008", TransactionID_Description)

                    }
                    else {
                    
                    }
                }
private func inputIsCorrect() -> Bool {
    if rewardTp == ""{
        showErrorMessage(nil, "請選取綁定方式")
        return false
    }
    if (rewardTp == "2" || rewardTp == "3") && Label_donateCode.text == "" {
        showErrorMessage(nil, "請輸入捐贈碼")
        return false
    }
    if Text_MobilePhone.text != "" {
        triplePhone = Text_MobilePhone.text!
    }
    return true
    }
    
    private func setDDTypeView() {
              if m_DDType == nil {
                  m_DDType = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
                  m_DDType?.delegate = self
                  m_DDType?.setOneRow(rewardType_Title,Choose_Title)
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
               list = reward_TypeList
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
//        if m_DDType?.getContentByType(.First) == reward_TypeList[0]  {
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
 TripleCodeInfo    [String : String]    8 key/value pairs
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
