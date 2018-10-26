//
//  GPRegularAccountInfomationViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/8/14.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit
//黃金存摺帳號下的定期申購設定
struct GPSettingData {
    ///投資日(扣款日期)
    var m_strDate: String = ""
    ///投資方式
    var m_strType: String = ""
    ///投資金額 or 基準價格(本行賣出價)
    var m_strAmount: String = ""
    ///暫停訖日
    var m_strStop: String = ""
    ///按鈕title
    var m_strBtn: String = ""
    ///定期不定額明細
    var m_objDiffAmount: DiffAmountDetail? = nil
}
//帶到申請或變更頁面的資訊
struct GPPassData {
//    var m_strDate: String
    var m_accountStruct: AccountStruct
    var m_strTransOutAct: String
    var m_settingData: GPSettingData
}
let sameAmount = "定期定額"
let sameQuantity = "定期定量"
let diffAmount = "定期不定額"
let amountTitle = "投資金額"
let quantityTitle = "投資數量"
let basePrice = "基準價格"
let stopTitle = "暫停訖日"
let diffAmountCommand = "此投資方式請洽臨櫃辦理"
let btnTitleNew = "申請"
let btnTitleChange = "變更"
let btnTitleCheck = "檢視"
class GPRegularAccountInfomationViewController: BaseViewController {
    var m_uiActView: OneRowDropDownView? = nil
    var m_iActIndex: Int = -1
    var m_aryActList: [AccountStruct] = [AccountStruct]()
    var m_aryData: [GPSettingData] = [GPSettingData]()
    var m_iBtnIndex: Int = -1
    var m_uiDiffAmountDetail: GPDiffAmountDetailView? = nil
    
    @IBOutlet var m_vActView: UIView!
    @IBOutlet var m_svContent: UIScrollView!
    @IBOutlet var m_lbCurrency: UILabel!
    @IBOutlet var m_lbTransOutAct: UILabel!
    
    @IBOutlet var m_lbAmountTitle1: UILabel!
    @IBOutlet var m_lbStopTitle1: UILabel!
    @IBOutlet var m_lbDate1: UILabel!
    @IBOutlet var m_lbType1: UILabel!
    @IBOutlet var m_lbAmount1: UILabel!
    @IBOutlet var m_lbStop1: UILabel!
    @IBOutlet var m_consStopHeight1: NSLayoutConstraint!
    @IBOutlet var m_btn1: UIButton!
    
    @IBOutlet var m_lbAmountTitle2: UILabel!
    @IBOutlet var m_lbStopTitle2: UILabel!
    @IBOutlet var m_lbDate2: UILabel!
    @IBOutlet var m_lbType2: UILabel!
    @IBOutlet var m_lbAmount2: UILabel!
    @IBOutlet var m_lbStop2: UILabel!
    @IBOutlet var m_consStopHeight2: NSLayoutConstraint!
    @IBOutlet var m_btn2: UIButton!
    
    @IBOutlet var m_lbAmountTitle3: UILabel!
    @IBOutlet var m_lbStopTitle3: UILabel!
    @IBOutlet var m_lbDate3: UILabel!
    @IBOutlet var m_lbType3: UILabel!
    @IBOutlet var m_lbAmount3: UILabel!
    @IBOutlet var m_lbStop3: UILabel!
    @IBOutlet var m_consStopHeight3: NSLayoutConstraint!
    @IBOutlet var m_btn3: UIButton!

