//
//  ScanResultViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/7/12.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit

class ScanResultViewController: BaseViewController {
    @IBOutlet var m_vScanResultView: UIView!
    @IBOutlet var m_vActView: UIView!
    @IBOutlet var m_tvScanResult: UITableView!
    @IBOutlet var m_consScanResultHeight: NSLayoutConstraint!
    @IBOutlet var m_btnConfirm: UIButton!
    @IBOutlet var m_vButtonView: UIView!
    var m_uiActView : TwoRowDropDownView? = nil

    var m_strInputAmount : String = ""
    var m_dicDecrypt : [String:String] = [String:String]()
    var m_arrResultData : [[String:String]] = [[String:String]]()
    var m_arrActList : [[String:String]] = [[String:String]]()

    private var m_strType : String = ""
    private var m_qrpInfo : MWQRPTransactionInfo? = nil
    private var m_taxInfo : PayTax? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        self.makeActView()
        self.initTableView()
        self.addObserverToKeyBoard()
        self.addGestureForKeyBoard()
        self.setShadowView(m_vButtonView)
        self.makeShowData()
        self.checkBtnConfirm()
        self.send_getActList()
//        self.getTransactionID("03001", TransactionID_Description)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
// MARK:- Init Methods
    func setData(type : String,  qrp : MWQRPTransactionInfo?, tax : PayTax?) {
        m_strType = type
        m_qrpInfo = qrp
        m_taxInfo = tax
    }
    private func initTableView() {
        m_tvScanResult.register(UINib(nibName: UIID.UIID_ResultCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultCell.NibName()!)
        m_tvScanResult.register(UINib(nibName: UIID.UIID_ResultEditCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultEditCell.NibName()!)
        m_tvScanResult.isScrollEnabled = false
    }
    private func makeActView() {
        m_uiActView = getUIByID(.UIID_TwoRowDropDownView) as? TwoRowDropDownView
        m_uiActView?.setTwoRow(NTTransfer_OutAccount, Choose_Title, NTTransfer_Balance, "")
        m_uiActView?.frame = m_vActView.frame
        m_uiActView?.frame.origin = .zero
        m_uiActView?.delegate = self
        m_vActView.addSubview(m_uiActView!)
        setShadowView(m_vActView)
    }
// MARK:- UI Methods
    func showActList() {
        if (m_arrActList.count > 0) {
            let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
            for info in m_arrActList {
                if let act = info["Act"] {
                    actSheet.addButton(withTitle: act)
                }
            }
            actSheet.tag = ViewTag.View_AccountActionSheet.rawValue
            actSheet.show(in: view)
        }
        else {
            showErrorMessage(nil, ErrorMsg_GetList_InCommonAccount)
        }
    }
// MARK:- Logic Methods
    func checkBtnConfirm() {
        if ((m_uiActView?.getContentByType(.First) != Choose_Title) &&
            (m_strInputAmount.isEmpty == false)) {
            m_btnConfirm.isEnabled = true
        }
        else {
            m_btnConfirm.isEnabled = false
        }
    }
    private func checkType(_ tag : String) -> String {
        var strType : String = "N"
        if (m_qrpInfo?.dTypeDic()[tag] != nil) {
            strType = "D"
        }
        else if (m_qrpInfo?.mTypeDic()[tag] != nil) {
            strType = "M"
        }
        return strType
    }
    private func makeShowData() {
        m_arrResultData.removeAll()
        switch m_strType {
        case "01":
            makePurchaseData()
        case "02":
            makeP2PTransferData()
        case "03":
            makeBillData()
        case "51":
            makePurchaseData()
        case PayTax_Type11_Type:
            makePayTaxType11Data()
        case PayTax_Type15_Type:
            makePayTaxType15Data()
        default:
            break
        }
        m_consScanResultHeight.constant = CGFloat(60 * m_arrResultData.count)
        m_tvScanResult.reloadData()
    }
    private func makePurchaseData() {
        var temp : [String:String] = [String:String]()
        
        temp[Response_Key] = "類別"
        temp[Response_Value] = "消費購物"
        m_arrResultData.append(temp)
        
        if ((m_qrpInfo?.merchantName()) != nil) {
            temp[Response_Key] = "商店名稱"
            temp[Response_Value] = m_qrpInfo?.merchantName()
            temp[Response_Type] = "N"
            m_arrResultData.append(temp)
        }
        if ((m_qrpInfo?.merchantId()) != nil) {
            temp[Response_Key] = "特店代號"
            temp[Response_Value] = m_qrpInfo?.merchantId()
            temp[Response_Type] = "N"
            m_arrResultData.append(temp)
        }
        //        if ((m_qrpInfo?.txnAmt()) != nil) {
        if (m_qrpInfo?.txnCurrencyCode() == nil) {
            temp[Response_Key] = "金額"
        }
        else {
            temp[Response_Key] = "金額" + (m_qrpInfo?.txnCurrencyCode())! == "901" ? "(新臺幣)" : String(format: "(%@)", (m_qrpInfo?.txnCurrencyCode())!)
        }
        temp[Response_Value] = m_qrpInfo?.txnAmt() ?? ""
        m_strInputAmount = m_qrpInfo?.txnAmt() ?? ""
        temp[Response_Type] = self.checkType("1")
        m_arrResultData.append(temp)
        //        }
        // 購物轉帳(51) - 轉入帳號
        if (m_strType == "51") {
            if ((m_qrpInfo?.transfereeAccountForPurchasing()) != nil) {
                temp[Response_Key] = "轉入帳號"
                temp[Response_Value] = m_qrpInfo?.transfereeAccountForPurchasing()
                temp[Response_Type] = self.checkType("11")
                m_arrResultData.append(temp)
            }
        }
        if ((m_qrpInfo?.orderNumber()) != nil) {
            temp[Response_Key] = "訂單編號"
            temp[Response_Value] = m_qrpInfo?.orderNumber()
            temp[Response_Type] = self.checkType("2")
            m_arrResultData.append(temp)
        }
        else if (m_dicDecrypt["E2"] != nil) {
            temp[Response_Key] = "訂單編號"
            temp[Response_Value] = m_dicDecrypt["E2"]
            temp[Response_Type] = "E"
            m_arrResultData.append(temp)
        }
    }
    private func makeP2PTransferData() {
        var temp : [String:String] = [String:String]()
        
        temp[Response_Key] = "類別"
        temp[Response_Value] = "轉帳"
        m_arrResultData.append(temp)
        
        if ((m_qrpInfo?.merchantName()) != nil) {
            temp[Response_Key] = "名稱"
            temp[Response_Value] = m_qrpInfo?.merchantName()
            temp[Response_Type] = "N"
            m_arrResultData.append(temp)
        }
        if ((m_qrpInfo?.transfereeBank()) != nil) {
            temp[Response_Key] = "轉入行代碼"
            temp[Response_Value] = m_qrpInfo?.transfereeBank()
            temp[Response_Type] = self.checkType("5")
            m_arrResultData.append(temp)
        }
        if ((m_qrpInfo?.transfereeAccount()) != nil) {
            temp[Response_Key] = "轉入帳號"
            temp[Response_Value] = m_qrpInfo?.transfereeAccount()
            temp[Response_Type] = self.checkType("6")
            m_arrResultData.append(temp)
        }
        //        if ((m_qrpInfo?.txnAmt()) != nil) {
        if (m_qrpInfo?.txnCurrencyCode() == nil) {
            temp[Response_Key] = "金額"
        }
        else {
            temp[Response_Key] = "金額" + (m_qrpInfo?.txnCurrencyCode())! == "901" ? "(新臺幣)" : String(format: "(%@)", (m_qrpInfo?.txnCurrencyCode())!)
        }
        temp[Response_Value] = m_qrpInfo?.txnAmt() ?? ""
        m_strInputAmount = m_qrpInfo?.txnAmt() ?? ""
        temp[Response_Type] = self.checkType("1")
        m_arrResultData.append(temp)
        //        }
        if ((m_qrpInfo?.note()) != nil) {
            temp[Response_Key] = "備註"
            temp[Response_Value] = m_qrpInfo?.note()
            temp[Response_Type] = self.checkType("9")
            m_arrResultData.append(temp)
        }
    }
    private func makeBillData() {
        var temp : [String:String] = [String:String]()
        
        temp[Response_Key] = "類別"
        temp[Response_Value] = "繳費"
        m_arrResultData.append(temp)
        
        if ((m_qrpInfo?.feeName()) != nil) {
            temp[Response_Key] = "費用名稱"
            temp[Response_Value] = m_qrpInfo?.feeName()
            temp[Response_Type] = self.checkType("16")
            m_arrResultData.append(temp)
        }
        else if ((m_qrpInfo?.feeInfo()) != nil) {
            let arrInfo : [String]? = (m_qrpInfo?.feeInfo().components(separatedBy: ","))
            var fName : String = ""
            if (arrInfo != nil && arrInfo!.count > 1 ) {
                if (arrInfo![0] == "0") {
                    fName = "全國繳費網"
                }
                else if (arrInfo![0] == "1") {
                    fName = "汽燃費"
                }
                else if (arrInfo![0] == "2") {
                    fName = "台灣自來水費"
                }
                else if (arrInfo![0] == "3") {
                    fName = "電費"
                }
                else {
                    fName = "瓦斯費"
                }
            }
            temp[Response_Key] = "費用名稱"
            temp[Response_Value] = fName
            temp[Response_Type] = self.checkType("14")
            m_arrResultData.append(temp)
        }
        else if ((m_qrpInfo?.merchantName()) != nil) {
            temp[Response_Key] = "費用名稱"
            temp[Response_Value] = m_qrpInfo?.merchantName()
            temp[Response_Type] = "N"
            m_arrResultData.append(temp)
        }
        //        if ((m_qrpInfo?.txnAmt()) != nil) {
        if (m_qrpInfo?.txnCurrencyCode() == nil) {
            temp[Response_Key] = "金額"
        }
        else {
            temp[Response_Key] = "金額" + (m_qrpInfo?.txnCurrencyCode())! == "901" ? "(新臺幣)" : String(format: "(%@)", (m_qrpInfo?.txnCurrencyCode())!)
        }
        temp[Response_Value] = m_qrpInfo?.txnAmt() ?? ""
        m_strInputAmount = m_qrpInfo?.txnAmt() ?? ""
        temp[Response_Type] = self.checkType("1")
        m_arrResultData.append(temp)
        //        }
        if ((m_qrpInfo?.noticeNbr()) != nil) {
            temp[Response_Key] = "銷帳編號"
            temp[Response_Value] = m_qrpInfo?.noticeNbr()
            temp[Response_Type] = self.checkType("7")
            m_arrResultData.append(temp)
        }
        else if (m_dicDecrypt["E7"] != nil) {
            temp[Response_Key] = "銷帳編號"
            temp[Response_Value] = m_dicDecrypt["E7"]
            temp[Response_Type] = "E"
            m_arrResultData.append(temp)
        }
        if ((m_qrpInfo?.charge()) != nil) {
            if ((m_qrpInfo?.acqBank() == "007" && m_qrpInfo?.feeInfo() != nil) ||
                (m_qrpInfo?.acqBank() != "007")) {
                temp[Response_Key] = "使用者支付手續費"
                temp[Response_Value] = m_qrpInfo?.charge()
                temp[Response_Type] = self.checkType("15")
                m_arrResultData.append(temp)
            }
        }
        if ((m_qrpInfo?.deadlinefinal()) != nil) {
            temp[Response_Key] = "繳納期限"
            temp[Response_Value] = m_qrpInfo?.deadlinefinal()
            temp[Response_Type] = self.checkType("4")
            m_arrResultData.append(temp)
        }
    }
    private func makePayTaxType11Data() {
        var temp : [String:String] = [String:String]()
        
        temp[Response_Key] = "類別"
        temp[Response_Value] = "繳稅11"
        m_arrResultData.append(temp)
        
        if ((m_taxInfo?.taxType) != nil) {
            temp[Response_Key] = PayTax_Type11_ShowTitle[0]
            temp[Response_Value] = m_taxInfo?.taxType
            temp[Response_Type] = "N"
            m_arrResultData.append(temp)
        }
        if ((m_taxInfo?.number) != nil) {
            temp[Response_Key] = PayTax_Type11_ShowTitle[1]
            temp[Response_Value] = m_taxInfo?.number
            temp[Response_Type] = "N"
            m_arrResultData.append(temp)
        }
        if ((m_taxInfo?.amount) != nil) {
            temp[Response_Key] = PayTax_Type11_ShowTitle[2]
            temp[Response_Value] = m_taxInfo?.amount
            temp[Response_Type] = "N"
            m_arrResultData.append(temp)
            m_strInputAmount = m_taxInfo?.amount ?? ""
        }
        if ((m_taxInfo?.deadLine) != nil) {
            temp[Response_Key] = PayTax_Type11_ShowTitle[3]
            temp[Response_Value] = m_taxInfo?.deadLine
            temp[Response_Type] = "N"
            m_arrResultData.append(temp)
        }
        if ((m_taxInfo?.periodCode) != nil) {
            temp[Response_Key] = PayTax_Type11_ShowTitle[4]
            temp[Response_Value] = m_taxInfo?.periodCode
            temp[Response_Type] = "N"
            m_arrResultData.append(temp)
        }
    }
    private func makePayTaxType15Data() {
        var temp : [String:String] = [String:String]()
        
        temp[Response_Key] = "類別"
        temp[Response_Value] = "繳稅15"
        m_arrResultData.append(temp)
        
        if ((m_taxInfo?.taxType) != nil) {
            temp[Response_Key] = PayTax_Type15_ShowTitle[0]
            temp[Response_Value] = m_taxInfo?.taxType
            temp[Response_Type] = "N"
            m_arrResultData.append(temp)
        }
        if ((m_taxInfo?.m_strPayTaxYear) != nil) {
            temp[Response_Key] = PayTax_Type15_ShowTitle[1]
            temp[Response_Value] = m_taxInfo?.m_strPayTaxYear
            temp[Response_Type] = "N"
            m_arrResultData.append(temp)
        }
        m_strInputAmount = "-"
    }
    private func enterConfirmView(_ taskList:[VTask], _ taskID:String) {
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
                
                let confirmRequest = RequestStruct(strMethod: "TRAN/TRAN0102", strSessionDescription: "TRAN0102", httpBody: nil, loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false, timeOut: TIME_OUT_125)
                
                let CARDACTNO = (jsonDic?["CARDACTNO"] as? String) ?? ""
                let INACT = (jsonDic?["INACT"] as? String) ?? ""
                let INBANK = (jsonDic?["INBANK"] as? String) ?? ""
                let TXAMT = (jsonDic?["TXAMT"] as? String) ?? ""
                let TXMEMO = (jsonDic?["TXMEMO"] as? String) ?? ""
                let MAIL = (jsonDic?["MAIL"] as? String) ?? ""
                
                var dataConfirm = ConfirmOTPStruct(image: ImageName.CowCheck.rawValue, title: Check_Transaction_Title, list: [[String:String]](), memo: "", confirmBtnName: "確認送出", resultBtnName: "繼續交易", checkRequest: confirmRequest, httpBodyList: ["WorkCode":"03001","Operate":"dataConfirm","TransactionId":transactionId,"CARDACTNO":CARDACTNO,"INACT":INACT,"INBANK":INBANK,"TXAMT":TXAMT,"TXMEMO":TXMEMO,"MAIL":MAIL,"taskId":taskID,"otp":""],task: task)
                
//                dataConfirm.list?.append([Response_Key: "轉出帳號", Response_Value:CARDACTNO])
//                dataConfirm.list?.append([Response_Key: "銀行代碼", Response_Value:INBANK])
//                dataConfirm.list?.append([Response_Key: "轉入帳號", Response_Value:INACT])
//                dataConfirm.list?.append([Response_Key: "轉帳金額", Response_Value:TXAMT.separatorThousand()])
//                dataConfirm.list?.append([Response_Key: "備註/交易備記", Response_Value:TXMEMO])
//                dataConfirm.list?.append([Response_Key: "受款人E-mail", Response_Value:MAIL])
                
                enterConfirmOTPController(dataConfirm, true)
            }
            catch {
                showErrorMessage(nil, error.localizedDescription)
            }
        }
    }
    // MARK:- Handle Actions
    @IBAction func m_btnConfirmClick(_ sender: Any) {
        dismissKeyboard()
        NSLog("Input[%@]", m_strInputAmount)
    }
    // MARK:- WebService Methods
    private func makeFakeData() {
        m_arrActList.removeAll()
        var temp : [String:String] = [String:String]()
        for i in 0..<20 {
            temp["Act"] = String.init(format: "%05d", i)
            temp["Amount"] = String.init(format: "%d", i*1000+100)
            m_arrActList.append(temp)
        }
    }
    func send_getActList() {
        self.makeFakeData()
        //        postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
    }
    private func send_confirm() {
        setLoading(true)
//        postRequest("TRAN/TRAN0103", "TRAN0103", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03001","Operate":"dataConfirm","TransactionId":transactionId,"CARDACTNO":m_uiActView?.getContentByType(.First) ?? "---","INACT":"---","INBANK":"---","TXAMT":m_strInputAmount,"TXMEMO":"---","MAIL":"---"], true), AuthorizationManage.manage.getHttpHead(true))
    }
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                setLoading(true)
                self.send_getActList()
            }
            else {
                super.didResponse(description, response)
            }
        case "TRAN0103":
            self.enterConfirmView([VTask](), "test ID")
