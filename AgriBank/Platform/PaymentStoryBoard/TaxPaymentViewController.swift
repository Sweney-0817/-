//
//  TaxPaymentViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/3.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let TaxPayment_Type_Title = "稅費種類"
let TaxPayment_Kind_Title = "繳稅類別"
let TaxPayment_OutAccount_Title = "轉出帳號"
let TaxPayment_Type1_List = ["機關代號", "身份證字號", "繳納金額"]
let TaxPayment_Type2_List = ["銷帳編號", "繳費期限(2017/05/01即20170501)", "繳納金額"]
let TaxPayment_Type1 = "1"      // 規格1 = TaxPayment_Type1_List
let TaxPayment_Type2 = "2"      // 規格2 = TaxPayment_Type2_List

class TaxPaymentViewController: BaseViewController, OneRowDropDownViewDelegate, UIActionSheetDelegate, UITextFieldDelegate {
    @IBOutlet weak var m_vShadowView: UIView!
    @IBOutlet weak var m_vDDType: UIView!
    @IBOutlet weak var m_vDDKind: UIView!
    @IBOutlet weak var m_vInput1: UIView!
    @IBOutlet weak var m_tfInput1: TextField!
    @IBOutlet weak var m_vInput2: UIView!
    @IBOutlet weak var m_tfInput2: TextField!
    @IBOutlet weak var m_vDDAccount: UIView!
    @IBOutlet weak var m_vInput3: UIView!
    @IBOutlet weak var m_tfInput3: TextField!

    private var m_DDType: OneRowDropDownView? = nil
    private var m_DDKind: OneRowDropDownView? = nil
    private var m_DDAccount: OneRowDropDownView? = nil
    private var m_curDropDownView: OneRowDropDownView? = nil
    private var typeCodeList = [[String:String]]()
    private var typeCodeIndex:Int? = nil
    private var typeItemList = [String:[[String:String]]]()
    private var typeItemIndex:Int? = nil                // typeItemList的index
    private var accountList:[AccountStruct]? = nil      // 帳號列表
    private var curType = TaxPayment_Type1              //
    private var endDate = ""                            // 截止日

    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()

        m_tfInput3.placeholder = TaxPayment_Type1_List[2]
        initInputForType(curType)
        
        m_DDType = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        m_DDType?.delegate = self
        m_DDType?.setOneRow(TaxPayment_Type_Title, Choose_Title)
        m_DDType?.frame = CGRect(x:0, y:0, width:m_vDDType.frame.width, height:m_vDDType.frame.height)
        m_vDDType.addSubview(m_DDType!)
        
        m_DDKind = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        m_DDKind?.delegate = self
        m_DDKind?.setOneRow(TaxPayment_Kind_Title, Choose_Title)
        m_DDKind?.frame = CGRect(x:0, y:0, width:m_vDDKind.frame.width, height:m_vDDKind.frame.height)
        m_vDDKind.addSubview(m_DDKind!)
        
        m_DDAccount = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        m_DDAccount?.delegate = self
        m_DDAccount?.setOneRow(TaxPayment_OutAccount_Title, Choose_Title)
        m_DDAccount?.frame = CGRect(x:0, y:0, width:m_vDDAccount.frame.width, height:m_vDDAccount.frame.height)
        m_vDDAccount.addSubview(m_DDAccount!)
        
        m_vShadowView.layer.borderWidth = Layer_BorderWidth
        m_vShadowView.layer.borderColor = Gray_Color.cgColor
        setShadowView(m_vShadowView)
        addGestureForKeyBoard()
        
