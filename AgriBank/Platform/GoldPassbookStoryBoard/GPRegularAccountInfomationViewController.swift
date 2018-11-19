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
    var m_strDAY: String = ""
    ///投資方式
    var m_strTYPE: GPRegularType = .GPRegularTypeDefault
    ///投資金額
    var m_strAMT: String = ""
    ///基準價格(本行賣出價)
    var m_strPRICE: String = ""
    ///暫停起日
    var m_strSDAY: String = ""
    ///暫停訖日
    var m_strEDAY: String = ""
    ///較基準價格上漲
    var m_strUPER: String = ""
    ///增加或減少
    var m_strUSIGN: String = ""
    ///每次投資金額
    var m_strUAMT: String = ""
    ///較基準價格下跌
    var m_strDPER: String = ""
    ///增加或減少
    var m_strDSIGN: String = ""
    ///每次投資金額
    var m_strDAMT: String = ""
    ///每次投資金額上限
    var m_strUCAP: String = ""
    ///每次投資金額下限
    var m_strDCAP: String = ""
    ///投資數量
    var m_strQTY: String = ""
    ///系統時間
    var m_strDATE: String = ""

    ///按鈕title
    var m_strBtn: String = ""
}
//定期交易申請暫停狀態
enum GPPauseStatus: Int {
    case GPPauseStatusBefore //日期在暫停區間前
    case GPPauseStatusIng    //日期在暫停區間中
    case GPPauseStatusAfter  //日期在暫停區間後
    case GPPauseStatusNone   //未申請暫停
}
enum GPRegularType: String {
    case GPRegularTypeDefault = "0"
    case GPRegularTypeSameAmount = "1"
    case GPRegularTypeSameQuantity = "2"
    case GPRegularTypeDiffAmount = "3"
    func getTitle() -> String {
        switch self {
        case .GPRegularTypeSameAmount:
            return "定期定額"
        case .GPRegularTypeSameQuantity:
            return "定期定量"
        case .GPRegularTypeDiffAmount:
            return "定期不定額"
        default:
            return "-"
        }
    }
    func getBtnTitle() -> String {
        switch self {
        case .GPRegularTypeSameAmount:
            return "變更"
        case .GPRegularTypeSameQuantity:
            return "變更"
        case .GPRegularTypeDiffAmount:
            return "檢視"
        default:
            return "申請"
        }
    }
}
//帶到申請或變更頁面的資訊
struct GPPassData {
//    var m_strDate: String
    var m_accountStruct: AccountStruct
    var m_strTransOutAct: String
    var m_settingData: GPSettingData
}
//let sameAmount = "定期定額"
//let sameQuantity = "定期定量"
//let diffAmount = "定期不定額"
let amountTitle = "投資金額"
let quantityTitle = "投資數量"
let basePrice = "基準價格"
let stopTitle = "暫停訖日"
let diffAmountCommand = "此投資方式請洽臨櫃辦理"
//let btnTitleNew = "申請"
//let btnTitleChange = "變更"
//let btnTitleCheck = "檢視"
class GPRegularAccountInfomationViewController: BaseViewController {
    var m_uiActView: OneRowDropDownView? = nil
    var m_iActIndex: Int = -1
    var m_aryActList: [AccountStruct] = [AccountStruct]()
    var m_aryData: [GPSettingData] = [GPSettingData]()
    var m_iBtnIndex: Int = -1
    var m_uiDiffAmountDetail: GPDiffAmountDetailView? = nil
    var m_strActFromAccountInfomation: String? = nil
    var m_strACTCreday: String = "N"
    
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
//        getTransactionID("10002", TransactionID_Description)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getTransactionID("10002", TransactionID_Description)
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
            showErrorMessage(nil, ErrorMsg_NoGPAccount)
        }
    }
    func clearDate() {
        setDate1(GPSettingData())
        setDate2(GPSettingData())
        setDate3(GPSettingData())
    }
    func setDate1(_ data: GPSettingData) {
        m_lbType1.text = data.m_strTYPE.getTitle()
        m_lbDate1.text = data.m_strDAY + "日"
        switch data.m_strTYPE {
        case GPRegularType.GPRegularTypeSameAmount:
            m_lbAmountTitle1.text = amountTitle
            m_lbStopTitle1.text = stopTitle
            m_lbAmount1.text = data.m_strAMT.separatorThousand() == "0" ? "-" : data.m_strAMT.separatorThousand()
            m_btn1.setTitle(data.m_strBtn, for: UIControlState.normal)
        case GPRegularType.GPRegularTypeSameQuantity:
            m_lbAmountTitle1.text = quantityTitle
            m_lbStopTitle1.text = stopTitle
            m_lbAmount1.text = data.m_strQTY.separatorThousand() == "0" ? "-" : data.m_strQTY.separatorThousand()
            m_btn1.setTitle(data.m_strBtn, for: UIControlState.normal)
        case GPRegularType.GPRegularTypeDiffAmount:
            m_lbAmountTitle1.text = basePrice
            m_lbStopTitle1.text = diffAmountCommand
            m_lbAmount1.text = data.m_strAMT.separatorThousand() == "0" ? "-" : data.m_strAMT.separatorThousand()
            m_btn1.setTitle(data.m_strBtn, for: UIControlState.normal)
        default:
            m_lbAmountTitle1.text = "投資金額"
            m_lbStopTitle1.text = "-"
            m_lbAmount1.text = "-"
            m_btn1.setTitle(data.m_strBtn, for: UIControlState.normal)
        }
        //暫停訖日為空，且不為定期不定額，隱藏第四行
        if (data.m_strEDAY == emptyDate && data.m_strTYPE != GPRegularType.GPRegularTypeDiffAmount) {
            m_lbStop1.text = ""
            m_consStopHeight1.constant = 0
        }
        else {
            if(data.m_strTYPE != GPRegularType.GPRegularTypeDiffAmount) {
                m_lbStop1.text = data.m_strEDAY.dateFormatter(form: "yyyyMMdd", to: "yyyy/MM/dd")
            }
            m_consStopHeight1.constant = 36
        }
        //KYC無效且不為定期不定額，按鈕disable
        if ((m_strACTCreday == "N") && data.m_strTYPE != GPRegularType.GPRegularTypeDiffAmount) {
            m_btn1.isEnabled = false
        }
        else {
            m_btn1.isEnabled = true
        }
    }
    func setDate2(_ data: GPSettingData) {
        m_lbType2.text = data.m_strTYPE.getTitle()
        m_lbDate2.text = data.m_strDAY + "日"
        switch data.m_strTYPE {
        case GPRegularType.GPRegularTypeSameAmount:
            m_lbAmountTitle2.text = amountTitle
            m_lbStopTitle2.text = stopTitle
            m_lbAmount2.text = data.m_strAMT.separatorThousand() == "0" ? "-" : data.m_strAMT.separatorThousand()
            m_btn2.setTitle(data.m_strBtn, for: UIControlState.normal)
        case GPRegularType.GPRegularTypeSameQuantity:
            m_lbAmountTitle2.text = quantityTitle
            m_lbStopTitle2.text = stopTitle
            m_lbAmount2.text = data.m_strQTY.separatorThousand() == "0" ? "-" : data.m_strQTY.separatorThousand()
            m_btn2.setTitle(data.m_strBtn, for: UIControlState.normal)
        case GPRegularType.GPRegularTypeDiffAmount:
            m_lbAmountTitle2.text = basePrice
            m_lbStopTitle2.text = diffAmountCommand
            m_lbAmount2.text = data.m_strAMT.separatorThousand() == "0" ? "-" : data.m_strAMT.separatorThousand()
            m_btn2.setTitle(data.m_strBtn, for: UIControlState.normal)
        default:
            m_lbAmountTitle2.text = "投資金額"
            m_lbStopTitle2.text = "-"
            m_lbAmount2.text = "-"
            m_btn2.setTitle(data.m_strBtn, for: UIControlState.normal)
        }
        //暫停訖日為空，且不為定期不定額，隱藏第四行
        if (data.m_strEDAY == emptyDate && data.m_strTYPE != GPRegularType.GPRegularTypeDiffAmount) {
            m_lbStop2.text = ""
            m_consStopHeight2.constant = 0
        }
        else {
            if(data.m_strTYPE != GPRegularType.GPRegularTypeDiffAmount) {
                m_lbStop2.text = data.m_strEDAY.dateFormatter(form: "yyyyMMdd", to: "yyyy/MM/dd")
            }
            m_consStopHeight2.constant = 36
        }
        //KYC無效且不為定期不定額，按鈕disable
        if ((m_strACTCreday == "N") && data.m_strTYPE != GPRegularType.GPRegularTypeDiffAmount) {
            m_btn2.isEnabled = false
        }
        else {
            m_btn2.isEnabled = true
        }
    }
    func setDate3(_ data: GPSettingData) {
        m_lbType3.text = data.m_strTYPE.getTitle()
        m_lbDate3.text = data.m_strDAY + "日"
        switch data.m_strTYPE {
        case GPRegularType.GPRegularTypeSameAmount:
            m_lbAmountTitle3.text = amountTitle
            m_lbStopTitle3.text = stopTitle
            m_lbAmount3.text = data.m_strAMT.separatorThousand() == "0" ? "-" : data.m_strAMT.separatorThousand()
            m_btn3.setTitle(data.m_strBtn, for: UIControlState.normal)
        case GPRegularType.GPRegularTypeSameQuantity:
            m_lbAmountTitle3.text = quantityTitle
            m_lbStopTitle3.text = stopTitle
            m_lbAmount3.text = data.m_strQTY.separatorThousand() == "0" ? "-" : data.m_strQTY.separatorThousand()
            m_btn3.setTitle(data.m_strBtn, for: UIControlState.normal)
        case GPRegularType.GPRegularTypeDiffAmount:
            m_lbAmountTitle3.text = basePrice
            m_lbStopTitle3.text = diffAmountCommand
            m_lbAmount3.text = data.m_strAMT.separatorThousand() == "0" ? "-" : data.m_strAMT.separatorThousand()
            m_btn3.setTitle(data.m_strBtn, for: UIControlState.normal)
        default:
            m_lbAmountTitle3.text = "投資金額"
            m_lbStopTitle3.text = "-"
            m_lbAmount3.text = "-"
            m_btn3.setTitle(data.m_strBtn, for: UIControlState.normal)
        }
        //暫停訖日為空，且不為定期不定額，隱藏第四行
        if (data.m_strEDAY == emptyDate && data.m_strTYPE != GPRegularType.GPRegularTypeDiffAmount) {
            m_lbStop3.text = ""
            m_consStopHeight3.constant = 0
        }
        else {
            if(data.m_strTYPE != GPRegularType.GPRegularTypeDiffAmount) {
                m_lbStop3.text = data.m_strEDAY.dateFormatter(form: "yyyyMMdd", to: "yyyy/MM/dd")
            }
            m_consStopHeight3.constant = 36
        }
        //KYC無效且不為定期不定額，按鈕disable
        if ((m_strACTCreday == "N") && data.m_strTYPE != GPRegularType.GPRegularTypeDiffAmount) {
            m_btn3.isEnabled = false
        }
        else {
            m_btn3.isEnabled = true
        }
    }
    func showDiffAmountDetail(_ data: GPSettingData) {
//        guard data.m_objDiffAmount != nil else {
//            return
//        }
        if m_uiDiffAmountDetail == nil {
            m_uiDiffAmountDetail = getUIByID(.UIID_GPDiffAmountDetailView) as? GPDiffAmountDetailView
            m_uiDiffAmountDetail?.frame = view.frame
            m_uiDiffAmountDetail?.delegate = self
            m_uiDiffAmountDetail?.setData(data)
            view.addSubview(m_uiDiffAmountDetail!)
        }
    }

    // MARK:- Logic Methods
    private func checkActFromAccountInfomation() {
        guard (m_strActFromAccountInfomation != nil) && (m_aryActList.count > 0) else {
            return
        }
        for i in 0..<m_aryActList.count {
            let actInfo: AccountStruct = m_aryActList[i]
            if (m_strActFromAccountInfomation == actInfo.accountNO) {
                m_strActFromAccountInfomation = nil
                m_iActIndex = i
                m_uiActView?.setOneRow(GPAccountTitle, actInfo.accountNO)
                self.m_lbCurrency.text = (actInfo.currency == Currency_TWD) ? Currency_TWD_Title:actInfo.currency
                self.send_getGoldAcctInfo(actInfo.accountNO)
                self.m_svContent.isHidden = true
                return
            }
        }
        NSLog("(定期投資戶總覽)找不到帳號總覽帶來的帳號[%@]", m_strActFromAccountInfomation!)
    }
    func processBtnClick(_ data: GPSettingData) {
        switch data.m_strTYPE {
        case GPRegularType.GPRegularTypeSameAmount:
            send_getTerms()
        case GPRegularType.GPRegularTypeSameQuantity:
            send_getTerms()
        case GPRegularType.GPRegularTypeDiffAmount:
            self.showDiffAmountDetail(data)
        default:
            send_getTerms()
        }
//        switch data.m_strBtn {
//        case btnTitleNew, btnTitleChange :
//            send_getTerms()
//        case btnTitleNew:
//            if AuthorizationManage.manage.canEnterGold() == false {
//                send_getTerms()
//            }
//            else {
//                performSegue(withIdentifier: "showBuy", sender: data)
//            }
//        case btnTitleChange:
//            if AuthorizationManage.manage.canEnterGold() == false {
//                send_getTerms()
//            }
//            else {
//                performSegue(withIdentifier: "showChange", sender: data)
//            }
//        case btnTitleCheck:
//            self.showDiffAmountDetail(data)
//        default:
//            break
//        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let data: GPSettingData = sender as! GPSettingData
        let passData: GPPassData = GPPassData(m_accountStruct: m_aryActList[m_iActIndex], m_strTransOutAct: self.m_lbTransOutAct.text!, m_settingData: data)
        super.prepare(for: segue, sender: sender)
        switch segue.identifier {
        case "showBuy":
            let controller = segue.destination as! GPRegularSubscriptionViewController
            controller.setData(passData)
            controller.transactionId = self.transactionId
        case "showChange":
            let controller = segue.destination as! GPRegularChangeViewController
            controller.setData(passData)
            controller.transactionId = self.transactionId
        case "showAcceptRules":
            let controller = segue.destination as! GPAcceptRulesViewController
            var dicData: [String:Any] = [String:Any]()
//            dicData["nextStep"] = data.m_strBtn == btnTitleNew ? "showBuy" : "showChange"
            switch data.m_strTYPE {
            case GPRegularType.GPRegularTypeSameAmount:
                dicData["nextStep"] = "showChange"
            case GPRegularType.GPRegularTypeSameQuantity:
                dicData["nextStep"] = "showChange"
            case GPRegularType.GPRegularTypeDiffAmount:
                break
            default:
                dicData["nextStep"] = "showBuy"
            }
            dicData["data"] = passData
            controller.m_dicData = dicData
        default:
            return
        }
    }
    // MARK:- WebService Methods
