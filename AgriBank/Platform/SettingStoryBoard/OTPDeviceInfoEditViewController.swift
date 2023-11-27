//
//  OTPDeviceInfoEditViewController.swift
//  AgriBank
//
//  Created by 數位資訊部 on 2020/11/19.
//  Copyright © 2020 Systex. All rights reserved.
//

import Foundation
let OTODeviceEditTitle = "編輯轉入帳號註記"
let OTODeviceEditResult_Seque = "GotoOTODeviceEditResult"
class OTPDeviceInfoEditViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var labelMobileType: UILabel!
    @IBOutlet weak var labelCreateDate: UILabel!
    @IBOutlet weak var RemarkText: TextField!
    
    private var errorMessage = ""
    private var currentTextField:UITextField? = nil
    private var list:[[String:String]]? = nil
    // list infor
    //0 "轉轉入帳號"
    //1 "銀行代號"
    //2 "註記"

    
    // MARK: - Public
    func setList(_ list:[[String:String]]) {
        self.list = list
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setView()
        addObserverToKeyBoard()
        addGestureForKeyBoard()
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
        labelMobileType.text = list?[0][Response_Value]
        labelCreateDate.text = list?[1][Response_Value]
        RemarkText.text = list?[2][Response_Value]
        
    }
    @IBAction func BtnSend(_ sender: Any) {
        setLoading(true)
        getTransactionID("13002", TransactionID_Description)
    }
    override func didResponse(_ description:String, _ response: NSDictionary) {
        self.setLoading(false)
        switch description {
            
        case "COMM0814" :
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {
                if let message = response.object(forKey: ReturnMessage_Key) as? String {
                    errorMessage = message
                    showAlert(title: "編輯行動裝置暱稱發生錯誤", msg:errorMessage, confirmTitle: "確定", cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                }
            }
            
            performSegue(withIdentifier: OTODeviceEditResult_Seque, sender: nil)
        // self.setLoading(false)
        case TransactionID_Description:
            
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                setLoading(true) // loading show
                if let WkCd = response.object(forKey: "WorkCode") as? String , WkCd == "13002" {
                    
                    let sMobileUID = (list?[3][Response_Value])!
                    postRequest("COMM/COMM0814", "COMM0814", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"13002","Operate":"changeMotpRemark","TransactionId":transactionId,"MobileUID":sMobileUID ,"Remark":RemarkText.text as Any ],true), AuthorizationManage.manage.getHttpHead(true))
                    
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
        if segue.identifier == OTODeviceEditResult_Seque {
            let controller = segue.destination as! OTPDeviceInfoToEditResultViewController
            var barTitle:String? = nil
            barTitle = OTODeviceEditTitle
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
        if   currentTextField == RemarkText   {
            super.keyboardWillShow(notification)
        }
    }
    
    
}
