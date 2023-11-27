//
//  USAccountEditViewController.swift
//  AgriBank
//
//  Created by ABOT on 2019/10/5.
//  Copyright © 2019 Systex. All rights reserved.
//

import UIKit

let USAccountEditTitle = "變更常用轉入帳號"
let USAccountResult_Seque = "GoUSAccEditResult"
class USAccountEditViewController:  BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var bankcodeLabel: UILabel!
    @IBOutlet weak var banknameLabel: UILabel!
    @IBOutlet weak var ActNoLabel: UILabel!
    @IBOutlet weak var EmailText: TextField!
   @IBOutlet weak var RemarkText: TextField!
    
    
  @IBOutlet weak var btnSend: UIButton!
    
    //2019-10-9 USAccountShowViedw set list infor
    private var errorMessage = ""
    private var currentTextField:UITextField? = nil 
    private var list:[[String:String]]? = nil
   // list infor
   //0 "銀行代號"
   //1 "銀行名稱"
   //2 "EMAIL"
   //3 "轉轉入帳號"
   //4 "說明"
   //5 "備註"
   //6 "P_KEY" 
    
    // MARK: - Public
    func setList(_ list:[[String:String]]) {
        self.list = list
    }
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        addObserverToKeyBoard()
        addGestureForKeyBoard()
        
        EmailText.setCanUseDefaultAction(bCanUse: true)
        RemarkText.setCanUseDefaultAction(bCanUse: true)
        
         getTransactionID("03008", TransactionID_Description)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.topItem?.title = USAccountEditTitle
    }
    
    
    
    // MARK: - Private
    private func setView() {
        bankcodeLabel.text = list?[0][Response_Value]
       banknameLabel.text = list?[1][Response_Value]
       ActNoLabel.text = list?[3][Response_Value]
        RemarkText.text = list?[4][Response_Value]
       EmailText.text = list?[2][Response_Value]
        
    }
    
    @IBAction func BtnSend(_ sender: Any) {
        if inputIsCorrect(){
        var wkP_Key = ""
        wkP_Key=(list?[6][Response_Value])! 
        setLoading(true)
        postRequest("TRAN/TRAN0702", "TRAN0702", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03008","Operate":"UpdateCommAcct","TransactionId":transactionId,"P_KEY":wkP_Key ,"INACT":ActNoLabel.text as Any,"INBANK":bankcodeLabel.text as Any,"EXPLANATION":RemarkText.text as Any,"MAIL":EmailText.text as Any],true), AuthorizationManage.manage.getHttpHead(true))
    }
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        self.setLoading(false)
        switch description {
        case "TRAN0702" :
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {
                if let message = response.object(forKey: ReturnMessage_Key) as? String {
                    errorMessage = message
                       showAlert(title: "變更常用帳號發生錯誤", msg:errorMessage, confirmTitle: "確定", cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                }
            }
            
            performSegue(withIdentifier: USAccountResult_Seque, sender: nil)
        // self.setLoading(false)
        case TransactionID_Description:

            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
            }
            else {
                super.didResponse(description, response)
            }

        default: super.didResponse(description, response)
            //  self.setLoading(false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == USAccountResult_Seque {
            let controller = segue.destination as! USAccountResultViewController
            var barTitle:String? = nil
             barTitle = USAccountEditTitle
            controller.setBrTitle(barTitle)
        }
    }
  
    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentTextField = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
}
    // MARK: - KeyBoard
    override func keyboardWillShow(_ notification:NSNotification) {
        if currentTextField == EmailText || currentTextField == RemarkText   {
            super.keyboardWillShow(notification)
        }
}
    
    private func inputIsCorrect() -> Bool {
        
        //EMAIL 檢核
        if !DetermineUtility.utility.isValidEmail(EmailText.text!) {
            showErrorMessage(nil, ErrorMsg_Invalid_Email)
            return false
        }
       
        return true
    }
}
