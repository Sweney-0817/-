//
//  InitTransToNoEditViewController.swift
//  AgriBank
//
//  Created by ABOT on 2020/3/23.
//  Copyright © 2020 Systex. All rights reserved.
//

import UIKit

let InitTransToNoEditTitle = "編輯轉入帳號註記"
let InitTransNoToResult_Seque = "GoInitTransNoEditResult"


class InitTransToNoEditViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var bankcodeLabel: UILabel!
    @IBOutlet weak var ActNoLabel: UILabel!
    @IBOutlet weak var RemarkText: TextField!
    
    @IBOutlet weak var SortText: TextField!
    private var errorMessage = ""
    private var currentTextField:UITextField? = nil
    private var list:[[String:String]]? = nil
    // list infor
    //0 "轉轉入帳號"
    //1 "銀行代號"
    //2 "註記"
    //3 "P_KEY"
    
    // MARK: - Public
    func setList(_ list:[[String:String]]) {
        self.list = list
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setView()
       addObserverToKeyBoard()
       addGestureForKeyBoard()
        
        RemarkText.setCanUseDefaultAction(bCanUse: true)
        SortText.setCanUseDefaultAction(bCanUse: true)
        
       // getTransactionID("03009", TransactionID_Description)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.topItem?.title = InitTransToNoEditTitle
    }
    
    // MARK: - Private
    private func setView() {
        bankcodeLabel.text = list?[0][Response_Value]
        ActNoLabel.text = list?[1][Response_Value]
        RemarkText.text = list?[2][Response_Value]
        let wkSort = list?[4][Response_Value]
        if wkSort == "255"{
            SortText.text = ""
        }else{
        SortText.text = list?[4][Response_Value]
        }
    }
    @IBAction func BtnSend(_ sender: Any) {
        setLoading(true)
        getTransactionID("03009", TransactionID_Description)
    }
    override func didResponse(_ description:String, _ response: NSDictionary) {
        self.setLoading(false)
        switch description {
            
        case "TRAN0705" ,"TRAN0707" :
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {
                if let message = response.object(forKey: ReturnMessage_Key) as? String {
                    errorMessage = message
                    showAlert(title: "編輯轉入帳號註記發生錯誤", msg:errorMessage, confirmTitle: "確定", cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                }
            }
            
            performSegue(withIdentifier: InitTransNoToResult_Seque, sender: nil)
        // self.setLoading(false)
        case TransactionID_Description:
            
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                setLoading(true) // loading show
                if let WkCd = response.object(forKey: "WorkCode") as? String , WkCd == "03009" {
                    var wkP_Key = ""
                    wkP_Key=(list?[3][Response_Value])!
                    var wkSort = ""
                    if SortText.text == "" {
                        wkSort = "255"
                    }else{
                        wkSort = SortText.text!
                    }
                    //postRequest("TRAN/TRAN0705", "TRAN0705", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03009","Operate":"changeReserAcct","TransactionId":transactionId,"P_KEY":wkP_Key ,"INACT":ActNoLabel.text as Any,"INBANK":bankcodeLabel.text as Any,"EXPLANATION":RemarkText.text as Any ],true), AuthorizationManage.manage.getHttpHead(true))
                    //  1.5.2  加排序
                    postRequest("TRAN/TRAN0707", "TRAN0707", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03009","Operate":"changeReserAcct","TransactionId":transactionId,"P_KEY":wkP_Key ,"INACT":ActNoLabel.text as Any,"INBANK":bankcodeLabel.text as Any,"EXPLANATION":RemarkText.text as Any,"SORT":wkSort as Any ],true), AuthorizationManage.manage.getHttpHead(true))
                    
                }
                else {
                    super.didResponse(description, response)
                }
            }
        default: super.didResponse(description, response)
            //  self.setLoading(false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == InitTransNoToResult_Seque {
            let controller = segue.destination as! InitTransToEditResultViewController
            var barTitle:String? = nil
            barTitle = InitTransToNoEditTitle
            controller.setBrTitle(barTitle)
        }
    }
    
      func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.count)! - range.length + string.count
        var maxLength = 0
        switch textField {
        case SortText:
            maxLength = 2
        case RemarkText:
            maxLength = 15
        default: break
        }
        if newLength <= maxLength {
            return true
        }
        else {
            return false
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentTextField = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        currentTextField = nil
        return true
    }
    // MARK: - KeyBoard
    override func addObserverToKeyBoard() {
        removeObserverToKeyBoard()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func keyboardWillShow(_ notification:NSNotification) {
        if loginView != nil, !(loginView?.isNeedRise())! {
            view.frame.origin.y = 0
            return
        }
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        
        // 換算 curTextfield 至 self.view的frame
        guard let txf = currentTextField,
              let frame1 = txf.superview?.convert(txf.frame, to: txf.superview?.superview),
              let frame2 = txf.superview?.superview?.superview?.convert(frame1, to: txf.superview?.superview?.superview?.superview),
              let frame3 = txf.superview?.superview?.superview?.superview?.superview?.convert(frame2, to: txf.superview?.superview?.superview?.superview?.superview?.superview)
        else { return }
        
        if (frame3.origin.y + originalY) >= keyboardRectangle.origin.y {
            let height = (frame3.origin.y + originalY + frame3.height) - keyboardRectangle.origin.y
            view.frame.origin.y = originalY - height
        }
    }
    
    
    
    
}
