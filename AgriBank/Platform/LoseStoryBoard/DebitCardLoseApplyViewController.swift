//
//  LoseATMCardViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/6/23.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let DebitCardLoseApply_Account_Title = "卡片帳號"
let DebitCardLoseApply_Memo = "請您本人攜帶身分證及原留印鑑來行辦理取消掛失或重新申請作業"

class DebitCardLoseApplyViewController: BaseViewController, OneRowDropDownViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, ImageConfirmViewDelegate {
    @IBOutlet weak var m_vShadowView: UIView!
    @IBOutlet weak var m_vDropDownView: UIView!
    @IBOutlet weak var m_tfWebBankPassword: TextField!
    @IBOutlet weak var m_vWebBankPasswordView: UIView!
    @IBOutlet weak var m_vImageConfirmView: UIView!
    private var m_OneRow: OneRowDropDownView? = nil
    private var m_ImageConfirmView: ImageConfirmView? = nil
    private var accountList:[AccountStruct]? = nil      // 帳號列表
    private var accountIndex:Int? = nil                 // 目前選擇轉出帳號
    private var password = ""

    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        setAllSubView()
        setShadowView(m_vShadowView)
        
        getTransactionID("04002", TransactionID_Description)
        addGestureForKeyBoard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                setLoading(true)
                postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else {
                super.didResponse(description, response)
            }
            
        case "ACCT0101":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]] {
                for category in array {
                    if let type = category["ACTTYPE"] as? String, let result = category["AccountInfo"] as? [[String:Any]], type == Account_Saving_Type {
                        accountList = [AccountStruct]()
                        for actInfo in result {
                            if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? String, let ebkfg = actInfo["EBKFG"] as? String {
                                accountList?.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
                            }
                        }
                    }
                }
                
                getImageConfirm(transactionId)
            }
            else {
                super.didResponse(description, response)
            }
            
        case "COMM0501":
            if let responseImage = response[RESPONSE_IMAGE_KEY] as? UIImage {
                m_ImageConfirmView?.m_ivShow.image = responseImage
            }
            
        case "COMM0502":
            if let flag = response[RESPONSE_IMAGE_CONFIRM_RESULT_KEY] as? String, flag == ImageConfirm_Success {
                let pdMd5 = SecurityUtility.utility.MD5(string: m_tfWebBankPassword.text!)
                setLoading(true)
                postRequest("LOSE/LOSE0201", "LOSE0201", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"04001","Operate":"setLoseAcnt","TransactionId":transactionId,"ACTNO":accountList?[accountIndex!].accountNO ?? "","PWD":pdMd5], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else {
                getImageConfirm(transactionId)
                showErrorMessage(nil, ErrorMsg_Image_ConfirmFaild)
            }
            
        case "LOSE0201":
            var result = ConfirmResultStruct()
            result.resultBtnName = "繼續交易"
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode == ReturnCode_Success {
                result.title = Lose_Successful_Title
                result.image = ImageName.CowSuccess.rawValue
                result.memo = DebitCardLoseApply_Memo
                if let data = response.object(forKey:ReturnData_Key) as? [String:String] {
                    result.list = [[String:String]]()
                    result.list?.append([Response_Key:"交易時間",Response_Value:data["TXTIME"] ?? ""])
                    result.list?.append([Response_Key:"掛失日期",Response_Value:data["TXDAY"] ?? ""])
                }
            }
            else {
                result.title = Lose_Faild_Title
                result.image = ImageName.CowFailure.rawValue
                if let message = response.object(forKey:ReturnMessage_Key) as? String {
                    result.list = [[String:String]]()
                    result.list?.append([Response_Key:Error_Title,Response_Value:message])
                }
            }
            enterConfirmResultController(false, result, true)
            
        default: super.didResponse(description, response)
        }
    }
    
    // MARK: - Private
     private func setAllSubView() {
        setDropDownView()
        setWebBankPasswordView()
        setImageConfirmView()
    }

    private func setDropDownView() {
        if m_OneRow == nil {
            m_OneRow = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
            m_OneRow?.delegate = self
            m_OneRow?.setOneRow(DebitCardLoseApply_Account_Title, Choose_Title)
            m_vDropDownView.addSubview(m_OneRow!)
        }
        m_OneRow?.frame = CGRect(x:0, y:0, width:m_vDropDownView.frame.width, height:(m_OneRow?.getHeight())!)
        m_vDropDownView.layer.borderColor = Gray_Color.cgColor
        m_vDropDownView.layer.borderWidth = 1
    }
    
    private func setWebBankPasswordView() {
        m_vWebBankPasswordView.layer.borderColor = Gray_Color.cgColor
        m_vWebBankPasswordView.layer.borderWidth = 1
    }

    private func setImageConfirmView() {
        if m_ImageConfirmView == nil {
            m_ImageConfirmView = getUIByID(.UIID_ImageConfirmView) as? ImageConfirmView
            m_ImageConfirmView?.delegate = self
            m_vImageConfirmView.addSubview(m_ImageConfirmView!)
        }
        m_ImageConfirmView?.frame = CGRect(x:0, y:0, width:m_vImageConfirmView.frame.width, height:m_vImageConfirmView.frame.height)
        m_vImageConfirmView.layer.borderColor = Gray_Color.cgColor
        m_vImageConfirmView.layer.borderWidth = 1
    }
    
    private func inputIsCorrect() -> Bool {
        if accountIndex == nil {
            showErrorMessage(nil, "\(Choose_Title)\(m_OneRow?.m_lbFirstRowTitle.text ?? "")")
            return false
        }
        if (m_tfWebBankPassword.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(m_tfWebBankPassword.placeholder ?? "")")
            return false
        }
        return true
    }
    
    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        if accountList != nil {
            if (accountList?.count)! > 0 {
                let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
                accountList?.forEach{index in actSheet.addButton(withTitle: index.accountNO)}
                actSheet.tag = ViewTag.View_AccountActionSheet.rawValue
                actSheet.show(in: view)
            }
            else {
                showErrorMessage(nil, "\(Get_Null_Title)\(sender.m_lbFirstRowTitle.text!)")
            }
        }
        else {
            showErrorMessage(nil, "\(Get_Null_Title)\(sender.m_lbFirstRowTitle.text!)")
        }
    }

    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            switch actionSheet.tag {
            case ViewTag.View_AccountActionSheet.rawValue:
                accountIndex = buttonIndex-1
                if let info = accountList?[accountIndex!] {
                    m_OneRow?.setOneRow(DebitCardLoseApply_Account_Title, info.accountNO)
                }
                
            default: break
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == m_tfWebBankPassword {
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            if !DetermineUtility.utility.isEnglishAndNumber(newString) {
                return false
            }
        }
        return true
    }
    
    // MARK: - ImageConfirmCellDelegate
    func clickRefreshBtn() {
        getImageConfirm(transactionId)
    }
    
    func changeInputTextfield(_ input: String) {
        password = input
    }
    
    func ImageConfirmTextfieldBeginEditing(_ textfield:UITextField) {}
    
    // MARK: - StoryBoard Touch Event
    @IBAction func m_btnSendClick(_ sender: Any) {
        if inputIsCorrect() {
            checkImageConfirm(password, transactionId)
        }
    }
}