//    private func makeFakeAct() {
//        m_aryActList.removeAll()
//        for i in 0..<20 {
//            let actNO = String.init(format: "%05d", i)
//            let curcd = "TWD"
//            let bal = String.init(format: "%dg", i*100+10)
//            m_aryActList.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ""))
//        }
//    }
//    private func makeFakeActData() {
//        let data0: GPSettingData = GPSettingData(m_strDate: "6日", m_strType: "定期不定額", m_strAmount: "3,000,000", m_strPauseStart: "", m_strPauseEnd: "", m_strBtn: "檢視", m_strToday: "2018/01/01", m_objDiffAmount: nil)
//        let data1: GPSettingData = GPSettingData(m_strDate: "16日", m_strType: "-", m_strAmount: "-", m_strPauseStart: "", m_strPauseEnd: "", m_strBtn: "申請", m_strToday: "2018/01/01", m_objDiffAmount: nil)
//        let data2: GPSettingData = GPSettingData(m_strDate: "26日", m_strType: "定期定額", m_strAmount: "-", m_strPauseStart: "1999/01/01", m_strPauseEnd: "2017/05/30", m_strBtn: "變更", m_strToday: "2018/01/01", m_objDiffAmount: nil)
//        m_aryData.removeAll()
//        m_aryData.append(data0)
//        m_aryData.append(data1)
//        m_aryData.append(data2)
//        self.m_lbCurrency.text = "台幣"
//        self.m_lbTransOutAct.text = "1234567890"
//        self.setDate1(m_aryData[0])
//        self.setDate2(m_aryData[1])
//        self.setDate3(m_aryData[2])
//    }
    func send_getGoldList() {
        self.setLoading(true)
//        self.makeFakeData()
        postRequest("Gold/Gold0201", "Gold0201", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10002","Operate":"getGoldList","TransactionId":transactionId], true), AuthorizationManage.manage.getHttpHead(true))
    }
    func send_getGoldAcctInfo(_ act: String) {
        self.setLoading(true)
        postRequest("Gold/Gold0203", "Gold0203", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10004","Operate":"getGoldAcctInfo","TransactionId":transactionId, "REFNO":act], true), AuthorizationManage.manage.getHttpHead(true))
    }
    func send_getGoldList2(_ act: String) {
        self.setLoading(true)
//        self.makeFakeActData()
        postRequest("Gold/Gold0204", "Gold0204", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10005","Operate":"getGoldList","TransactionId":transactionId, "REFNO":act], true), AuthorizationManage.manage.getHttpHead(true))
    }
    func send_getTerms() {
        self.setLoading(true)
        self.postRequest("Gold/Gold0101", "Gold0101A", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10001","Operate":"getTerms","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
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
                self.checkActFromAccountInfomation()
            }
            else {
                showErrorMessage(nil, ErrorMsg_NoGPAccount)
            }
        case "Gold0203":
            if let actInfo = response.object(forKey: ReturnData_Key) as? [String:Any] {
                m_strACTCreday = actInfo["CREDAY"]! as! String
                self.send_getGoldList2(m_aryActList[m_iActIndex].accountNO)
//                if (m_strACTCreday == "N") {
//                    m_tvContentView.isHidden = true
//                    m_consContentViewHeight.constant = 0
//                    m_consSellAllHeight.constant = 0
//                    m_tvContentView.reloadData()
//                    showAlert(title: nil, msg: "本會依法須定期更新客戶投資風險承受度資訊，以保障客戶權益，貴戶「投資風險屬性評估表」已逾一年有效期限，請速洽本會營業據點或於網路銀行線上填寫上述評估表，即可辦理黃金存摺買進類交易。", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
//                    m_btnNext.isEnabled = false
//                }
//                else {
//                    m_tvContentView.isHidden = false
//                    m_consContentViewHeight.constant = m_contentViewHeight
//                    m_consSellAllHeight.constant = m_sellAllHeight
//                    m_tvContentView.reloadData()
//                    m_btnNext.isEnabled = true
//                }
//            }
//            self.send_getGoldList2(actInfo.accountNO)
            }
        case "Gold0204":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any] {
                self.m_lbTransOutAct.text = data["INVACT"] as? String
                if let result = data["Result"] as? [[String:String]] {
                    m_aryData.removeAll()
                    for date in result {
                        var tempSettingData: GPSettingData = GPSettingData()
                        tempSettingData.m_strDAY = date["DAY"]!
                        tempSettingData.m_strTYPE = GPRegularType(rawValue: date["TYPE"]!)!
                        tempSettingData.m_strAMT = date["AMT"]!
                        tempSettingData.m_strPRICE = date["PRICE"]!
                        tempSettingData.m_strSDAY = date["SDAY"]!
                        tempSettingData.m_strEDAY = date["EDAY"]!
                        tempSettingData.m_strUPER = date["UPER"]!
                        tempSettingData.m_strUSIGN = date["USIGN"]!
                        tempSettingData.m_strUAMT = date["UAMT"]!
                        tempSettingData.m_strDPER = date["DPER"]!
                        tempSettingData.m_strDSIGN = date["DSIGN"]!
                        tempSettingData.m_strDAMT = date["DAMT"]!
                        tempSettingData.m_strUCAP = date["UCAP"]!
                        tempSettingData.m_strDCAP = date["DCAP"]!
                        tempSettingData.m_strQTY = date["QTY"]!
                        tempSettingData.m_strDATE = (data["DATE"]! as? String)!
                        tempSettingData.m_strBtn = tempSettingData.m_strTYPE.getBtnTitle()
                        m_aryData.append(tempSettingData)
                    }
                    if (m_aryData.count >= 3) {
                        self.setDate1(m_aryData[0])
                        self.setDate2(m_aryData[1])
                        self.setDate3(m_aryData[2])
                        self.m_svContent.isHidden = false
                    }
                    else {
                        self.showAlert(title: nil, msg: "Gold0204 資料數不足", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                    }
                }
                else {
                    self.clearDate()
                    self.m_svContent.isHidden = true
                }
                if (m_strACTCreday == "N") {
                    showAlert(title: nil, msg: "本會依法須定期更新客戶投資風險承受度資訊，以保障客戶權益，貴戶「投資風險屬性評估表」已逾一年有效期限，請速洽本會營業據點或於網路銀行線上填寫上述評估表，即可辦理黃金存摺買進類交易。", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                }
            }
        case "Gold0101A":
            if let data = response.object(forKey: ReturnData_Key) as? [String:String] {
//                AuthorizationManage.manage.setGoldAcception(data)
//                if (AuthorizationManage.manage.canEnterGold()) {
                if (data["Read"] == "Y") {
                    switch m_aryData[m_iBtnIndex].m_strTYPE {
                    case GPRegularType.GPRegularTypeSameAmount:
                        performSegue(withIdentifier: "showChange", sender: m_aryData[m_iBtnIndex])
                    case GPRegularType.GPRegularTypeSameQuantity:
                        performSegue(withIdentifier: "showChange", sender: m_aryData[m_iBtnIndex])
                    case GPRegularType.GPRegularTypeDiffAmount:
                        break
                    default:
                        performSegue(withIdentifier: "showBuy", sender: m_aryData[m_iBtnIndex])
                    }
//                    if(m_aryData[m_iBtnIndex].m_strBtn == btnTitleNew) {
//                        performSegue(withIdentifier: "showBuy", sender: m_aryData[m_iBtnIndex])
//                    }
//                    else if(m_aryData[m_iBtnIndex].m_strBtn == btnTitleChange) {
//                        performSegue(withIdentifier: "showChange", sender: m_aryData[m_iBtnIndex])
//                    }
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
                if (actInfo.accountNO != m_uiActView?.getContentByType(.First)) {
                    m_uiActView?.setOneRow(GPAccountTitle, actInfo.accountNO)
                    self.m_lbCurrency.text = (actInfo.currency == Currency_TWD) ? Currency_TWD_Title:actInfo.currency
                    self.send_getGoldAcctInfo(actInfo.accountNO)
                    self.m_svContent.isHidden = true
                }
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