        setLoading(true)
        postRequest("PAY/PAY0101", "PAY0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"05001","Operate":"getList","TransactionId":transactionId], true), AuthorizationManage.manage.getHttpHead(true))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {            
        case "PAY0101":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let result = data["Result"] as? [[String:Any]] {
                for dic in result {
                    if let type = dic["ACTTYPE"] as? String, let code = dic["ACTTYPECODE"] as? String, let item = dic["ITEM"] as? [[String:String]] {
                        typeCodeList.append(["ACTTYPE":type,"ACTTYPECODE":code])
                        typeItemList[type] = item
                    }
                }
            }
            else {
                super.didResponse(description, response)
            }
            setLoading(true)
            postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
            
        case "ACCT0101":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]]{
                for category in array {
                    if let type = category["ACTTYPE"] as? String, let result = category["AccountInfo"] as? [[String:Any]], type == Account_Saving_Type {
                        accountList = [AccountStruct]()
                        for actInfo in result {
                            if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? String, let ebkfg = actInfo["EBKFG"] as? String, ebkfg == Account_EnableTrans {
                                accountList?.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
                            }
                        }
                    }
                }
            }
            else {
                super.didResponse(description, response)
            }
            
        case "PAY0102","PAY0104":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let Id = data["taskId"] as? String {
                VaktenManager.sharedInstance().getTasksOperation{ resultCode, tasks  in
                    if VIsSuccessful(resultCode) && tasks != nil {
                        self.payTax(tasks! as! [VTask], Id)
                    }
                    else {
                        self.showErrorMessage(nil, "\(ErrorMsg_GetTasks_Faild) \(resultCode.rawValue)")
                    }
                }
            }
            else {
                showErrorMessage(nil, ErrorMsg_No_TaskId)
            }
            
        default: super.didResponse(description, response)
        }
    }

    // MARK: - Private
    private func initInputForType(_ type:String) {
        m_tfInput1.text = ""
        m_tfInput2.text = ""
        endDate = ""
        if type == TaxPayment_Type1 {
            m_tfInput1.placeholder = TaxPayment_Type1_List[0]
            m_tfInput2.placeholder = TaxPayment_Type1_List[1]
        }
        else if type == TaxPayment_Type2 {
            m_tfInput1.placeholder = TaxPayment_Type2_List[0]
            m_tfInput2.placeholder = TaxPayment_Type2_List[1]
        }
    }
    
    private func inputIsCorrect() -> Bool {
        if m_DDType?.getContentByType(.First) == Choose_Title {
            showErrorMessage(nil, "\(Choose_Title)\(m_DDType?.m_lbFirstRowTitle.text ?? "")")
            return false
        }
        if m_DDKind?.getContentByType(.First) == Choose_Title {
            showErrorMessage(nil, "\(Choose_Title)\(m_DDKind?.m_lbFirstRowTitle.text ?? "")")
            return false
        }
        if (m_tfInput1.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(m_tfInput1.placeholder ?? "")")
            return false
        }
        if (m_tfInput2.text?.isEmpty)! {
            if curType == TaxPayment_Type1 {
                showErrorMessage(nil, "\(Enter_Title)\(m_tfInput2.placeholder ?? "")")
                return false
            }
            else {
                showErrorMessage(nil, ErrorMsg_Choose_PayDate)
                return false
            }
        }
        else {
            if curType == TaxPayment_Type1 {
                if (m_tfInput2.text?.characters.count)! < Min_Identify_Length {
                    showErrorMessage(nil, ErrorMsg_ID_LackOfLength)
                    return false
                }
            }
        }
        if curType == TaxPayment_Type1 {
            if !DetermineUtility.utility.isValidIdentify(m_tfInput2.text!) {
                showErrorMessage(nil, ErrorMsg_Error_Identify)
                return false
            }
        }
        if m_DDAccount?.getContentByType(.First) == Choose_Title {
            showErrorMessage(nil, "\(Choose_Title)\(m_DDAccount?.m_lbFirstRowTitle.text ?? "")")
            return false
        }
        if (m_tfInput3.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(m_tfInput3.placeholder ?? "")")
            return false
        }
        if let amount = Int(m_tfInput3.text!) {
            if amount == 0 {
                showErrorMessage(nil, ErrorMsg_Input_Amount)
                return false
            }
        }
        else {
            showErrorMessage(nil, ErrorMsg_Illegal_Character)
            return false
        }
        return true
    }
    
    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        if sender == m_DDType && typeCodeList.count == 0 {
            showErrorMessage(nil, "無法取得\(m_DDType?.m_lbFirstRowTitle.text ?? "")")
            return
        }
        else if sender == m_DDKind {
            if m_DDType?.getContentByType(.First) == Choose_Title {
                showErrorMessage(nil, "請先選擇\(m_DDType?.m_lbFirstRowTitle.text ?? "")")
                return
            }
            else if typeItemList.count == 0 {
                showErrorMessage(nil, "無法取得\(m_DDKind?.m_lbFirstRowTitle.text ?? "")")
                return
            }
        }
        
        m_curDropDownView = sender
        let actionSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle:nil)
        if m_curDropDownView == m_DDType {
            typeCodeList.forEach{ title in actionSheet.addButton(withTitle: title["ACTTYPE"] ?? "")}
        }
        else if m_curDropDownView == m_DDKind {
            if let item = typeItemList[m_DDType?.getContentByType(.First) ?? ""] {
                for dic in item {
                    if let name = dic["PAYTYPE"], let code = dic["PAYCODE"] {
                        actionSheet.addButton(withTitle: code+"-"+name)
                    }
                }
            }
        }
        else if m_curDropDownView == m_DDAccount {
            accountList?.forEach{index in actionSheet.addButton(withTitle: index.accountNO)}
        }
        
        actionSheet.show(in: view)
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet.cancelButtonIndex != buttonIndex {
            if m_curDropDownView == m_DDType {
                typeCodeIndex = buttonIndex-1
                initInputForType(curType)
                typeItemIndex = nil
                m_DDKind?.setOneRow(TaxPayment_Kind_Title, Choose_Title)
            }
            else if m_curDropDownView == m_DDKind {
                typeItemIndex = buttonIndex-1
                if let list = typeItemList[m_DDType?.getContentByType(.First) ?? ""] {
                    if let type = list[typeItemIndex!]["TYPE"] {
                        curType = type
                        initInputForType(curType)
                    }
                }
            }
            m_curDropDownView?.setOneRow((m_curDropDownView?.m_lbFirstRowTitle.text)!, actionSheet.buttonTitle(at: buttonIndex)!)
        }
        m_curDropDownView = nil
    }
    
    private func payTax(_ taskList:[VTask], _ taskID:String) {
        var task:VTask? = nil
        for info in taskList {
            if info.taskID == taskID {
                task = info
                break
            }
        }
        
        if task != nil, let data = task?.message.data(using: .utf8) {
            do {
                let jsonDic = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                
                let OUTACT = (jsonDic?["OUTACT"] as? String) ?? ""
                let ACTTYPECODE = (jsonDic?["ACTTYPECODE"] as? String) ?? ""
                let ACTTYPE = (jsonDic?["ACTTYPE"] as? String) ?? ""
                let PAYTYPECODE = (jsonDic?["PAYTYPECODE"] as? String) ?? ""
                let PAYTYPE = (jsonDic?["PAYTYPE"] as? String) ?? ""
                let TXAMT = (jsonDic?["TXAMT"] as? String) ?? ""
                let TYPE = (jsonDic?["TYPE"] as? String) ?? ""
                
                if TYPE == TaxPayment_Type1  {
                    let CORP = (jsonDic?["CORP"] as? String) ?? ""
                    let IDNO = (jsonDic?["IDNO"] as? String) ?? ""
                    
                    let confirmRequest = RequestStruct(strMethod: "PAY/PAY0103", strSessionDescription: "PAY0103", httpBody: nil, loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false)
                    
                    var dataConfirm = ConfirmOTPStruct(image: ImageName.CowCheck.rawValue, title: Check_Transaction_Title, list: [[String:String]](), memo: "", confirmBtnName: "確認送出", resultBtnName: "繼續交易", checkRequest: confirmRequest, httpBodyList: ["WorkCode":"05001","Operate":"ConfirmTxn","TransactionId":transactionId,"ACTTYPECODE":ACTTYPECODE,"ACTTYPE":ACTTYPE,"PAYTYPECODE":PAYTYPECODE,"PAYTYPE":PAYTYPE,"TYPE":TYPE,"OUTACT":OUTACT,"CORP":CORP,"IDNO":IDNO,"TXAMT":TXAMT,"taskId":taskID,"otp":""],task: task)
                    
                    dataConfirm.list?.append([Response_Key: "繳稅總類", Response_Value:ACTTYPE])
                    dataConfirm.list?.append([Response_Key: "繳稅類別", Response_Value:PAYTYPECODE+"-"+PAYTYPE])
                    dataConfirm.list?.append([Response_Key: "轉出帳號", Response_Value:OUTACT])
                    dataConfirm.list?.append([Response_Key: "機關代號", Response_Value:CORP])
                    dataConfirm.list?.append([Response_Key: "身分證號碼", Response_Value:IDNO])
                    dataConfirm.list?.append([Response_Key: "繳納金額", Response_Value:TXAMT.separatorThousand()])
                    
                    enterConfirmOTPController(dataConfirm, true)
                }
                else {
                    let BILLNO = (jsonDic?["BILLNO"] as? String) ?? ""
                    let DATELINE = (jsonDic?["DATELINE"] as? String) ?? ""
                    
                    let confirmRequest = RequestStruct(strMethod: "PAY/PAY0105", strSessionDescription: "PAY0105", httpBody: nil, loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false)
                    
                    var dataConfirm = ConfirmOTPStruct(image: ImageName.CowCheck.rawValue, title: Check_Transaction_Title, list: [[String:String]](), memo: "", confirmBtnName: "確認送出", resultBtnName: "繼續交易", checkRequest: confirmRequest, httpBodyList: ["WorkCode":"05001","Operate":"ConfirmTxn","TransactionId":transactionId,"ACTTYPECODE":ACTTYPECODE,"ACTTYPE":ACTTYPE,"PAYTYPECODE":PAYTYPECODE,"PAYTYPE":PAYTYPE,"TYPE":TYPE,"OUTACT":OUTACT,"BILLNO":BILLNO,"DATELINE":DATELINE,"TXAMT":TXAMT,"taskId":taskID,"otp":""],task: task)
                    
                    dataConfirm.list?.append([Response_Key: "繳稅總類", Response_Value:ACTTYPE])
                    dataConfirm.list?.append([Response_Key: "繳稅類別", Response_Value:PAYTYPE])
                    dataConfirm.list?.append([Response_Key: "轉出帳號", Response_Value:OUTACT])
                    dataConfirm.list?.append([Response_Key: "銷帳編號", Response_Value:BILLNO])
                    dataConfirm.list?.append([Response_Key: "繳費期限", Response_Value:DATELINE])
                    dataConfirm.list?.append([Response_Key: "繳納金額", Response_Value:TXAMT.separatorThousand()])
                    
                    enterConfirmOTPController(dataConfirm, true)
                }
            }
            catch {
                showErrorMessage(nil, error.localizedDescription)
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == m_tfInput2 && curType == TaxPayment_Type2 {
            if let dateView = getUIByID(.UIID_DatePickerView) as? DatePickerView {
                dateView.frame = view.frame
                dateView.frame.origin = .zero
                dateView.showOneDatePickerView(true, nil) {  end in
                    self.endDate = "\(end.year)\(end.month)\(end.day)"
                    self.m_tfInput2.text = "\(end.year)/\(end.month)/\(end.day)"
                }
                view.addSubview(dateView)
            }
            return false
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.characters.count)! - range.length + string.characters.count
        if textField == m_tfInput2 && curType == TaxPayment_Type1 {
            if newLength > Max_Identify_Length {
                return false
            }
        }
        return true
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func m_btnSendClick(_ sender: Any) {
        if inputIsCorrect() {
            setLoading(true)
            let ACTTYPECODE = typeCodeList[typeCodeIndex!]["ACTTYPECODE"] ?? ""
            let ACTTYPE = typeCodeList[typeCodeIndex!]["ACTTYPE"] ?? ""
            let PAYTYPE = typeItemList[ACTTYPE]?[typeItemIndex!]["PAYTYPE"] ?? ""
            let PAYTYPECODE = typeItemList[ACTTYPE]?[typeItemIndex!]["PAYCODE"] ?? ""
            if curType == TaxPayment_Type1 {
                postRequest("PAY/PAY0102", "PAY0102", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"05001","Operate":"dataConfirm","TransactionId":transactionId,"ACTTYPECODE":ACTTYPECODE,"ACTTYPE":ACTTYPE,"PAYTYPECODE":PAYTYPECODE,"PAYTYPE":PAYTYPE,"TYPE":curType,"OUTACT":m_DDAccount?.getContentByType(.First) ?? "","CORP":m_tfInput1.text!,"IDNO":m_tfInput2.text!.uppercased(),"TXAMT":m_tfInput3.text!], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else {
                postRequest("PAY/PAY0104", "PAY0104", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"05001","Operate":"dataConfirm","TransactionId":transactionId,"ACTTYPECODE":ACTTYPECODE,"ACTTYPE":ACTTYPE,"PAYTYPECODE":PAYTYPECODE,"PAYTYPE":PAYTYPE,"TYPE":curType,"OUTACT":m_DDAccount?.getContentByType(.First) ?? "","BILLNO":m_tfInput1.text!,"DATELINE":endDate,"TXAMT":m_tfInput3.text!], true), AuthorizationManage.manage.getHttpHead(true))
            }
        }
    }
}
