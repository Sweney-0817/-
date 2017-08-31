//
//  BasicInfoChangeViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/11.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let GoBaseInfoChangeResult_Segue = "GoBaseInfoChangeResult"

class BasicInfoChangeViewController: BaseViewController, UITextFieldDelegate {
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var mobilePhoneLabel: UILabel!
    @IBOutlet weak var telePhoneLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var emailTextfield: TextField!        // 新Email
    @IBOutlet weak var mobliePhoneTextfield: TextField!  // 新行動電話
    @IBOutlet weak var telePhoneTextfield: TextField!    // 新電話號碼
    @IBOutlet weak var addressTextfield: TextField!      // 新聯絡地址
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var teleAreaCodeTextfield: TextField! // 新區碼
    @IBOutlet weak var postalCodeTextfield: TextField!   // 新郵遞區號
    private var currentTextField:UITextField? = nil
    private var resultList:[[String:String]]? = nil
    private var emailFG = ""      // input需要的「E-MAIL  通知狀態」
    private var funcd = ""        // input需要的「變更項目」
    private var teleAreaCode = "" // 原區碼
    private var telePhone = ""    // 原電話號碼
    private var postalCode = ""   // 原郵遞區號
    private var address = ""      // 原聯絡地址
    
    // MARK: - Private
    private func InputIsCorrect() -> Bool {
        if emailTextfield.text!.isEmpty && mobliePhoneTextfield.text!.isEmpty && telePhoneTextfield.text!.isEmpty && teleAreaCodeTextfield.text!.isEmpty && postalCodeTextfield.text!.isEmpty && addressTextfield.text!.isEmpty {
            showErrorMessage(nil, ErrorMsg_NeedChangeOne)
            return false
        }
        if (telePhoneTextfield.text!.isEmpty && !teleAreaCodeTextfield.text!.isEmpty) || (!telePhoneTextfield.text!.isEmpty && teleAreaCodeTextfield.text!.isEmpty) {
            showErrorMessage(nil, ErrorMsg_Telephone)
            return false
        }
        if (postalCodeTextfield.text!.isEmpty && !addressTextfield.text!.isEmpty) || (!postalCodeTextfield.text!.isEmpty && addressTextfield.text!.isEmpty) {
            showErrorMessage(nil, ErrorMsg_Address)
            return false
        }
        if !emailTextfield.text!.isEmpty && !DetermineUtility.utility.isValidEmail(emailTextfield.text!) {
            showErrorMessage(nil, ErrorMsg_Invalid_Email)
            return false
        }
        
        return true
    }
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setShadowView(bottomView)
        setLoading(true)
        getTransactionID("08001", TransactionID_Description)
        addObserverToKeyBoard()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! BasicInfoResultViewController
        controller.SetList(resultList)
    }

    // MARK: - StoryBoard Touch Event
    @IBAction func clickChangeBtn(_ sender: Any) {
        if InputIsCorrect() {
            setLoading(true)
            let email:String = emailTextfield.text!.isEmpty ? emailLabel.text! : emailTextfield.text!
            let mobliePhone:String = mobliePhoneTextfield.text!.isEmpty ? mobilePhoneLabel.text! : mobliePhoneTextfield.text!
            let areaCode:String = teleAreaCodeTextfield.text!.isEmpty ?  teleAreaCode : teleAreaCodeTextfield.text!
            let phone:String = telePhoneTextfield.text!.isEmpty ? telePhone : telePhoneTextfield.text!
            let code:String = postalCodeTextfield.text!.isEmpty ? postalCode : postalCodeTextfield.text!
            let ADR2:String = addressTextfield.text!.isEmpty ? address : addressTextfield.text!
            postRequest("Usif/USIF0102", "USIF0102", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"08001","Operate":"dataConfirm","TransactionId":transactionId,"FUNCD":funcd,"EMAIL":email,"EMAILFG":emailFG,"MPHONE ":mobliePhone,"AREA1":areaCode,"TELNO1":phone,"ZIPCD2":code,"ADR2":ADR2], true), AuthorizationManage.manage.getHttpHead(true))
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentTextField = textField
        if textField.keyboardType == .numberPad {
            // ToolBar
            let toolBar = UIToolbar()
            toolBar.barTintColor = ToolBar_barTintColor
            toolBar.tintColor = ToolBar_tintColor
            toolBar.sizeToFit()
            // Adding Button ToolBar
            let doneButton = UIBarButtonItem(title: ToolBar_DoneButton_Title, style: .plain, target: self, action: #selector(clickDoneBtn(_:)))
            let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let cancelButton = UIBarButtonItem(title: ToolBar_CancelButton_Title, style: .plain, target: self, action: #selector(clickCancelBtn(_:)))
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: ToolBar_Title_Weight, height: toolBar.frame.height))
            titleLabel.textColor = .black
            titleLabel.text = Choose_Title
            titleLabel.textAlignment = .center
            let titleButton = UIBarButtonItem(customView: titleLabel)
            
            toolBar.setItems([cancelButton, spaceButton, titleButton, spaceButton, doneButton], animated: false)
            toolBar.isUserInteractionEnabled = true
            textField.inputAccessoryView = toolBar
        }

        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - ConnectionUtilityDelegate
    override func didRecvdResponse(_ description:String, _ response: NSDictionary) {
        setLoading(false)
        switch description {
        case "USIF0101":
            if let data = response.object(forKey: "Data") as? [String:Any] {
                if let email = data["EMAIL"] as? String {
                    emailLabel.text = email
                }
                if let mobilePhone = data["MPHONE"] as? String {
                    mobilePhoneLabel.text = mobilePhone
                }
                if let telePhone = data["TELNO1"] as? String, let teleAreaCode = data["AREA1"] as? String {
                    telePhoneLabel.text = "\(teleAreaCode)-\(telePhone)"
                    self.teleAreaCode = teleAreaCode
                    self.telePhone = telePhone
                }
                if let address = data["ADR2"] as? String, let postalCode = data["ZIPCD2"] as? String {
                    addressLabel.text = "\(postalCode) \(address)"
                    self.address = address
                    self.postalCode = postalCode
                }
                if let flage = data["EMAILFG"] as? Int {
                    emailFG = "\(flage)"
                }
                if let member = data["MEMBER"] as? Int {
                    // 會員別 = 0 為非會員 其他則為會員
                    if member == 0 {
                        funcd = "88"
                    }
                    else {
                        funcd = "89"
                        teleAreaCodeTextfield.text = teleAreaCode
                        teleAreaCodeTextfield.isEnabled = false
                        teleAreaCodeTextfield.backgroundColor = Disable_Color
                        telePhoneTextfield.text = telePhone
                        telePhoneTextfield.isEnabled = false
                        telePhoneTextfield.backgroundColor = Disable_Color
                        addressTextfield.text = address
                        addressTextfield.isEnabled = false
                        addressTextfield.backgroundColor = Disable_Color
                        postalCodeTextfield.text = postalCode
                        postalCodeTextfield.isEnabled = false
                        postalCodeTextfield.backgroundColor = Disable_Color
                    }
                }
            }
            else {
                super.didRecvdResponse(description, response)
            }
            
        case TransactionID_Description:
            if let data = response.object(forKey: "Data") as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                setLoading(true)
                postRequest("Usif/USIF0101", "USIF0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"08001","Operate":"queryData","TransactionId":tranId], false), AuthorizationManage.manage.getHttpHead(false))
            }
            else {
                super.didRecvdResponse(description, response)
            }
        
        case "USIF0102":
            if let data = response.object(forKey: "Data") as? [[String:String]] {
                resultList = data
                performSegue(withIdentifier: GoBaseInfoChangeResult_Segue, sender: nil)
            }
            else {
                super.didRecvdResponse(description, response)
            }
            
        default: super.didRecvdResponse(description, response)
        }
    }
    
    // MARK: - selector
    func clickCancelBtn(_ sender:Any) {
        currentTextField?.text = ""
        currentTextField?.resignFirstResponder()
    }
    
    func clickDoneBtn(_ sender:Any) {
        currentTextField?.resignFirstResponder()
    }
    
    // MARK: - KeyBoard
    override func keyboardWillShow(_ notification:NSNotification) {
        if currentTextField == teleAreaCodeTextfield || currentTextField == telePhoneTextfield || currentTextField == postalCodeTextfield || currentTextField == addressTextfield {
            super.keyboardWillShow(notification)
        }
    }
}