    @IBOutlet var m_lbCommand: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initActView()
        m_svContent.isHidden = true
        getTransactionID("10005", TransactionID_Description)
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
            showErrorMessage(nil, ErrorMsg_GetList_InCommonAccount)
        }
    }
    func clearDate() {
        setDate1(GPSettingData())
        setDate2(GPSettingData())
        setDate3(GPSettingData())
    }
    func setDate1(_ data: GPSettingData) {
        m_lbType1.text = data.m_strType
        m_lbDate1.text = data.m_strDate + "日"
        switch data.m_strType {
        case sameAmount:
            m_lbAmountTitle1.text = amountTitle
            m_lbStopTitle1.text = stopTitle
            m_lbAmount1.text = data.m_strAmount
            m_btn1.setTitle(data.m_strBtn, for: UIControlState.normal)
        case sameQuantity:
            m_lbAmountTitle1.text = quantityTitle
            m_lbStopTitle1.text = stopTitle
            m_lbAmount1.text = data.m_strAmount
            m_btn1.setTitle(data.m_strBtn, for: UIControlState.normal)
        case diffAmount:
            m_lbAmountTitle1.text = basePrice
            m_lbStopTitle1.text = diffAmountCommand
            m_lbAmount1.text = data.m_strAmount
            m_btn1.setTitle(data.m_strBtn, for: UIControlState.normal)
        default:
            m_lbAmountTitle1.text = "-"
            m_lbStopTitle1.text = "-"
            m_lbAmount1.text = "-"
            m_btn1.setTitle("-", for: UIControlState.normal)
        }
        if (data.m_strStop.isEmpty == true && data.m_strType != diffAmount) {
            m_lbStop1.text = ""
            m_consStopHeight1.constant = 0
        }
        else {
            m_lbStop1.text = data.m_strStop
            m_consStopHeight1.constant = 36
        }
    }
    func setDate2(_ data: GPSettingData) {
        m_lbType2.text = data.m_strType
        m_lbDate2.text = data.m_strDate + "日"
        switch data.m_strType {
        case sameAmount:
            m_lbAmountTitle2.text = amountTitle
            m_lbStopTitle2.text = stopTitle
            m_lbAmount2.text = data.m_strAmount
            m_btn2.setTitle(data.m_strBtn, for: UIControlState.normal)
        case sameQuantity:
            m_lbAmountTitle2.text = quantityTitle
            m_lbStopTitle2.text = stopTitle
            m_lbAmount2.text = data.m_strAmount
            m_btn2.setTitle(data.m_strBtn, for: UIControlState.normal)
        case diffAmount:
            m_lbAmountTitle2.text = basePrice
            m_lbStopTitle2.text = diffAmountCommand
            m_lbAmount2.text = data.m_strAmount
            m_btn2.setTitle(data.m_strBtn, for: UIControlState.normal)
        default:
            m_lbAmountTitle2.text = "-"
            m_lbStopTitle2.text = "-"
            m_lbAmount2.text = "-"
            m_btn2.setTitle("-", for: UIControlState.normal)
        }
        if (data.m_strStop.isEmpty == true && data.m_strType != diffAmount) {
            m_lbStop2.text = ""
            m_consStopHeight2.constant = 0
        }
        else {
            m_lbStop2.text = data.m_strStop
            m_consStopHeight2.constant = 36
        }
    }
    func setDate3(_ data: GPSettingData) {
        m_lbType3.text = data.m_strType
        m_lbDate3.text = data.m_strDate + "日"
        switch data.m_strType {
        case sameAmount:
            m_lbAmountTitle3.text = amountTitle
            m_lbStopTitle3.text = stopTitle
            m_lbAmount3.text = data.m_strAmount
            m_btn3.setTitle(data.m_strBtn, for: UIControlState.normal)
        case sameQuantity:
            m_lbAmountTitle3.text = quantityTitle
            m_lbStopTitle3.text = stopTitle
            m_lbAmount3.text = data.m_strAmount
            m_btn3.setTitle(data.m_strBtn, for: UIControlState.normal)
        case diffAmount:
            m_lbAmountTitle3.text = basePrice
            m_lbStopTitle3.text = diffAmountCommand
            m_lbAmount3.text = data.m_strAmount
            m_btn3.setTitle(data.m_strBtn, for: UIControlState.normal)
        default:
            m_lbAmountTitle3.text = "-"
            m_lbStopTitle3.text = "-"
            m_lbAmount3.text = "-"
            m_btn3.setTitle("-", for: UIControlState.normal)
        }
        if (data.m_strStop.isEmpty == true && data.m_strType != diffAmount) {
            m_lbStop3.text = ""
            m_consStopHeight3.constant = 0
        }
        else {
            m_lbStop3.text = data.m_strStop
            m_consStopHeight3.constant = 36
        }
    }
    func showDiffAmountDetail(_ data: GPSettingData) {
        guard data.m_objDiffAmount != nil else {
            return
        }
        if m_uiDiffAmountDetail == nil {
            m_uiDiffAmountDetail = getUIByID(.UIID_GPDiffAmountDetailView) as? GPDiffAmountDetailView
            m_uiDiffAmountDetail?.frame = view.frame
            m_uiDiffAmountDetail?.delegate = self
            m_uiDiffAmountDetail?.setData(data.m_objDiffAmount!)
            view.addSubview(m_uiDiffAmountDetail!)
        }
    }
    // MARK:- Logic Methods
    func processBtnClick(_ data: GPSettingData) {
        switch data.m_strBtn {
        case btnTitleNew:
            if AuthorizationManage.manage.canEnterGold() == false {
                send_getTerms()
            }
            else {
                performSegue(withIdentifier: "showBuy", sender: data)
            }
        case btnTitleChange:
            if AuthorizationManage.manage.canEnterGold() == false {
                send_getTerms()
            }
            else {
                performSegue(withIdentifier: "showChange", sender: data)
            }
        case btnTitleCheck:
            self.showDiffAmountDetail(data)
        default:
            break
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let data: GPSettingData = sender as! GPSettingData
        let passData: GPPassData = GPPassData(m_accountStruct: m_aryActList[m_iActIndex], m_strTransOutAct: self.m_lbTransOutAct.text!, m_settingData: data)
        super.prepare(for: segue, sender: sender)
        switch segue.identifier {
        case "showBuy":
            let controller = segue.destination as! GPRegularSubscriptionViewController
            controller.setData(passData)
        case "showChange":
            let controller = segue.destination as! GPRegularChangeViewController
            controller.setData(passData)
        case "showAcceptRules":
            let controller = segue.destination as! GPAcceptRulesViewController
            var dicData: [String:Any] = [String:Any]()
            dicData["nextStep"] = data.m_strBtn == btnTitleNew ? "showBuy" : "showChange"
            dicData["data"] = passData
            controller.m_dicData = dicData
        default:
            return
        }
    }
    // MARK:- WebService Methods
    private func makeFakeAct() {
        m_aryActList.removeAll()
        for i in 0..<20 {
            let actNO = String.init(format: "%05d", i)
            let curcd = "TWD"
            let bal = String.init(format: "%dg", i*100+10)
            m_aryActList.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ""))
        }
    }
    private func makeFakeActData() {
        let data0: GPSettingData = GPSettingData(m_strDate: "6日", m_strType: "定期不定額", m_strAmount: "3,000,000", m_strStop: "", m_strBtn: "檢視", m_objDiffAmount: nil)
        let data1: GPSettingData = GPSettingData(m_strDate: "16日", m_strType: "-", m_strAmount: "-", m_strStop: "", m_strBtn: "申請", m_objDiffAmount: nil)
        let data2: GPSettingData = GPSettingData(m_strDate: "26日", m_strType: "定期定額", m_strAmount: "-", m_strStop: "2017/05/30", m_strBtn: "變更", m_objDiffAmount: nil)
        m_aryData.removeAll()
        m_aryData.append(data0)
        m_aryData.append(data1)
        m_aryData.append(data2)
        self.m_lbCurrency.text = "台幣"
        self.m_lbTransOutAct.text = "1234567890"
        self.setDate1(m_aryData[0])
        self.setDate2(m_aryData[1])
        self.setDate3(m_aryData[2])
    }
    func send_getGoldList() {
        self.setLoading(true)
//        self.makeFakeData()
        postRequest("Gold/Gold0201", "Gold0201", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10002","Operate":"getGoldList","TransactionId":transactionId], true), AuthorizationManage.manage.getHttpHead(true))
    }
    func send_getGoldList2() {
        self.setLoading(true)
//        self.makeFakeActData()
        postRequest("Gold/Gold0204", "Gold0204", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10005","Operate":"getGoldList","TransactionId":transactionId], true), AuthorizationManage.manage.getHttpHead(true))
    }
    func send_getTerms() {
        self.setLoading(true)
        self.postRequest("Gold/Gold0101", "Gold0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10001","Operate":"getTerms","TransactionId":tempTransactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
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
        case "Gold0204":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any] {
                self.m_lbTransOutAct.text = data["INVACT"] as? String
                if let result = data["Result"] as? [[String:String]] {
                    m_aryData.removeAll()
                    for date in result {
                        var tempSettingData: GPSettingData = GPSettingData()
                        tempSettingData.m_strDate = date["DAY"]!
                        switch date["TYPE"]! {
                        case "1":
                            tempSettingData.m_strType = sameAmount
                        case "2":
                            tempSettingData.m_strType = sameQuantity
                        case "3":
                            tempSettingData.m_strType = diffAmount
                        default:
                            tempSettingData.m_strType = "-"
                        }
                        if (tempSettingData.m_strType == diffAmount) {
                            tempSettingData.m_strAmount = date["PRICE"]!
                            tempSettingData.m_strBtn = btnTitleCheck
                            
                            var tempDiffAmountDetail: DiffAmountDetail = DiffAmountDetail()
                            tempDiffAmountDetail.m_strDate = date["DAY"]!
                            tempDiffAmountDetail.m_strAmount = date["AMT"]!
                            tempDiffAmountDetail.m_strBasePrice = date["PRICE"]!
                            tempDiffAmountDetail.m_strUp = date["UPER"]!
                            tempDiffAmountDetail.m_strUpAmount = date["USIGN"]! + date["UAMT"]!
                            tempDiffAmountDetail.m_strDown = date["DPER"]!
                            tempDiffAmountDetail.m_strDownAmount = date["DSIGN"]! + date["DAMT"]!
                            tempDiffAmountDetail.m_strAmountUpLimit = date["UCAP"]!
                            tempDiffAmountDetail.m_strAmountDownLimit = date["DCAP"]!
                            tempSettingData.m_objDiffAmount = tempDiffAmountDetail
                        }
                        else if (tempSettingData.m_strType == sameAmount || tempSettingData.m_strType == sameQuantity){
                            tempSettingData.m_strAmount = date["AMT"]!
                            tempSettingData.m_strStop = date["EDAY"]!
                            tempSettingData.m_strBtn = btnTitleChange
                        }
                        else {
                            tempSettingData.m_strAmount = date["AMT"]!
                            tempSettingData.m_strBtn = btnTitleNew
                        }
                        m_aryData.append(tempSettingData)
                    }
                    if (m_aryData.count >= 3) {
                        self.setDate1(m_aryData[0])
                        self.setDate2(m_aryData[1])
                        self.setDate3(m_aryData[2])
                        self.m_svContent.isHidden = false
                    }
                    else {
                        self.showAlert(title: nil, msg: "Gold0204 資料數不足", confirmTitle: "confirm", cancleTitle: "cancel", completionHandler: {()}, cancelHandelr: {()})
                    }
                }
                else {
                    self.clearDate()
                    self.m_svContent.isHidden = true
                }
            }
        case "Gold0101":
            if let data = response.object(forKey: ReturnData_Key) as? [String:String] {
                AuthorizationManage.manage.setGoldAcception(data)
                if (AuthorizationManage.manage.canEnterGold()) {
                    self.processBtnClick(m_aryData[m_iBtnIndex])
                }
                else {
                    performSegue(withIdentifier: "showAcceptRules", sender: m_aryData[m_iBtnIndex])
                }
            }
        default:
            super.didResponse(description, response)
        }
    }
    // MARK:- Handle Actions
    @IBAction func m_btn1Click(_ sender: Any) {
        m_iBtnIndex = 0
        self.processBtnClick(m_aryData[m_iBtnIndex])
    }
    @IBAction func m_btn2Click(_ sender: Any) {
        m_iBtnIndex = 1
        self.processBtnClick(m_aryData[m_iBtnIndex])
    }
    @IBAction func m_btn3Click(_ sender: Any) {
        m_iBtnIndex = 2
        self.processBtnClick(m_aryData[m_iBtnIndex])
    }
    
}
extension GPRegularAccountInfomationViewController : OneRowDropDownViewDelegate {
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
extension GPRegularAccountInfomationViewController : UIActionSheetDelegate {
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet.cancelButtonIndex != buttonIndex {
            switch (actionSheet.tag) {
            case ViewTag.View_AccountActionSheet.rawValue:
                m_iActIndex = buttonIndex - 1
                let actInfo : AccountStruct = m_aryActList[m_iActIndex]
                m_uiActView?.setOneRow(GPAccountTitle, actInfo.accountNO)
                self.m_lbCurrency.text = actInfo.currency
                self.send_getGoldList2()
                self.m_svContent.isHidden = true
            default:
                break
            }
        }
    }
}
extension GPRegularAccountInfomationViewController : GPDiffAmountDetailViewDelegate {
    func clickDiffAmountDetailViewCloseBtn() {
        m_uiDiffAmountDetail?.removeFromSuperview()
        m_uiDiffAmountDetail = nil
    }
}
