//
//  USAccountAddViewController.swift
//  AgriBank
//
//  Created by ABOT on 2019/10/5.
//  Copyright © 2019 Systex. All rights reserved.
//

import UIKit
let USAccount_BankCode = "銀行代碼"
let USActAddResult_Seque = "GoUSAccAddResult"
let USAccountAddTitle = "新增常用轉入帳號"

class USAccountAddViewController:  BaseViewController, UITextFieldDelegate , OneRowDropDownViewDelegate,UIActionSheetDelegate {
    

    @IBOutlet weak var AccountInput: TextField!
    @IBOutlet weak var EmailInput: TextField!
    @IBOutlet weak var RemarkInput: TextField!
    @IBOutlet weak var BtnAdd: UIButton!
    @IBOutlet weak var BtnDel: UIButton!
   
    @IBOutlet weak var showBankView: UIView!
    
    private var bankNameList:[[String:String]]? = nil   // 銀行代碼列表
    private var bankNameIndex:Int? = nil                // 銀行代碼Index
    private var showBankDorpView:OneRowDropDownView? = nil
      private var currentTextField:UITextField? = nil
      private var errorMessage = ""
    // MARK: - Private
    private func inputIsCorrect() -> Bool {
        //check bank
        if showBankDorpView?.getContentByType(.First) == Choose_Title {
            showErrorMessage(nil, "\(Choose_Title)\((showBankDorpView?.m_lbFirstRowTitle.text)!)")
            return false
        }
       //轉入帳號檢核
        if AccountInput.text!.isEmpty  {
            showErrorMessage(nil, ErrorMsg_USAccount)
            return false
        }else{
            if (AccountInput.text?.count)! > 16{
                showErrorMessage(nil,  ErrorMsg_USAccountLen)
                 return false
            }
        }
        //EMAIL 檢核
        if !DetermineUtility.utility.isValidEmail(EmailInput.text!) {
            showErrorMessage(nil, ErrorMsg_Invalid_Email)
            return false
        }
       
        return true
    }
    
    override func viewDidLoad() {
        
           super.viewDidLoad()
        
        addObserverToKeyBoard()
        addGestureForKeyBoard()
        
        AccountInput.setCanUseDefaultAction(bCanUse: true)
        EmailInput.setCanUseDefaultAction(bCanUse: true)
        RemarkInput.setCanUseDefaultAction(bCanUse: true)
        
        
        showBankDorpView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        showBankDorpView?.setOneRow(USAccount_BankCode, Choose_Title)
        showBankDorpView?.frame = showBankView.frame
        showBankDorpView?.frame.origin = .zero
        showBankDorpView?.delegate = self
        showBankView.addSubview(showBankDorpView!)
        
         getTransactionID("03007", TransactionID_Description)
    }
    @IBAction func btnAdd(_ sender: Any) {
         if inputIsCorrect() {
        setLoading(true)
        postRequest("TRAN/TRAN0701", "TRAN0701", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03007","Operate":"addCommAcct","TransactionId":transactionId ,"INACT":AccountInput.text as Any,"INBANK":showBankDorpView?.getContentByType(.First) ?? "","EXPLANATION":RemarkInput.text as Any,"MAIL":EmailInput.text as Any],true), AuthorizationManage.manage.getHttpHead(true))    }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == USActAddResult_Seque {
            let controller = segue.destination as! USAccountResultViewController
            var barTitle:String? = nil
            barTitle = USAccountAddTitle
            controller.setBrTitle(barTitle)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.topItem?.title = USAccountAddTitle
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        if bankNameList == nil {
            setLoading(true)
            postRequest("COMM/COMM0401", "COMM0401", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07001","Operate":"getList"], false), AuthorizationManage.manage.getHttpHead(false))
        }
        else {
            showBankList()
        }
    }

    private func showBankList() {
        if bankNameList != nil {
           
            var array = [String]()
            for index in bankNameList! {
                if let name = index["bankName"], let code = index["bankCode"] {
                    let temp = "\(code) \(name)".trimmingCharacters(in: .whitespaces)
                    if (code == "600"){
                        //600放在第一個
                        array.insert(temp, at: 0)
                    }else{
                    array.append(temp)
                    }
                }
            }
            SGActionView.showSheetQr(withTitle: Choose_Title, itemTitles: array, selectedIndex: 0) { index in
                self.bankNameIndex = index
                let title = array[index]
                let array = title.components(separatedBy: .whitespaces)
                self.showBankDorpView?.setOneRow(NTTransfer_BankCode, array.first ?? "")
            }
        }
    }

 
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
               
            }
            else {
                super.didResponse(description, response)
            }
            
        case "COMM0401":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:String]] {
                bankNameList = array
                showBankList()
            }
            else {
                super.didResponse(description, response)
            }
        case "TRAN0701" :
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {
                if let message = response.object(forKey: ReturnMessage_Key) as? String {
                    errorMessage = message
                    showAlert(title: "新增常用帳號發生錯誤", msg:errorMessage, confirmTitle: "確定", cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                }
            }
            
            performSegue(withIdentifier: USActAddResult_Seque, sender: nil)
        default: super.didResponse(description, response)
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
        if currentTextField == EmailInput || currentTextField == RemarkInput  || currentTextField == AccountInput   {
            super.keyboardWillShow(notification)
            
        }
    }
 
}
    
    



