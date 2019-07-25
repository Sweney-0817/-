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
    @IBOutlet var m_wvMemo: UIWebView!
    @IBOutlet var m_consMemoHeight: NSLayoutConstraint!
    @IBOutlet var m_btnConfirm: UIButton!
    @IBOutlet var m_vButtonView: UIView!
    var m_uiActView : TwoRowDropDownView? = nil

    var m_strInputAmount : String = ""
    var m_dicDecrypt : [String:String]? = nil//[String:String]()
    var m_aryShowData : [[String:String]] = [[String:String]]()
    var m_arrActList : [AccountStruct] = [AccountStruct]()//[[String:String]] = [[String:String]]()

    private var m_strType : String = ""
    private var m_qrpInfo : MWQRPTransactionInfo? = nil
    private var m_taxInfo : PayTax? = nil
    private var m_strTempOrderNumber : String = ""
    private var m_strTitle: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        self.makeActView()
        self.initTableView()
        self.addObserverToKeyBoard()
        self.addGestureForKeyBoard()
        self.setShadowView(m_vButtonView)
        self.makeShowData()
//        self.checkBtnConfirm()
        self.send_getActList()
        self.send_QueryData()
    }

    override func viewDidAppear(_ animated: Bool) {
        m_consScanResultHeight.constant = 0
        for item:[String:String] in m_aryShowData {
            let height = ResultCell.GetStringHeightByWidthAndFontSize(item[Response_Value]!, m_tvScanResult.frame.size.width)
            m_consScanResultHeight.constant += height
        }
        if (m_strTitle != nil) {
            navigationController?.navigationBar.topItem?.title = m_strTitle
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
// MARK:- Init Methods
    func setData(type : String,  qrp : MWQRPTransactionInfo?, tax : PayTax?, transactionId : String, secure : [String:String]?) {
        m_strType = type
        m_qrpInfo = qrp
        m_taxInfo = tax
        self.transactionId = transactionId
        m_dicDecrypt = secure
        m_strTitle = m_strType == "02" ? "掃描轉帳" : "台灣Pay"
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
            for actInfo in m_arrActList {
                actSheet.addButton(withTitle: actInfo.accountNO)
            }
            actSheet.tag = ViewTag.View_AccountActionSheet.rawValue
            actSheet.show(in: view)
        }
        else {
            showErrorMessage(nil, ErrorMsg_GetList_InCommonAccount)
        }
    }
// MARK:- Logic Methods
    func checkInput() -> Bool {
        if (m_uiActView?.getContentByType(.First) == Choose_Title) {
            showAlert(title: UIAlert_Default_Title, msg: "請選擇帳戶", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
            return false
        }
        if (m_strInputAmount.isEmpty == true) {
            showAlert(title: UIAlert_Default_Title, msg: "請輸入金額", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
            return false
        }
        if (Int(m_strInputAmount) == 0) {
            showAlert(title: UIAlert_Default_Title, msg: ErrorMsg_Input_Amount, confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
            return false
        }
        if (Int(m_strInputAmount) == 0) {
            showAlert(title: UIAlert_Default_Title, msg: "輸入金額不得小於0元", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
            return false
        }
        if (m_strType == "02" && m_qrpInfo?.txnAmt() == nil && Int(m_strInputAmount)! > 30000) {
            showAlert(title: UIAlert_Default_Title, msg: ErrorMsg_NotPredesignated_Amount, confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
            return false
        }
        return true
    }
    func checkBtnConfirm() {
        if ((m_uiActView?.getContentByType(.First) != Choose_Title) &&
            (m_strInputAmount.isEmpty == false) &&
            Int(m_strInputAmount)! > 0) {
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
    //====== 處理掃完頁的顯示
    private func makeShowData() {
        m_aryShowData.removeAll()
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
//        m_consScanResultHeight.constant = CGFloat(60 * m_aryShowData.count)
        m_tvScanResult.reloadData()
    }
    private func makePurchaseData() {
        var temp : [String:String] = [String:String]()
        
//        temp[Response_Key] = "類別"
//        temp[Response_Value] = "消費購物"
//        m_aryShowData.append(temp)

        if ((m_qrpInfo?.merchantName()) != nil) {
            temp[Response_Key] = "商店名稱"
            temp[Response_Value] = m_qrpInfo?.merchantName()
            temp[Response_Type] = "N"
            m_aryShowData.append(temp)
        }

        if ((m_qrpInfo?.merchantId()) != nil) {
            temp[Response_Key] = "特店代號"
            temp[Response_Value] = m_qrpInfo?.merchantId()
            temp[Response_Type] = "N"
            m_aryShowData.append(temp)
        }

        // 購物轉帳(51) - 轉入帳號
        if (m_strType == "51") {
            if ((m_qrpInfo?.transfereeAccountForPurchasing()) != nil) {
                temp[Response_Key] = "轉入帳號"
                temp[Response_Value] = m_qrpInfo?.transfereeAccountForPurchasing()
                temp[Response_Type] = self.checkType("11")
                m_aryShowData.append(temp)
            }
        }

        if ((m_qrpInfo?.orderNumber()) != nil) {
            temp[Response_Key] = "訂單編號"
            temp[Response_Value] = m_qrpInfo?.orderNumber()
            temp[Response_Type] = self.checkType("2")
            m_aryShowData.append(temp)
        }
//        else if (m_dicDecrypt["E2"] != nil) {
//            temp[Response_Key] = "訂單編號"
//            temp[Response_Value] = m_dicDecrypt["E2"]
//            temp[Response_Type] = "E"
//            m_aryShowData.append(temp)
//        }
        else {
            temp[Response_Key] = "訂單編號"
            temp[Response_Value] = createOrderNumber()
            temp[Response_Type] = self.checkType("2")
            m_aryShowData.append(temp)
        }

//        if (m_qrpInfo?.txnCurrencyCode() == nil) {
            temp[Response_Key] = "金額"
//        }
//        else {
//            temp[Response_Key] = "金額" + ((m_qrpInfo?.txnCurrencyCode())! == "901" ? "(新臺幣)" : String(format: "(%@)", (m_qrpInfo?.txnCurrencyCode())!))
//        }
        if (m_qrpInfo?.txnAmt() == nil) {
            temp[Response_Value] = ""
            m_strInputAmount = ""
        }
        else {
            let showAmt: String = (m_qrpInfo?.txnAmt()?.substring(to: (m_qrpInfo?.txnAmt().count)! - 3).separatorThousandDecimal())!
            let strAmt: String = (m_qrpInfo?.txnAmt()?.substring(to: (m_qrpInfo?.txnAmt().count)! - 3).separatorDecimal())!
//            let showAmt: String = (m_qrpInfo?.txnAmt().substring(to: (m_qrpInfo?.txnAmt().count)! - 3))! + "." + (m_qrpInfo?.txnAmt().substring(from: (m_qrpInfo?.txnAmt().count)! - 2))!
//            let strAmt: String = (m_qrpInfo?.txnAmt().substring(to: (m_qrpInfo?.txnAmt().count)! - 3))!
            temp[Response_Value] = showAmt
            m_strInputAmount = strAmt
        }
        temp[Response_Type] = self.checkType("1")
        m_aryShowData.append(temp)

        //同登打頁(若不含金額會加在最後)
        //01 追加 "儲存於手機條碼"
    }
    private func makeP2PTransferData() {
        var temp : [String:String] = [String:String]()
        
        temp[Response_Key] = "類別"
        temp[Response_Value] = "轉帳"
        m_aryShowData.append(temp)
        
//        if ((m_qrpInfo?.merchantName()) != nil) {
//            temp[Response_Key] = "名稱"
//            temp[Response_Value] = m_qrpInfo?.merchantName()
//            temp[Response_Type] = "N"
//            m_aryShowData.append(temp)
//        }
        if ((m_qrpInfo?.transfereeBank()) != nil) {
            temp[Response_Key] = "銀行代碼"
            temp[Response_Value] = m_qrpInfo?.transfereeBank()
            temp[Response_Type] = self.checkType("5")
            m_aryShowData.append(temp)
        }
        if ((m_qrpInfo?.transfereeAccount()) != nil) {
            temp[Response_Key] = "轉入帳號"
            temp[Response_Value] = m_qrpInfo?.transfereeAccount()
            temp[Response_Type] = self.checkType("6")
            m_aryShowData.append(temp)
        }
        //        if ((m_qrpInfo?.txnAmt()) != nil) {
//        if (m_qrpInfo?.txnCurrencyCode() == nil) {
            temp[Response_Key] = "金額"
//        }
//        else {
//            temp[Response_Key] = "金額" + (m_qrpInfo?.txnCurrencyCode())! == "901" ? "(新臺幣)" : String(format: "(%@)", (m_qrpInfo?.txnCurrencyCode())!)
//        }
        if (m_qrpInfo?.txnAmt() == nil) {
            temp[Response_Value] = ""
            m_strInputAmount = ""
        }
        else {
            let showAmt: String = (m_qrpInfo?.txnAmt()?.substring(to: (m_qrpInfo?.txnAmt().count)! - 3).separatorThousandDecimal())!
            let strAmt: String = (m_qrpInfo?.txnAmt()?.substring(to: (m_qrpInfo?.txnAmt().count)! - 3).separatorDecimal())!
//            let showAmt: String = (m_qrpInfo?.txnAmt().substring(to: (m_qrpInfo?.txnAmt().count)! - 3))! + "." + (m_qrpInfo?.txnAmt().substring(from: (m_qrpInfo?.txnAmt().count)! - 2))!
//            let strAmt: String = (m_qrpInfo?.txnAmt().substring(to: (m_qrpInfo?.txnAmt().count)! - 3))!
            temp[Response_Value] = showAmt
            m_strInputAmount = strAmt
        }
//        if (m_qrpInfo?.txnAmt() == nil) {
//            temp[Response_Value] = ""
//            m_strInputAmount = ""
//        }
//        else {
//            let strAmt: String = (m_qrpInfo?.txnAmt()?.substring(to: (m_qrpInfo?.txnAmt().count)! - 3).separatorDecimal())!
////            let strAmt: String = (m_qrpInfo?.txnAmt().substring(to: (m_qrpInfo?.txnAmt().count)! - 3))!
//            temp[Response_Value] = strAmt
//            m_strInputAmount = strAmt
//        }
        temp[Response_Type] = self.checkType("1")
        m_aryShowData.append(temp)

//        if ((m_qrpInfo?.note()) != nil) {
//            temp[Response_Key] = "備註"
//            temp[Response_Value] = m_qrpInfo?.note()
//            temp[Response_Type] = self.checkType("9")
//            m_aryShowData.append(temp)
//        }
    }
    private func makeBillData() {
        var temp : [String:String] = [String:String]()
        
//        temp[Response_Key] = "類別"
//        temp[Response_Value] = "繳費"
//        m_aryShowData.append(temp)
        
        if ((m_qrpInfo?.feeName()) != nil) {
            temp[Response_Key] = "費用名稱"
            if (m_qrpInfo?.feeName() == m_qrpInfo?.merchantName()) {
                temp[Response_Value] = m_qrpInfo?.feeName()
            }
            else {
                temp[Response_Value] = (m_qrpInfo?.merchantName() ?? "") + " " + (m_qrpInfo?.feeName())!
            }
            temp[Response_Type] = self.checkType("16")
            m_aryShowData.append(temp)
        }
        else if ((m_qrpInfo?.feeInfo()) != nil) {
            let arrInfo : [String]? = (m_qrpInfo?.feeInfo().components(separatedBy: ","))
            var fName : String = ""
            if (arrInfo != nil && arrInfo!.count > 0 ) {
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
                else if (arrInfo![0] == "4") {
                    fName = "瓦斯費"
                }
                else if (arrInfo![0] == "5") {
                    fName = "中華電信費"
                }
                else {
                    fName = "繳費"
                }
            }
            temp[Response_Key] = "費用名稱"
            if (fName == m_qrpInfo?.merchantName()) {
                temp[Response_Value] = fName
            }
            else {
                temp[Response_Value] = (m_qrpInfo?.merchantName() ?? "") + " " + fName
            }
            temp[Response_Type] = self.checkType("14")
            m_aryShowData.append(temp)
        }
        else if ((m_qrpInfo?.merchantName()) != nil) {
            temp[Response_Key] = "費用名稱"
            temp[Response_Value] = m_qrpInfo?.merchantName()
            temp[Response_Type] = "N"
            m_aryShowData.append(temp)
        }
        if ((m_qrpInfo?.deadlinefinal()) != nil) {
            temp[Response_Key] = "繳費期限"
            if ((m_qrpInfo?.deadlinefinal()?.count)! < 8) {
                let deadline: String = "\(Int((m_qrpInfo?.deadlinefinal()!)!)! + 20110000)".dateFormatter(form: dataDateFormat, to: showDateFormat)
                temp[Response_Value] = deadline
            }
            else {
                temp[Response_Value] = m_qrpInfo?.deadlinefinal()?.dateFormatter(form: dataDateFormat, to: showDateFormat)
            }
            temp[Response_Type] = self.checkType("4")
            m_aryShowData.append(temp)
        }
        if ((m_qrpInfo?.noticeNbr()) != nil) {
            temp[Response_Key] = "銷帳編號"
            temp[Response_Value] = m_qrpInfo?.noticeNbr()
            temp[Response_Type] = self.checkType("7")
            m_aryShowData.append(temp)
        }
        else if (m_dicDecrypt != nil && m_dicDecrypt!["E7"] != nil) {
            temp[Response_Key] = "銷帳編號"
            temp[Response_Value] = (m_dicDecrypt!["E7"]! as NSString).replacingCharacters(in: NSRange(location: 3, length: 3), with: "***")
            temp[Response_Type] = "E"
            m_aryShowData.append(temp)
        }
        //        if ((m_qrpInfo?.txnAmt()) != nil) {
//        if (m_qrpInfo?.txnCurrencyCode() == nil) {
            temp[Response_Key] = "金額"
//        }
//        else {
//            temp[Response_Key] = "金額" + (m_qrpInfo?.txnCurrencyCode())! == "901" ? "(新臺幣)" : String(format: "(%@)", (m_qrpInfo?.txnCurrencyCode())!)
//        }
        if (m_qrpInfo?.txnAmt() == nil) {
            temp[Response_Value] = ""
            m_strInputAmount = ""
        }
        else {
            let showAmt: String = (m_qrpInfo?.txnAmt()?.substring(to: (m_qrpInfo?.txnAmt().count)! - 3).separatorThousandDecimal())!
            let strAmt: String = (m_qrpInfo?.txnAmt()?.substring(to: (m_qrpInfo?.txnAmt().count)! - 3).separatorDecimal())!
//            let showAmt: String = (m_qrpInfo?.txnAmt().substring(to: (m_qrpInfo?.txnAmt().count)! - 3))! + "." + (m_qrpInfo?.txnAmt().substring(from: (m_qrpInfo?.txnAmt().count)! - 2))!
//            let strAmt: String = (m_qrpInfo?.txnAmt().substring(to: (m_qrpInfo?.txnAmt().count)! - 3))!
            temp[Response_Value] = showAmt
            m_strInputAmount = strAmt
        }
        temp[Response_Type] = self.checkType("1")
        m_aryShowData.append(temp)
        if ((m_qrpInfo?.charge()) != nil) {
//            if ((m_qrpInfo?.acqBank() == "007" && m_qrpInfo?.feeInfo() != nil) ||
//                (m_qrpInfo?.acqBank() != "007")) {
                temp[Response_Key] = "使用者支付手續費"
            temp[Response_Value] = (m_qrpInfo?.charge()?.substring(to: (m_qrpInfo?.charge().count)! - 3).separatorThousandDecimal())!
                temp[Response_Type] = self.checkType("15")
                m_aryShowData.append(temp)
//            }
        }
    }
    private func makePayTaxType11Data() {
        var temp : [String:String] = [String:String]()
        
        temp[Response_Key] = "類別"
        temp[Response_Value] = "繳稅11"
        m_aryShowData.append(temp)
        
        if ((m_taxInfo?.taxType) != nil) {
            temp[Response_Key] = PayTax_Type11_ShowTitle[0]
            temp[Response_Value] = m_taxInfo?.taxType
            temp[Response_Type] = "N"
            m_aryShowData.append(temp)
        }
        if ((m_taxInfo?.number) != nil) {
            temp[Response_Key] = PayTax_Type11_ShowTitle[1]
            temp[Response_Value] = m_taxInfo?.number
            temp[Response_Type] = "N"
            m_aryShowData.append(temp)
        }
        if ((m_taxInfo?.amount) != nil) {
            temp[Response_Key] = PayTax_Type11_ShowTitle[2]
            temp[Response_Value] = m_taxInfo?.amount
            temp[Response_Type] = "N"
            m_aryShowData.append(temp)
            m_strInputAmount = m_taxInfo?.amount ?? ""
        }
        if ((m_taxInfo?.deadLine) != nil) {
            temp[Response_Key] = PayTax_Type11_ShowTitle[3]
            temp[Response_Value] = m_taxInfo?.deadLine
            temp[Response_Type] = "N"
            m_aryShowData.append(temp)
        }
        if ((m_taxInfo?.periodCode) != nil) {
            temp[Response_Key] = PayTax_Type11_ShowTitle[4]
            temp[Response_Value] = m_taxInfo?.periodCode
            temp[Response_Type] = "N"
            m_aryShowData.append(temp)
        }
        //同登打頁 ＋ PayTax_Type11_Confirm_AddShowTitle
    }
    private func makePayTaxType15Data() {
        var temp : [String:String] = [String:String]()
        
        temp[Response_Key] = "類別"
        temp[Response_Value] = "繳稅15"
        m_aryShowData.append(temp)
        
        if ((m_taxInfo?.taxType) != nil) {
            temp[Response_Key] = PayTax_Type15_ShowTitle[0]
            temp[Response_Value] = m_taxInfo?.taxType
            temp[Response_Type] = "N"
            m_aryShowData.append(temp)
        }
        if ((m_taxInfo?.m_strPayTaxYear) != nil) {
            temp[Response_Key] = PayTax_Type15_ShowTitle[1]
            temp[Response_Value] = m_taxInfo?.m_strPayTaxYear
            temp[Response_Type] = "N"
            m_aryShowData.append(temp)
        }
        m_strInputAmount = "-"
        //同登打頁 ＋ PayTax_Type15_Confirm_AddShowTitle
    }
    //====== 處理確認頁的顯示
    private func makePurchaseConfirmShowData(_ data: [String:String]) -> [[String:String]] {
        var list: [[String:String]] = [[String:String]]()
        var item: [String:String] = [String:String]()
        item[Response_Key] = "轉出帳號"
        item[Response_Value] = m_uiActView?.getContentByType(.First)
        list.append(item)
        if (m_strType == "51") {
            if (data["merchantName"] != nil && data["merchantName"]!.isEmpty != true) {
                item[Response_Key] = "商店名稱"
                item[Response_Value] = data["merchantName"]
                list.append(item)
            }
        }
        else if (m_strType == "01") {
            if (data["merchant"] != nil && data["merchant"]!.isEmpty != true) {
                item[Response_Key] = "商店名稱"
                item[Response_Value] = data["merchant"]
                list.append(item)
            }
        }
        
        if (data["merchantId"] != nil && data["merchantId"]!.isEmpty != true) {
            item[Response_Key] = "特店代號"
            item[Response_Value] = data["merchantId"]
            list.append(item)
        }
        
        // 購物轉帳(51) - 轉入帳號
        if (m_strType == "51") {
            if (data["INACT"] != nil && data["INACT"]!.isEmpty != true) {
                item[Response_Key] = "轉入帳號"
                item[Response_Value] = data["INACT"]
                list.append(item)
            }
        }
        if (m_strType == "51") {
            if (data["orderNumber"] != nil && data["orderNumber"]!.isEmpty != true) {
                item[Response_Key] = "訂單編號"
                item[Response_Value] = data["orderNumber"]
                list.append(item)
            }
        }
        else if (m_strType == "01") {
            if (data["orderNbr"] != nil && data["orderNbr"]!.isEmpty != true) {
                item[Response_Key] = "訂單編號"
                item[Response_Value] = data["orderNbr"]
                list.append(item)
            }
        }
        
        if (m_strType == "51") {
            item[Response_Key] = "金額"
            item[Response_Value] = data["TXAMT"]!.substring(to: data["TXAMT"]!.count - 3).separatorThousandDecimal()
            list.append(item)
        }
        else if (m_strType == "01") {
            item[Response_Key] = "金額"
            item[Response_Value] = data["txnAmt"]!.substring(to: data["txnAmt"]!.count - 3).separatorThousandDecimal()
            list.append(item)
        }

        return list
    }
    private func makeBillConfirmShowData(_ data: [String:String]) -> [[String:String]] {
        var list: [[String:String]] = [[String:String]]()
        var item: [String:String] = [String:String]()
        item[Response_Key] = "轉出帳號"
        item[Response_Value] = m_uiActView?.getContentByType(.First)
        list.append(item)
        if (data["feeName"] != nil && data["feeName"]!.isEmpty != true) {
            item[Response_Key] = "費用名稱"
            if (data["feeName"] == data["merchant"]) {
                item[Response_Value] = data["feeName"]
            }
            else {
                item[Response_Value] = (data["merchant"] ?? "") + " " + (data["feeName"])!
            }
            list.append(item)
        }
        else if (data["feeInfo"] != nil && data["feeInfo"]!.isEmpty != true) {
            let arrInfo : [String]? = (data["feeInfo"]!.components(separatedBy: ","))
            var fName : String = ""
            if (arrInfo != nil && arrInfo!.count > 0 ) {
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
                else if (arrInfo![0] == "4") {
                    fName = "瓦斯費"
                }
                else if (arrInfo![0] == "5") {
                    fName = "中華電信費"
                }
                else {
                    fName = "繳費"
                }
            }
            item[Response_Key] = "費用名稱"
            if (fName == data["merchant"]) {
                item[Response_Value] = fName
            }
            else {
                item[Response_Value] = (data["merchant"] ?? "") + " " + fName
            }
            list.append(item)
        }
        else if (data["merchant"] != nil && data["merchant"]!.isEmpty != true) {
            item[Response_Key] = "費用名稱"
            item[Response_Value] = data["merchant"]
            list.append(item)
        }
        if (data["deadlinefinal"] != nil && data["deadlinefinal"]!.isEmpty != true) {
            item[Response_Key] = "繳費期限"
            if (data["deadlinefinal"]!.count < 8) {
                let deadline: String = "\(Int(data["deadlinefinal"]!)! + 20110000)".dateFormatter(form: dataDateFormat, to: showDateFormat)
                item[Response_Value] = deadline
            }
            else {
                item[Response_Value] = data["deadlinefinal"]!.dateFormatter(form: dataDateFormat, to: showDateFormat)
            }
            list.append(item)
        }
        if (data["noticeNbr"] != nil && data["noticeNbr"]!.isEmpty != true) {
            item[Response_Key] = "銷帳編號"
            item[Response_Value] = data["noticeNbr"]
            list.append(item)
        }
        item[Response_Key] = "金額"
        item[Response_Value] = data["txnAmt"]!.substring(to: data["txnAmt"]!.count - 3).separatorThousandDecimal()
        list.append(item)
        if (data["charge"] != nil) {
            item[Response_Key] = "使用者支付手續費"
            item[Response_Value] = data["charge"]!.substring(to: data["charge"]!.count - 3).separatorThousandDecimal()
            list.append(item)
        }

        return list
    }
    //====== 處理確認頁的電文
    private func makeConfirmData() {
        var data: [String:String]? = nil
        switch m_strType {
        case "01":
            data = makePurchaseConfirmData()
            send_PurchaseConfirm(data!)
        case "02":
            data = makeP2PTransferConfirmData()
            send_P2PTransfer(data!)
        case "03":
            data = makeBillConfirmData()
            send_BillConfirm(data!)
        case "51":
            data = makeTransPurchaseConfirmData()
            send_TransPurchaseConfirm(data!)
        case PayTax_Type11_Type:
            makePayTaxType11ConfirmData()
        case PayTax_Type15_Type:
            makePayTaxType15ConfirmData()
        default:
            break
        }
    }
    private func makePurchaseConfirmData() -> [String:String] {
        var body: [String:String] = [String:String]()
        body["WorkCode"] = "09004"
        body["Operate"] = "dataConfirm"
        body["TransactionId"] = transactionId
        //金融卡帳號
        body["cardNumber"] = m_uiActView?.getContentByType(.First)
        //交易金額
        body["txnAmt"] = m_strInputAmount + "00"
        //訂單編號
        if ((m_qrpInfo?.orderNumber()) != nil) {
            body["orderNbr"] = m_qrpInfo?.orderNumber()
        }
        else {
            body["orderNbr"] = createOrderNumber()
        }
        //收單行代碼
        if (m_qrpInfo?.acqBank() != nil) {
            body["acqBank"] = m_qrpInfo?.acqBank()
        }
        //端末代號
        if (m_qrpInfo?.terminalId() != nil) {
            body["terminalId"] = m_qrpInfo?.terminalId()
        }
        //特店代號
        if ((m_qrpInfo?.merchantId()) != nil) {
            body["merchantId"] = m_qrpInfo?.merchantId()
        }
        //特店名稱
        if ((m_qrpInfo?.merchantName()) != nil) {
            body["merchant"] = m_qrpInfo?.merchantName()
        }
        //前端應用軟體代號
        body["appId"] = AgriBank_AppID
        //幣別碼
        if ((m_qrpInfo?.txnCurrencyCode()) != nil) {
            body["txnCurrencyCode"] = m_qrpInfo?.txnCurrencyCode()
        }
        //支付工具型態欄位
        if (m_qrpInfo?.paymentType() != nil) {
            body["paymentType"] = m_qrpInfo?.paymentType()
//            if (m_qrpInfo?.paymentType() == "00" || m_qrpInfo?.paymentType() == "01") {
//                body["processingCode"] = "2541"
//            }
//            else if (m_qrpInfo?.paymentType() == "02") {
//                body["processingCode"] = "2525"
//            }
        }
        //國別碼
        if ((m_qrpInfo?.countryCode()) != nil) {
            body["countryCode"] = m_qrpInfo?.countryCode()
        }
        return body
    }
    private func makeTransPurchaseConfirmData() -> [String:String] {
        var body: [String:String] = [String:String]()
        body["WorkCode"] = "09003"
        body["Operate"] = "dataConfirm"
        body["TransactionId"] = transactionId
        //轉出帳號
        body["CARDACTNO"] = m_uiActView?.getContentByType(.First)
        //轉入帳號
        if (m_strType == "51" && (m_qrpInfo?.transfereeAccountForPurchasing()) != nil) {
            body["INACT"] = m_qrpInfo?.transfereeAccountForPurchasing()
        }
        //轉入銀行代碼
        if (m_strType == "51" && (m_qrpInfo?.transfereeBankForPurchasing()) != nil) {
            body["INBANK"] = m_qrpInfo?.transfereeBankForPurchasing()
        }
        else if (m_qrpInfo?.acqBank() != nil) {
            body["INBANK"] = m_qrpInfo?.acqBank()
        }
        //轉帳金額
        body["TXAMT"] = String(Int(m_strInputAmount) ?? 0) + "00"
        //特店名稱
        if ((m_qrpInfo?.merchantName()) != nil) {
            body["merchantName"] = m_qrpInfo?.merchantName()
        }
        //特店代號
        if ((m_qrpInfo?.merchantId()) != nil) {
            body["merchantId"] = m_qrpInfo?.merchantId()
        }
        //訂單編號
        if ((m_qrpInfo?.orderNumber()) != nil) {
            body["orderNumber"] = m_qrpInfo?.orderNumber()
        }
        else {
            body["orderNumber"] = createOrderNumber()
        }
        return body
    }
    private func makeP2PTransferConfirmData() -> [String:String]  {
        var body: [String:String] = [String:String]()
        body["WorkCode"] = "09007"
        body["Operate"] = "dataConfirm"
        body["TransactionId"] = transactionId
        body["CARDACTNO"] = m_uiActView?.getContentByType(.First)
        body["INACT"] = m_qrpInfo?.transfereeAccount()
        body["INBANK"] = m_qrpInfo?.transfereeBank()
        body["TXAMT"] = String(Int(m_strInputAmount) ?? 0)
        body["TXMEMO"] = ""//"P2P轉帳"
        body["MAIL"] = ""
        return body
    }
    private func makeBillConfirmData() -> [String:String]  {
        var body: [String:String] = [String:String]()
        body["WorkCode"] = "09005"
        body["Operate"] = "dataConfirm"
        body["TransactionId"] = transactionId
        //金融卡帳號
        body["cardNumber"] = m_uiActView?.getContentByType(.First)
        //交易金額
        body["txnAmt"] = m_strInputAmount + "00"
        //訂單編號
        if ((m_qrpInfo?.orderNumber()) != nil) {
            body["orderNbr"] = m_qrpInfo?.orderNumber()
        }
        else {
            body["orderNbr"] = createOrderNumber()
        }
        //收單行代碼
        if (m_qrpInfo?.acqBank() != nil) {
            body["acqBank"] = m_qrpInfo?.acqBank()
        }
        //端末代號
        if (m_qrpInfo?.terminalId() != nil) {
            body["terminalId"] = m_qrpInfo?.terminalId()
        }
        //特店代號
        if ((m_qrpInfo?.merchantId()) != nil) {
            body["merchantId"] = m_qrpInfo?.merchantId()
        }
        //特店名稱
        if ((m_qrpInfo?.merchantName()) != nil) {
            body["merchant"] = m_qrpInfo?.merchantName()
        }
        //前端應用軟體代號
        body["appId"] = AgriBank_AppID
        //幣別碼
        if ((m_qrpInfo?.txnCurrencyCode()) != nil) {
            body["txnCurrencyCode"] = m_qrpInfo?.txnCurrencyCode()
        }
        //支付工具型態欄位
        if (m_qrpInfo?.paymentType() != nil) {
            body["paymentType"] = m_qrpInfo?.paymentType()
//            if (m_qrpInfo?.paymentType() == "00" || m_qrpInfo?.paymentType() == "01") {
//                body["processingCode"] = "2541"
//            }
//            else if (m_qrpInfo?.paymentType() == "02") {
//                body["processingCode"] = "2525"
//            }
        }
        //國別碼
        if ((m_qrpInfo?.countryCode()) != nil) {
            body["countryCode"] = m_qrpInfo?.countryCode()
        }
        //繳費期限(截止日)
        if ((m_qrpInfo?.deadlinefinal()) != nil) {
            body["deadlinefinal"] = m_qrpInfo?.deadlinefinal()
        }
        //銷帳編號
        if ((m_qrpInfo?.noticeNbr()) != nil) {
            body["noticeNbr"] = m_qrpInfo?.noticeNbr()
        }
        else if (m_dicDecrypt != nil && m_dicDecrypt!["E7"] != nil) {
            body["noticeNbr"] = m_dicDecrypt!["E7"]!
        }

        //費用資訊
//        if ((m_qrpInfo?.feeInfo()) != nil) {
            body["feeInfo"] = m_qrpInfo?.feeInfo() ?? ""
//        }
        //費用名稱
//        if ((m_qrpInfo?.feeName()) != nil) {
//            body["feeName"] = m_qrpInfo?.feeName()
//        }
        if ((m_qrpInfo?.feeName()) != nil) {
            body["feeName"] = m_qrpInfo?.feeName()
        }
        else if ((m_qrpInfo?.feeInfo()) != nil) {
            let arrInfo : [String]? = (m_qrpInfo?.feeInfo().components(separatedBy: ","))
            var fName : String = ""
            if (arrInfo != nil && arrInfo!.count > 0 ) {
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
                else if (arrInfo![0] == "4") {
                    fName = "瓦斯費"
                }
                else if (arrInfo![0] == "5") {
                    fName = "中華電信費"
                }
                else {
                    fName = "繳費"
                }
            }
            body["feeName"] = fName
        }
        //使用者支付手續費
        if ((m_qrpInfo?.charge()) != nil) {
            body["charge"] = m_qrpInfo?.charge()
        }
        return body
    }
    private func makePayTaxType11ConfirmData() {
        
    }
    private func makePayTaxType15ConfirmData() {
        
    }
    private func createOrderNumber() -> String {
        if (m_strTempOrderNumber.isEmpty == false) {
            return m_strTempOrderNumber
        }
        let subOrderNumber1: String = (m_qrpInfo?.merchantId().substring(from: 10))!
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyyMMddHHmmss"
        let subOrderNumber2: String = fmt.string(from: Date())
        m_strTempOrderNumber = subOrderNumber1 + subOrderNumber2
        return m_strTempOrderNumber
    }
    private func transNonPredesignated(_ taskList:[VTask], _ taskID:String) {
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
                
                let confirmRequest = RequestStruct(strMethod: "QR/QR0702", strSessionDescription: "QR0702", httpBody: nil, loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false, timeOut: TIME_OUT_125)
                
                let CARDACTNO = (jsonDic?["CARDACTNO"] as? String) ?? ""
                let INACT = (jsonDic?["INACT"] as? String) ?? ""
                let INBANK = (jsonDic?["INBANK"] as? String) ?? ""
                let TXAMT = (jsonDic?["TXAMT"] as? String) ?? ""
                let TXMEMO = (jsonDic?["TXMEMO"] as? String) ?? ""
                let MAIL = (jsonDic?["MAIL"] as? String) ?? ""
                
                var dataConfirm = ConfirmOTPStruct(image: ImageName.CowCheck.rawValue, title: Check_Transaction_Title, list: [[String:String]](), memo: "", confirmBtnName: "確認送出", resultBtnName: "繼續交易", checkRequest: confirmRequest, httpBodyList: ["WorkCode":"09007","Operate":"dataConfirm","TransactionId":transactionId,"CARDACTNO":CARDACTNO,"INACT":INACT,"INBANK":INBANK,"TXAMT":TXAMT,"TXMEMO":TXMEMO,"MAIL":MAIL,"taskId":taskID,"otp":""],task: task)
                
                dataConfirm.list?.append([Response_Key: "類別", Response_Value:"轉帳"])
                dataConfirm.list?.append([Response_Key: "轉出帳號", Response_Value:CARDACTNO])
                dataConfirm.list?.append([Response_Key: "銀行代碼", Response_Value:INBANK])
                dataConfirm.list?.append([Response_Key: "轉入帳號", Response_Value:INACT])
                dataConfirm.list?.append([Response_Key: "金額", Response_Value:TXAMT.separatorThousandDecimal()])
//                dataConfirm.list?.append([Response_Key: "備註/交易備記", Response_Value:TXMEMO])
//                dataConfirm.list?.append([Response_Key: "受款人E-mail", Response_Value:MAIL])
                
                enterConfirmOTPController(dataConfirm, true, "掃描轉帳")
            }
            catch {
                showErrorMessage(nil, error.localizedDescription)
            }
        }
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
                
                switch m_strType {
                case "01":
                    let confirmRequest = RequestStruct(strMethod: "QR/QR0402", strSessionDescription: "QR0402", httpBody: nil, loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false, timeOut: TIME_OUT_125)

                    var data : [String:String] = [String:String]()
                    data["WorkCode"] = "09004"
                    data["Operate"] = "commitTxn"
                    data["TransactionId"] = (jsonDic?["TransactionId"] as? String) ?? ""
                    data["cardNumber"] = (jsonDic?["cardNumber"] as? String) ?? ""
                    data["txnAmt"] = (jsonDic?["txnAmt"] as? String) ?? ""
                    data["orderNbr"] = (jsonDic?["orderNbr"] as? String) ?? ""
                    data["acqBank"] = (jsonDic?["acqBank"] as? String) ?? ""
                    data["terminalId"] = (jsonDic?["terminalId"] as? String) ?? ""
                    data["merchantId"] = (jsonDic?["merchantId"] as? String) ?? ""
                    data["merchant"] = (jsonDic?["merchant"] as? String) ?? ""
                    data["appId"] = (jsonDic?["appId"] as? String) ?? ""
                    data["txnCurrencyCode"] = (jsonDic?["txnCurrencyCode"] as? String) ?? ""
                    data["paymentType"] = (jsonDic?["paymentType"] as? String) ?? ""
                    data["countryCode"] = (jsonDic?["countryCode"] as? String) ?? ""
                    data["taskId"] = taskID
                    data["otp"] = (jsonDic?["otp"] as? String) ?? ""
                    
                    var dataConfirm = ConfirmOTPStruct(image: ImageName.CowCheck.rawValue, title: Check_Transaction_Title, list: [[String:String]](), memo: "", confirmBtnName: "確認送出", resultBtnName: "繼續交易", checkRequest: confirmRequest, httpBodyList:data, task: task)

//                    dataConfirm.list?.append([Response_Key: "商店名稱", Response_Value:data["merchant"]!])
//                    dataConfirm.list?.append([Response_Key: "特店代號", Response_Value:data["merchantId"]!])
//                    dataConfirm.list?.append([Response_Key: "訂單編號", Response_Value:data["orderNbr"]!])
//                    let showAmt: String = (data["txnAmt"]!.substring(to: (data["txnAmt"]!.count) - 3).separatorThousandDecimal())
//                    dataConfirm.list?.append([Response_Key: "金額", Response_Value:showAmt])
                    dataConfirm.list = makePurchaseConfirmShowData(data)
                    enterConfirmOTPController(dataConfirm, true, "台灣Pay")
                case "02":
                    break
                case "03":
                    let confirmRequest = RequestStruct(strMethod: "QR/QR0502", strSessionDescription: "QR0502", httpBody: nil, loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false, timeOut: TIME_OUT_125)

                    var data : [String:String] = [String:String]()
                    data["WorkCode"] = "09005"
                    data["Operate"] = "commitTxn"
                    data["TransactionId"] = (jsonDic?["TransactionId"] as? String) ?? ""
                    data["cardNumber"] = (jsonDic?["cardNumber"] as? String) ?? ""
                    data["txnAmt"] = (jsonDic?["txnAmt"] as? String) ?? ""
                    data["orderNbr"] = (jsonDic?["orderNbr"] as? String) ?? ""
                    data["acqBank"] = (jsonDic?["acqBank"] as? String) ?? ""
                    data["terminalId"] = (jsonDic?["terminalId"] as? String) ?? ""
                    data["merchantId"] = (jsonDic?["merchantId"] as? String) ?? ""
                    data["merchant"] = (jsonDic?["merchant"] as? String) ?? ""
                    data["appId"] = (jsonDic?["appId"] as? String) ?? ""
                    data["txnCurrencyCode"] = (jsonDic?["txnCurrencyCode"] as? String) ?? ""
                    data["paymentType"] = (jsonDic?["paymentType"] as? String) ?? ""
                    data["countryCode"] = (jsonDic?["countryCode"] as? String) ?? ""
                    data["deadlinefinal"] = (jsonDic?["deadlinefinal"] as? String) ?? ""
                    data["noticeNbr"] = (jsonDic?["noticeNbr"] as? String) ?? ""
                    data["feeInfo"] = (jsonDic?["feeInfo"] as? String) ?? ""
                    data["feeName"] = (jsonDic?["feeName"] as? String) ?? ""
                    data["charge"] = (jsonDic?["charge"] as? String) ?? ""
                    data["taskId"] = taskID
                    data["otp"] = (jsonDic?["otp"] as? String) ?? ""
                    var dataConfirm = ConfirmOTPStruct(image: ImageName.CowCheck.rawValue, title: Check_Transaction_Title, list: [[String:String]](), memo: "", confirmBtnName: "確認送出", resultBtnName: "繼續交易", checkRequest: confirmRequest, httpBodyList:data, task: task)
                    dataConfirm.list = makeBillConfirmShowData(data)
                    enterConfirmOTPController(dataConfirm, true, "台灣Pay")
                case "51":
                    let confirmRequest = RequestStruct(strMethod: "QR/QR0302", strSessionDescription: "QR0302", httpBody: nil, loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false, timeOut: TIME_OUT_125)
                    
                    var data : [String:String] = [String:String]()
                    data["WorkCode"] = "09003"
                    data["Operate"] = "commitTxn"
                    data["TransactionId"] = (jsonDic?["TransactionId"] as? String) ?? ""
                    data["CARDACTNO"] = (jsonDic?["CARDACTNO"] as? String) ?? ""
                    data["INACT"] = (jsonDic?["INACT"] as? String) ?? ""
                    data["INBANK"] = (jsonDic?["INBANK"] as? String) ?? ""
                    data["TXAMT"] = (jsonDic?["TXAMT"] as? String) ?? ""
                    data["merchantName"] = (jsonDic?["merchantName"] as? String) ?? ""
                    data["merchantId"] = (jsonDic?["merchantId"] as? String) ?? ""
                    data["orderNumber"] = (jsonDic?["orderNumber"] as? String) ?? ""
                    data["taskId"] = taskID
                    data["otp"] = (jsonDic?["otp"] as? String) ?? ""
                    
                    var dataConfirm = ConfirmOTPStruct(image: ImageName.CowCheck.rawValue, title: Check_Transaction_Title, list: [[String:String]](), memo: "", confirmBtnName: "確認送出", resultBtnName: "繼續交易", checkRequest: confirmRequest, httpBodyList:data, task: task)
                    dataConfirm.list = makePurchaseConfirmShowData(data)
//                    dataConfirm.list?.append([Response_Key: "商店名稱", Response_Value:data["merchantName"]!])
//                    dataConfirm.list?.append([Response_Key: "特店代號", Response_Value:data["merchantId"]!])
//                    dataConfirm.list?.append([Response_Key: "轉入帳號", Response_Value:data["INACT"]!])
//                    dataConfirm.list?.append([Response_Key: "訂單編號", Response_Value:data["orderNumber"]!])
//                    let showAmt: String = (data["TXAMT"]!.substring(to: (data["TXAMT"]!.count) - 3).separatorThousandDecimal())
//                    dataConfirm.list?.append([Response_Key: "金額", Response_Value:showAmt])
                    enterConfirmOTPController(dataConfirm, true, "台灣Pay")
                case PayTax_Type11_Type:
//                    makePayTaxType11Data()
                    break
                case PayTax_Type15_Type:
//                    makePayTaxType15Data()
                    break
                default:
                    break
                }
                
                

            }
            catch {
                showErrorMessage(nil, error.localizedDescription)
            }
        }
    }
    // MARK:- Handle Actions
    @IBAction func m_btnConfirmClick(_ sender: Any) {
        dismissKeyboard()
        guard self.checkInput() else {
            return
        }
        NSLog("Input[%@]", m_strInputAmount)
        makeConfirmData()
    }
    // MARK:- WebService Methods
    private func makeFakeData() {
        m_arrActList.removeAll()
        for i in 0..<20 {
            var actInfo: AccountStruct = AccountStruct()
            actInfo.accountNO = String.init(format: "%05d", i)
            actInfo.currency = "TWNTD"
            actInfo.balance = String.init(format: "%d", i*1000+100)
            actInfo.status = "?"
            m_arrActList.append(actInfo)
        }
    }
    func send_getActList() {
        self.setLoading(true)
//        self.makeFakeData()
        postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
    }
    func send_QueryData() {
        self.setLoading(true)
        var type: String = ""
        switch m_strType {
        case "51":// 轉帳購貨:T
            type = "T"
        case "01":// 消費扣款:C
            type = "C"
        case "02":// P2P轉帳:Q
            type = "Q"
        case "03":// 繳費:P
            type = "P"
        default:
            type = ""
        }
        postRequest("QR/QR0601", "QR0601", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"09006","Operate":"queryData","Type":type], true), AuthorizationManage.manage.getHttpHead(true))
    }
    
    private func send_PurchaseConfirm(_ data:[String:String]) {
        setLoading(true)
        postRequest("QR/QR0401", "QR0401", AuthorizationManage.manage.converInputToHttpBody(data, true), AuthorizationManage.manage.getHttpHead(true))
    }
    private func send_TransPurchaseConfirm(_ data:[String:String]) {
        setLoading(true)
        postRequest("QR/QR0301", "QR0301", AuthorizationManage.manage.converInputToHttpBody(data, true), AuthorizationManage.manage.getHttpHead(true))
    }
    private func send_P2PTransfer(_ data:[String:String]) {
        setLoading(true)
        postRequest("QR/QR0701", "QR0701", AuthorizationManage.manage.converInputToHttpBody(data, true), AuthorizationManage.manage.getHttpHead(true))
    }
    private func send_BillConfirm(_ data:[String:String]) {
        setLoading(true)
        postRequest("QR/QR0501", "QR0501", AuthorizationManage.manage.converInputToHttpBody2(data, true), AuthorizationManage.manage.getHttpHead(true))
    }

    override func didResponse(_ description:String, _ response: NSDictionary) {
        self.setLoading(false)
        switch description {
        case "ACCT0101":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]]{
                for category in array {
                    if let type = category["ACTTYPE"] as? String, let result = category["AccountInfo"] as? [[String:Any]], type == Account_Saving_Type {
                        m_arrActList.removeAll()
                        for actInfo in result {
                            if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? String, let ebkfg = actInfo["EBKFG"] as? String, ebkfg == Account_EnableTrans {
                                m_arrActList.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
                            }
                        }
                    }
                }
            }
            else {
                super.didResponse(description, response)
            }
        case "QR0301":
//            self.enterConfirmView([VTask](), "test ID")
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let Id = data["taskId"] as? String {
                VaktenManager.sharedInstance().getTasksOperation{ resultCode, tasks  in
                    if VIsSuccessful(resultCode) && tasks != nil {
                        self.enterConfirmView(tasks! as! [VTask], Id)
                    }
                    else {
                        self.showErrorMessage(nil, "\(ErrorMsg_GetTasks_Faild) \(resultCode.rawValue)")
                    }
                }
            }
            else {
                showErrorMessage(nil, ErrorMsg_No_TaskId)
            }
        case "QR0401":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let Id = data["taskId"] as? String {
                VaktenManager.sharedInstance().getTasksOperation{ resultCode, tasks  in
                    if VIsSuccessful(resultCode) && tasks != nil {
                        self.enterConfirmView(tasks! as! [VTask], Id)
                    }
                    else {
                        self.showErrorMessage(nil, "\(ErrorMsg_GetTasks_Faild) \(resultCode.rawValue)")
                    }
                }
            }
            else {
                showErrorMessage(nil, ErrorMsg_No_TaskId)
            }
        case "QR0501":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let Id = data["taskId"] as? String {
                VaktenManager.sharedInstance().getTasksOperation{ resultCode, tasks  in
                    if VIsSuccessful(resultCode) && tasks != nil {
                        self.enterConfirmView(tasks! as! [VTask], Id)
                    }
                    else {
                        self.showErrorMessage(nil, "\(ErrorMsg_GetTasks_Faild) \(resultCode.rawValue)")
                    }
                }
            }
            else {
                showErrorMessage(nil, ErrorMsg_No_TaskId)
            }
        case "QR0601":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any] {
                let content = data["Content"] as? String
                m_wvMemo.loadHTMLString(content!, baseURL: nil)
            }
        case "QR0701":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let Id = data["taskId"] as? String {
                VaktenManager.sharedInstance().getTasksOperation{ resultCode, tasks  in
                    if VIsSuccessful(resultCode) && tasks != nil {
                        self.transNonPredesignated(tasks! as! [VTask], Id)
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
                let info : AccountStruct = m_arrActList[iIndex]
                let act : String = info.accountNO
                let amount : String = info.balance
                m_uiActView?.setTwoRow(NTTransfer_OutAccount, act, NTTransfer_Balance, amount.separatorThousand())
//                self.checkBtnConfirm()
            default:
                break
            }
        }
    }
}
extension ScanResultViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_aryShowData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (((m_aryShowData[indexPath.row][Response_Key])!.range(of: "金額") != nil) &&
            ((m_aryShowData[indexPath.row][Response_Type] == "M") ||
                (m_aryShowData[indexPath.row][Response_Value]?.isEmpty == true))) {
//            (m_aryShowData[indexPath.row][Response_Value]?.isEmpty == true)) {
            let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultEditCell.NibName()!, for: indexPath) as! ResultEditCell
            cell.set(m_strInputAmount)
            cell.m_tfEditData.delegate = self
            cell.selectionStyle = .none
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell
            cell.set((m_aryShowData[indexPath.row][Response_Key])!, (m_aryShowData[indexPath.row][Response_Value])!)
            cell.selectionStyle = .none
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ResultCell.GetStringHeightByWidthAndFontSize((m_aryShowData[indexPath.row][Response_Value])!, tableView.frame.size.width)
    }
}
extension ScanResultViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        guard DetermineUtility.utility.isAllNumber(newString) else {
            return false
        }
        
        let newLength = (textField.text?.count)! - range.length + string.count
        let maxLength = Max_GetAmount_Length
        if newLength <= maxLength {
            m_strInputAmount = newString
//            self.checkBtnConfirm()
            return true
        }
        else {
            return false
        }
    }
}
extension ScanResultViewController : UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        var frame: CGRect = self.m_wvMemo.frame
        frame.size.height = 1
        self.m_wvMemo.frame = frame
        let fittingSize = self.m_wvMemo.sizeThatFits(CGSize(width: 0, height: 0))
        frame.size = fittingSize
        self.m_wvMemo.frame = frame
        m_consMemoHeight.constant = fittingSize.height
    }
}