//            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let Id = data["taskId"] as? String {
//                VaktenManager.sharedInstance().getTasksOperation{ resultCode, tasks  in
//                    if VIsSuccessful(resultCode) && tasks != nil {
//                        self.enterConfirmView(tasks! as! [VTask], Id)
//                    }
//                    else {
//                        self.showErrorMessage(nil, "\(ErrorMsg_GetTasks_Faild) \(resultCode.rawValue)")
//                    }
//                }
//            }
//            else {
//                showErrorMessage(nil, ErrorMsg_No_TaskId)
//            }
        default: super.didResponse(description, response)
        }
    }
}
// MARK:- extension
extension ScanResultViewController : TwoRowDropDownViewDelegate {
    func clickTwoRowDropDownView(_ sender: TwoRowDropDownView) {
        if (m_arrActList.count == 0) {
            self.send_getActList()
        }
        else {
            self.showActList()
        }
    }
}
extension ScanResultViewController : UIActionSheetDelegate {
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet.cancelButtonIndex != buttonIndex {
            switch (actionSheet.tag) {
            case ViewTag.View_AccountActionSheet.rawValue:
                let iIndex : Int = buttonIndex - 1
                let info : [String:String] = m_arrActList[iIndex]
                let act : String = info["Act"]!
                let amount : String = info["Amount"]!
                m_uiActView?.setTwoRow(NTTransfer_OutAccount, act, NTTransfer_Balance, amount)
                self.checkBtnConfirm()
            default:
                break
            }
        }
    }
}
extension ScanResultViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_arrResultData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (((m_arrResultData[indexPath.row][Response_Key])!.range(of: "金額") != nil) &&
            (m_arrResultData[indexPath.row][Response_Value]?.isEmpty == true)) {
            let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultEditCell.NibName()!, for: indexPath) as! ResultEditCell
            cell.set(m_arrResultData[indexPath.row][Response_Key]!, m_strInputAmount)
            cell.m_tfEditData.delegate = self
            cell.selectionStyle = .none
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell
            cell.set((m_arrResultData[indexPath.row][Response_Key])!, (m_arrResultData[indexPath.row][Response_Value])!)
            cell.selectionStyle = .none
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ResultCell.GetStringHeightByWidthAndFontSize((m_arrResultData[indexPath.row][Response_Value])!, tableView.frame.size.width)
    }
}
extension ScanResultViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        guard DetermineUtility.utility.isAllNumber(newString) else {
            return false
        }
        
        let newLength = (textField.text?.count)! - range.length + string.count
        let maxLength = Max_MobliePhone_Length
        if newLength <= maxLength {
            m_strInputAmount = newString
            self.checkBtnConfirm()
            return true
        }
        else {
            return false
        }
    }
}

