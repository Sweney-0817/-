//
//  GPTransactionDetailViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/7/31.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit
let TransactionDetail_CellTitle = ["交易日期", "更正記號", "交易量", "餘額(克)"]

struct GPTransactionDetailData {
    ///日期
    var TXDAY: String = ""
    // 時間
    var TXTIME: String = ""
    ///更正
    var HCODE: String = ""
    ///借貸
    var CRDB: String = ""
    ///交易公克數
    var TXQTY: String = ""
    ///餘額(公克)
    var AVBAL: String = ""
    ///交易序號
    var SEQ: String = ""
    ///單價
    var VALUE: String = ""
}
class GPTransactionDetailViewController: BaseViewController {
    @IBOutlet var m_vActView: UIView!
    @IBOutlet var m_vTopView: UIView!
    @IBOutlet var m_lbTitle: UILabel!
    @IBOutlet var m_lbDate: UILabel!
    @IBOutlet var m_tvContentView: UITableView!
    var m_dtStart:Date? = nil
    var m_dtEnd:Date? = nil
    var m_iActIndex: Int = -1
    var m_aryActList : [AccountStruct] = [AccountStruct]()
    var m_aryData: [GPTransactionDetailData] = [GPTransactionDetailData]()
    var m_uiActView: OneRowDropDownView? = nil
    var m_strActFromAccountInfomation: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initActView()
        initTableView()
        getTransactionID("10002", TransactionID_Description)
        
        // 預設為近7日
        m_dtStart = NSCalendar.current.date(byAdding: .day, value: -6, to: Date())!
        m_dtEnd = Date()
        self.showDatePeriod("近7日", start: m_dtStart!, end: m_dtEnd!)
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
        
        setShadowView(m_vTopView)
    }
    private func initTableView() {
        m_tvContentView.delegate = self
        m_tvContentView.dataSource = self
        m_tvContentView.allowsSelection = false
        m_tvContentView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
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
    func showDatePeriod(_ strTitle: String, start: Date, end: Date) {
        if (strTitle == "") {
            m_lbTitle.text = ""
            m_lbDate.text = ""
        }
        else {
            m_lbTitle.text = strTitle
            let fmt = DateFormatter()
            fmt.dateFormat = "YYYY/MM/dd"
            let startDate: String = fmt.string(from: start)
            let endDate: String = fmt.string(from: end)
            m_lbDate.text = "\(startDate) - \(endDate)"
        }
    }
    func showDetail(_ index: Int) {
        performSegue(withIdentifier: "showDetail", sender: m_aryData[index])
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
                self.send_getGoldInfo(m_dtStart!, m_dtEnd!)
                return
            }
        }
