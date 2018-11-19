//
//  GPSingleSellViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/7/31.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit

class GPSingleSellViewController: BaseViewController {
    let m_contentViewHeight: CGFloat = 180.0
    let m_sellAllHeight: CGFloat = 43.0
    var m_uiActView: OneRowDropDownView? = nil
    var m_strSellGram: String = "0"
    var m_iActIndex: Int = -1
    var m_bIsSellAll: Bool = false
    var m_aryActList : [AccountStruct] = [AccountStruct]()
    var m_objActInfo : GPActInfo? = nil
    var m_objPriceInfo : GPPriceInfo? = nil
    @IBOutlet var m_vActView: UIView!
    @IBOutlet var m_tvContentView: UITableView!
    @IBOutlet var m_consContentViewHeight: NSLayoutConstraint!
    @IBOutlet var m_vSellAll: UIView!
    @IBOutlet var m_consSellAllHeight: NSLayoutConstraint!
    @IBOutlet var m_btnSellAll: UIButton!
    @IBOutlet var m_btnNext: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initActView()
        self.initTableView()
        self.addGestureForKeyBoard()
        getTransactionID("10006", TransactionID_Description)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Init Methods
    private func initActView() {
        m_uiActView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        m_uiActView?.delegate = self
        m_uiActView?.frame = m_vActView.frame
        m_uiActView?.frame.origin = .zero
        m_uiActView?.setOneRow(GPAccountTitle, Choose_Title)
        m_uiActView?.m_lbFirstRowTitle.textAlignment = .center
        m_vActView.addSubview(m_uiActView!)
        
        setShadowView(m_vActView)
    }
    private func initTableView() {
        m_tvContentView.delegate = self
        m_tvContentView.dataSource = self
        m_tvContentView.register(UINib(nibName: UIID.UIID_ResultCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultCell.NibName()!)
        m_tvContentView.register(UINib(nibName: UIID.UIID_ResultEditCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultEditCell.NibName()!)
        m_tvContentView.allowsSelection = false
        m_tvContentView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        m_tvContentView.isHidden = true
        m_consContentViewHeight.constant = 0
        m_consSellAllHeight.constant = 0
    }
    // MARK:- UI Methods
    func showActList() {
        if (m_aryActList.count > 0) {
            let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
            for actInfo in m_aryActList {
                actSheet.addButton(withTitle: actInfo.accountNO)
            }
            actSheet.tag = ViewTag.View_AccountActionSheet.rawValue
            actSheet.show(in: view)
        }
        else {
            showErrorMessage(nil, ErrorMsg_NoGPAccount)
        }
    }
    // MARK:- Logic Methods
    private func enterConfirmView() {
        guard m_objActInfo != nil && m_objPriceInfo != nil else {
            return
        }
        
        let strPriceTime: String = m_objPriceInfo!.DATE.dateFormatter(form: "yyyyMMdd", to: "yyyy/MM/dd") + " " + m_objPriceInfo!.TIME//牌告時間
        let dBuy: Double = Double(m_objPriceInfo!.BUY.replacingOccurrences(of: ",", with: ""))!
        let totalAmount: String = String(lround(dBuy * Double(m_strSellGram)!))//試算金額
        
        var data : [String:String] = [String:String]()
        data["WorkCode"] = "10006"
        data["Operate"] = "commitTxn"
        data["TransactionId"] = transactionId
        data["REFNO"] = m_aryActList[m_iActIndex].accountNO
        data["MACTNO"] = m_objActInfo!.PAYACT
        data["VALUE"] = m_objPriceInfo!.BUY
        data["CNT"] = m_objPriceInfo!.CNT
        data["AMOUNT"] = m_strSellGram
        data["TXAMT"] = totalAmount
        data["DATE"] = strPriceTime
        let confirmRequest = RequestStruct(strMethod: "Gold/Gold0301", strSessionDescription: "Gold0301", httpBody: AuthorizationManage.manage.converInputToHttpBody2(data, true), loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false, timeOut: REQUEST_TIME_OUT)
        
        var dataConfirm = ConfirmResultStruct(image: ImageName.CowCheck.rawValue, title: Check_Transaction_Title, list: [[String:String]](), memo: "", confirmBtnName: "送出", resultBtnName: "繼續交易", checkRequest: confirmRequest)
        dataConfirm.list?.append([Response_Key: "黃金存摺帳號", Response_Value: m_aryActList[m_iActIndex].accountNO])
        dataConfirm.list?.append([Response_Key: "計價幣別", Response_Value: m_aryActList[m_iActIndex].currency == Currency_TWD ? Currency_TWD_Title:m_aryActList[m_iActIndex].currency])
        dataConfirm.list?.append([Response_Key: "入款帳號", Response_Value: m_objActInfo!.PAYACT])
        dataConfirm.list?.append([Response_Key: "牌告時間", Response_Value: strPriceTime])
        dataConfirm.list?.append([Response_Key: "參考價(1克)", Response_Value: m_objPriceInfo!.BUY.separatorThousand()])
        dataConfirm.list?.append([Response_Key: "回售量(克)", Response_Value: m_bIsSellAll ? m_strSellGram.separatorThousandDecimal() : m_strSellGram.separatorThousand()])
        dataConfirm.list?.append([Response_Key: "試算金額", Response_Value: totalAmount.separatorThousand()])
        enterConfirmResultController(true, dataConfirm, true)
    }
    // MARK:- WebService Methods
    private func makeFakeData() {
        m_aryActList.removeAll()
        for i in 0..<20 {
            let actNO = String.init(format: "%05d", i)
            let curcd = "TWD"
            let bal = String.init(format: "%dg", i*100+10)
            m_aryActList.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ""))
        }
    }
    func send_getGoldList() {
        self.setLoading(true)
//        self.makeFakeData()
        postRequest("Gold/Gold0201", "Gold0201", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10002","Operate":"getGoldList","TransactionId":transactionId], true), AuthorizationManage.manage.getHttpHead(true))
    }
    func send_getGoldAcctInfo(_ act: String) {
        self.setLoading(true)
        postRequest("Gold/Gold0203", "Gold0203", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10004","Operate":"getGoldAcctInfo","TransactionId":transactionId, "REFNO":act], true), AuthorizationManage.manage.getHttpHead(true))
    }
    func send_queryData(){
        self.setLoading(true)
        postRequest("Gold/Gold0502", "Gold0502", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10013","Operate":"queryData"], true), AuthorizationManage.manage.getHttpHead(true))
    }
    override func didResponse(_ description:String, _ response: NSDictionary) {
        self.setLoading(false)
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                self.send_getGoldList()
            }
            else {
                super.didResponse(description, response)
            }
        case "Gold0201":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let result = data["Result"] as? [[String:Any]] {
                m_aryActList.removeAll()
                for actInfo in result {
                    if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? String {
                        m_aryActList.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ""))
                    }
                }
            }
            else {
                showErrorMessage(nil, ErrorMsg_No_TaskId)
            }
        case "Gold0203":
            if let actInfo = response.object(forKey: ReturnData_Key) as? [String:Any] {
                m_objActInfo = GPActInfo(PAYACT: actInfo["PAYACT"]! as! String, AVBAL: actInfo["AVBAL"]! as! String, SCORE: actInfo["SCORE"]! as! String, CREDAY: actInfo["CREDAY"]! as! String)
//                if (m_objActInfo?.CREDAY == "N") {
//                    m_tvContentView.isHidden = true
//                    m_consContentViewHeight.constant = 0
//                    m_consSellAllHeight.constant = 0
//                    m_tvContentView.reloadData()
//                    showAlert(title: nil, msg: "本會依法須定期更新客戶投資風險承受度資訊，以保障客戶權益，貴戶「投資風險屬性評估表」已逾一年有效期限，請速洽本會營業據點或於網路銀行線上填寫上述評估表，即可辦理黃金存摺買進類交易。", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
//                    m_btnNext.isEnabled = false
//                }
//                else {
                    m_tvContentView.isHidden = false
                    m_consContentViewHeight.constant = m_contentViewHeight
                    m_consSellAllHeight.constant = m_sellAllHeight
                    m_tvContentView.reloadData()
//                    m_btnNext.isEnabled = true
//                }
            }
        case "Gold0502":
            if let priceInfo = response.object(forKey: ReturnData_Key) as? [String:String] {
                if (priceInfo["CanTrans"] == Can_Transaction_Status) {
                    m_objPriceInfo = GPPriceInfo(DATE: priceInfo["DATE"]!, TIME: priceInfo["TIME"]!, CNT: priceInfo["CNT"]!, SELL: priceInfo["SELL"]!, BUY: priceInfo["BUY"]!)
                    self.enterConfirmView()
                }
                else {
                    showErrorMessage(nil, ErrorMsg_IsNot_TransTime)
                }
            }
        default:
            super.didResponse(description, response)
        }
    }
    // MARK:- Handle Actions
    @IBAction func m_btnNextClick(_ sender: Any) {
        guard m_iActIndex != -1 else {
            showAlert(title: nil, msg: "請選擇黃金存摺帳號", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
            return
        }
        guard m_strSellGram.isEmpty == false else {
            showAlert(title: nil, msg: "請輸入回售數量", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
            return
        }
        guard Float(m_strSellGram)! > 0.0 else {
            showAlert(title: nil, msg: "回售數量不得0克", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
            return
        }
        self.send_queryData()
    }
    @IBAction func m_btnSellAllClick(_ sender: Any) {
        m_bIsSellAll = !m_bIsSellAll
        m_btnSellAll.isSelected = m_bIsSellAll
        m_strSellGram = m_aryActList[m_iActIndex].balance
        m_tvContentView.reloadData()
    }
}
extension GPSingleSellViewController : OneRowDropDownViewDelegate {
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        self.dismissKeyboard()
        if (m_aryActList.count == 0) {
            self.send_getGoldList()
        }
        else {
            self.showActList()
        }
    }
}
extension GPSingleSellViewController : UIActionSheetDelegate {
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet.cancelButtonIndex != buttonIndex {
            switch (actionSheet.tag) {
            case ViewTag.View_AccountActionSheet.rawValue:
                self.m_iActIndex = buttonIndex - 1
                let actInfo : AccountStruct = m_aryActList[self.m_iActIndex]
                if (actInfo.accountNO != m_uiActView?.getContentByType(.First)) {
                    m_uiActView?.setOneRow(GPAccountTitle, actInfo.accountNO)
                    self.send_getGoldAcctInfo(actInfo.accountNO)
                    m_vSellAll.isHidden = false
                    m_bIsSellAll = false
                    m_btnSellAll.isSelected = m_bIsSellAll
                }
            default:
                m_vSellAll.isHidden = true
                break
            }
        }
    }
}
extension GPSingleSellViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (m_iActIndex != -1 && m_aryActList.count > m_iActIndex) {
            return 3
        }
        else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell
            cell.set("計價幣別", m_aryActList[m_iActIndex].currency == Currency_TWD ? Currency_TWD_Title:m_aryActList[m_iActIndex].currency)
            cell.selectionStyle = .none
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell
            cell.set("入款帳號", m_objActInfo?.PAYACT ?? "")
            cell.selectionStyle = .none
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultEditCell.NibName()!, for: indexPath) as! ResultEditCell
            cell.set("", placeholder: "請輸入回售量(克)")
            cell.m_tfEditData.delegate = self
            cell.selectionStyle = .none
            if (m_bIsSellAll == true) {
                cell.m_tfEditData.isEnabled = false
                cell.m_tfEditData.text = m_aryActList[m_iActIndex].balance
                cell.m_tfEditData.textColor = .gray
                m_strSellGram = m_aryActList[m_iActIndex].balance
            }
            else {
                cell.m_tfEditData.isEnabled = true
                cell.m_tfEditData.text = ""
                cell.m_tfEditData.textColor = .black
                m_strSellGram = ""
            }
            return cell
        default:
            return UITableViewCell()
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
extension GPSingleSellViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        guard DetermineUtility.utility.isAllNumber(newString) else {
            return false
        }
        
        let newLength = (textField.text?.count)! - range.length + string.count
        let maxLength = Max_GoldGram_Length
        if newLength <= maxLength {
            m_strSellGram = newString
            return true
        }
        else {
            return false
        }
    }
}
