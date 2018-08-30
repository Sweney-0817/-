//
//  GPTransactionDetailViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/7/31.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit
let TransactionDetail_CellTitle = ["交易日期", "更正記號", "交易量", "餘額(g)"]
let TransactionDetailDetail_CellTitle = ["交易時間", "交易序號", "更正記號", "借貸", "交易量", "單價", "餘額(g)"]
class GPTransactionDetailViewController: BaseViewController {
    @IBOutlet var m_vActView: UIView!
    @IBOutlet var m_vTopView: UIView!
    @IBOutlet var m_lbTitle: UILabel!
    @IBOutlet var m_lbDate: UILabel!
    @IBOutlet var m_tvContentView: UITableView!
    var m_aryActList: [String] = [String]()
    var m_aryData: [[String:String]] = [[String:String]]()
    var m_strCurDetail: String? = nil
    var m_dicDetail: [String:[[String:String]]] = [String:[[String:String]]]()
    var m_uiActView: OneRowDropDownView? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initActView()
        initTableView()
        send_getActList()
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
        
//        setShadowView(m_vActView)
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
            for act in m_aryActList {
                actSheet.addButton(withTitle: act)
            }
            actSheet.tag = ViewTag.View_AccountActionSheet.rawValue
            actSheet.show(in: view)
        }
        else {
            showErrorMessage(nil, ErrorMsg_GetList_InCommonAccount)
        }
    }
    private func showDatePeriod(_ strTitle: String, start: Date, end: Date) {
        m_lbTitle.text = strTitle
        let fmt = DateFormatter()
        fmt.dateFormat = "YYYY/MM/dd"
        let startDate: String = fmt.string(from: start)
        let endDate: String = fmt.string(from: end)
        m_lbDate.text = "\(startDate) - \(endDate)"
    }
    func showDetail(_ serial: String) {
        m_strCurDetail = serial
        if (m_dicDetail[m_strCurDetail!] == nil) {
            self.send_getTransactionDetailDetail(m_strCurDetail!)
        }
        else {
            performSegue(withIdentifier: "showDetail", sender: nil)
        }
    }
    // MARK:- Logic Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let controller = segue.destination as! GPTransactionDetailDetailViewController
        controller.setData(m_dicDetail[m_strCurDetail!]!)
    }
    // MARK:- WebService Methods
    private func makeFakeAct() {
        m_aryActList.removeAll()
        for i in 0..<20 {
            m_aryActList.append(String.init(format: "%05d", i))
        }
    }
    private func makeFakeTransactionDetail(_ start: Date, _ end: Date) {
        m_aryData.removeAll()
        var date = start // first date
        let endDate = end // last date
        
        // Formatter for printing the date, adjust it according to your needs:
        let fmt = DateFormatter()
        fmt.dateFormat = "YYYY/MM/dd"
        
        while date <= endDate {
            var dicData: [String: String] = [String: String]()
            dicData["title"] = (Int(Date().timeIntervalSince1970) % 2 == 0) ? "買進量" : "賣出量"
            dicData["date"] = fmt.string(from: date)
            dicData["mark"] = (Int(Date().timeIntervalSince1970) % 2 == 0) ? "更" : "-"
            dicData["amount"] = String(format: "%d", arc4random_uniform(100))
            dicData["balance"] = String(format: "%d", arc4random_uniform(10))
            dicData["serial"] = String(format: "%d", arc4random_uniform(10))
            
            date = NSCalendar.current.date(byAdding: .day, value: 1, to: date)!
            m_aryData.append(dicData)
        }
        m_tvContentView.reloadData()
    }
    private func makeFakeTransactionDetailDetail(_ serial: String) {
        var aryData: [[String:String]] = [[String:String]]()
        for key in TransactionDetailDetail_CellTitle {
            var dicData: [String:String] = [String:String]()
            dicData[Response_Key] = key
            dicData[Response_Value] = String(format: "[%@][%@]", key, serial)
            aryData.append(dicData)
        }
        m_dicDetail[serial] = aryData
    }
    func send_getActList() {
        self.makeFakeAct()
        //        postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
    }
    func send_getTransactionDetail(_ start: Date, _ end: Date) {
        self.makeFakeTransactionDetail(start, end)
        //        postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
    }
    func send_getTransactionDetailDetail(_ serial: String) {
        self.makeFakeTransactionDetailDetail(serial)
        performSegue(withIdentifier: "showDetail", sender: nil)
    }
    // MARK:- Handle Actions
    @IBAction func m_btnTodayClick(_ sender: Any) {
        let start: Date = Date()
        let end: Date = Date()
        self.showDatePeriod("當日", start: start, end: end)
        self.send_getTransactionDetail(start, end)
    }
    @IBAction func m_btnWeekClick(_ sender: Any) {
        let start: Date = NSCalendar.current.date(byAdding: .day, value: -7, to: Date())!
        let end: Date = Date()
        self.showDatePeriod("近7日", start: start, end: end)
        self.send_getTransactionDetail(start, end)
    }
    @IBAction func m_btnCustomizeClick(_ sender: Any) {
        let curDate = InputDatePickerStruct(minDate: nil, maxDate: Date(), curDate: Date())
        if let dateView = getUIByID(.UIID_DatePickerView) as? DatePickerView {
            dateView.frame = view.frame
            dateView.frame.origin = .zero
            dateView.showTwoDatePickerView(true, curDate, curDate) { start, end, sDate, eDate in
                var componenets = Calendar.current.dateComponents([.year, .month, .day], from: sDate!)
                componenets.month = componenets.month!+6
                if Calendar.current.compare(Calendar.current.date(from: componenets)!, to: eDate!, toGranularity: .day) == .orderedAscending {
                    self.showErrorMessage(nil, ErrorMsg_DateMonthOnlySix)
                }
                else {
                    self.showDatePeriod("自訂", start: sDate!, end: eDate!)
                    self.send_getTransactionDetail(sDate!, eDate!)
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
            self.send_getActList()
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
                let iIndex : Int = buttonIndex - 1
                let act : String = m_aryActList[iIndex]
                m_uiActView?.setOneRow(GPAccountTitle, act)
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
        cell.set(m_aryData[indexPath.row], self.showDetail(_:))
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 126
    }
}