//        NSLog("(往來明細)找不到帳戶總覽帶來的帳號[%@]", m_strActFromAccountInfomation!)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let data: GPTransactionDetailData = sender as! GPTransactionDetailData
        super.prepare(for: segue, sender: sender)
        let controller = segue.destination as! GPTransactionDetailDetailViewController
        controller.setData(data)
    }
    
    // MARK:- WebService Methods
    func send_getGoldList() {
        self.setLoading(true)
        postRequest("Gold/Gold0201", "Gold0201", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10002","Operate":"getGoldList","TransactionId":transactionId], true), AuthorizationManage.manage.getHttpHead(true))
    }
    func send_getGoldInfo(_ start: Date, _ end: Date) {
        self.setLoading(true)
        let fmt = DateFormatter()
        fmt.dateFormat = "YYYYMMdd"
        let startDate: String = fmt.string(from: start)
        let endDate: String = fmt.string(from: end)

        postRequest("Gold/Gold0202", "Gold0202", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10003","Operate":"getGoldInfo","TransactionId":transactionId, "REFNO":m_aryActList[m_iActIndex].accountNO,"INQSDY":startDate,"INQEDY":endDate], true), AuthorizationManage.manage.getHttpHead(true))
    }
    override func didResponse(_ description:String, _ response: NSDictionary) {
        self.setLoading(false)
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                setLoading(true)
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
                showErrorMessage(nil, ErrorMsg_No_TaskId)
            }
        case "Gold0202":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let result = data["Result"] as? [[String:String]] {
                m_aryData.removeAll()
                for data in result {
                    if let TXDAY = data["TXDAY"], let TXTIME = data["TIME"], let HCODE = data["HCODE"], let CRDB = data["CRDB"], let TXQTY = data["TXQTY"], let AVBAL = data["AVBAL"], let SEQ = data["SEQ"], let VALUE = data["VALUE"] {
                        
                        m_aryData.append(GPTransactionDetailData(TXDAY: TXDAY.dateFormatter(form: "yyyyMMdd", to: "yyyy/MM/dd"), TXTIME: TXTIME, HCODE: HCODE, CRDB: CRDB, TXQTY: TXQTY, AVBAL: AVBAL, SEQ: SEQ, VALUE: VALUE))
                    }
                }
                m_tvContentView.reloadData()
            }
        default: super.didResponse(description, response)
        }
    }
    
    // MARK:- Handle Actions
    @IBAction func m_btnTodayClick(_ sender: Any) {
        guard m_iActIndex != -1 else {
            self.showAlert(title: UIAlert_Default_Title, msg: "請選擇黃金存摺帳號", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
            return
        }
        m_dtStart = Date()
        m_dtEnd = Date()
        self.showDatePeriod("當日", start: m_dtStart!, end: m_dtEnd!)
        self.send_getGoldInfo(m_dtStart!, m_dtEnd!)
    }
    @IBAction func m_btnWeekClick(_ sender: Any) {
        guard m_iActIndex != -1 else {
            self.showAlert(title: UIAlert_Default_Title, msg: "請選擇黃金存摺帳號", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
            return
        }
        m_dtStart = NSCalendar.current.date(byAdding: .day, value: -6, to: Date())!
        m_dtEnd = Date()
        self.showDatePeriod("近7日", start: m_dtStart!, end: m_dtEnd!)
        self.send_getGoldInfo(m_dtStart!, m_dtEnd!)
    }
    @IBAction func m_btnCustomizeClick(_ sender: Any) {
        guard m_iActIndex != -1 else {
            self.showAlert(title: UIAlert_Default_Title, msg: "請選擇黃金存摺帳號", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
            return
        }
        let curDate = InputDatePickerStruct(minDate: nil, maxDate: Date(), curDate: Date())
        if let dateView = getUIByID(.UIID_DatePickerView) as? DatePickerView {
            dateView.frame = CGRect(origin: .zero, size: view.frame.size)
            dateView.showTwoDatePickerView(true, curDate, curDate) { start, end, dtStart, dtEnd in
                self.m_dtStart = dtStart
                self.m_dtEnd = dtEnd
                var componenets = Calendar.current.dateComponents([.year, .month, .day], from: self.m_dtStart!)
                componenets.month = componenets.month!+6
                if Calendar.current.compare(Calendar.current.date(from: componenets)!, to: self.m_dtEnd!, toGranularity: .day) == .orderedAscending {
                    self.showErrorMessage(nil, ErrorMsg_DateMonthOnlySix)
                }
                else {
                    self.showDatePeriod("自訂", start: self.m_dtStart!, end: self.m_dtEnd!)
                    self.send_getGoldInfo(self.m_dtStart!, self.m_dtEnd!)
                }
            }
            view.addSubview(dateView)
        }
    }
}

extension GPTransactionDetailViewController : OneRowDropDownViewDelegate {
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

extension GPTransactionDetailViewController : UIActionSheetDelegate {
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet.cancelButtonIndex != buttonIndex {
            switch (actionSheet.tag) {
            case ViewTag.View_AccountActionSheet.rawValue:
                self.m_iActIndex = buttonIndex - 1
                let actInfo : AccountStruct = m_aryActList[self.m_iActIndex]
                if (m_uiActView?.getContentByType(.First) != actInfo.accountNO)
                {
                    m_uiActView?.setOneRow(GPAccountTitle, actInfo.accountNO)
                    self.send_getGoldInfo(m_dtStart!, m_dtEnd!)
                }
                else
                {
                    // 相同帳號不做動作
                }
            default:
                break
            }
        }
    }
}

extension GPTransactionDetailViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_aryData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_GPTransactionDetailCell.NibName()!, for: indexPath) as! GPTransactionDetailCell
        cell.set(m_aryData[indexPath.row], self.showDetail(_:), indexPath.row)
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 126
    }
}
