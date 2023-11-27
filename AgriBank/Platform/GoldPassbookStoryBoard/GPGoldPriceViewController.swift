//
//  GPGoldPriceViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/7/31.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit
struct GoldPriceData {
    var m_strDate: String
    var m_strTime: String
    var m_strBuy: String
    var m_strSell: String
}

class GPGoldPriceViewController: BaseViewController {
    @IBOutlet var m_vTopView: UIView!
    @IBOutlet var m_lbTitle: UILabel!
    @IBOutlet var m_lbDate: UILabel!
    @IBOutlet var m_tvContentView: UITableView!
    var m_aryData: [GoldPriceData] = [GoldPriceData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initTableView()
        setShadowView(m_vTopView)
        
        // 預設顯示當日牌告價格
        self.m_btnTodayClick((Any).self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Init Methods
    private func initTableView() {
        m_tvContentView.delegate = self
        m_tvContentView.dataSource = self
        m_tvContentView.allowsSelection = false
        m_tvContentView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }

    // MARK:- UI Methods
    private func showDatePeriod(_ strTitle: String, start: Date, end: Date) {
        m_lbTitle.text = strTitle
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy/MM/dd"
        let startDate: String = fmt.string(from: start)
        let endDate: String = fmt.string(from: end)
        m_lbDate.text = "\(startDate) - \(endDate)"
    }
    // MARK:- Logic Methods
    
    // MARK:- WebService Methods
    private func getRandomPrice() -> Float {
        let i = arc4random_uniform(10000)
        let f = Float(i) / 100.0 + 950
        return f
    }
    private func makeFakeData(_ start: Date, _ end: Date) {
        m_aryData.removeAll()
        var date = start // first date
        let endDate = end // last date
        
        // Formatter for printing the date, adjust it according to your needs:
        let fmt = DateFormatter()
        fmt.dateFormat = "MM/dd"
        
        while date <= endDate {
            let goldPriceData1: GoldPriceData = GoldPriceData(m_strDate: fmt.string(from: date), m_strTime: "00:00:00", m_strBuy: String(format: "%.2f", getRandomPrice()), m_strSell: String(format: "%.2f", getRandomPrice()))
            let goldPriceData2: GoldPriceData = GoldPriceData(m_strDate: fmt.string(from: date), m_strTime: "06:00:00", m_strBuy: String(format: "%.2f", getRandomPrice()), m_strSell: String(format: "%.2f", getRandomPrice()))
            let goldPriceData3: GoldPriceData = GoldPriceData(m_strDate: fmt.string(from: date), m_strTime: "12:00:00", m_strBuy: String(format: "%.2f", getRandomPrice()), m_strSell: String(format: "%.2f", getRandomPrice()))
            let goldPriceData4: GoldPriceData = GoldPriceData(m_strDate: fmt.string(from: date), m_strTime: "18:00:00", m_strBuy: String(format: "%.2f", getRandomPrice()), m_strSell: String(format: "%.2f", getRandomPrice()))
            m_aryData.append(goldPriceData1)
            m_aryData.append(goldPriceData2)
            m_aryData.append(goldPriceData3)
            m_aryData.append(goldPriceData4)
            date = NSCalendar.current.date(byAdding: .day, value: 1, to: date)!
        }
        m_tvContentView.reloadData()
    }
    func send_queryData(_ start: Date, _ end: Date) {
        self.setLoading(true)
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyyMMdd"
        let startDate: String = fmt.string(from: start)
        let endDate: String = fmt.string(from: end)

        postRequest("Gold/Gold0501", "Gold0501", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10012","Operate":"queryData","SDAY":startDate,"EDAY":endDate], true), AuthorizationManage.manage.getHttpHead(true))
    }
    override func didResponse(_ description:String, _ response: NSDictionary) {
        self.setLoading(false)
        switch description {
        case "Gold0501":
            // 清除畫面資料
            m_aryData.removeAll()
            
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode == ReturnCode_Success
            {
                if let result = response.object(forKey: ReturnData_Key) as? [[String:String]] {
                    for data in result {
                        if let DATE = data["DATE"], let TIME = data["TIME"], let SELL = data["SELL"], let BUY = data["BUY"] {
                            m_aryData.append(GoldPriceData(m_strDate: DATE, m_strTime: TIME, m_strBuy: BUY, m_strSell: SELL))
                        }
                    }
                }
            }
            else {
                if let message = response.object(forKey:ReturnMessage_Key) as? String {
                    showErrorMessage(nil, message)
                }
            }
            
            // 重新ReLoad
            m_tvContentView.reloadData()
        default: super.didResponse(description, response)
        }
    }
    
    // MARK:- Handle Actions
    @IBAction func m_btnTodayClick(_ sender: Any) {
        let start: Date = Date()
        let end: Date = Date()
        self.showDatePeriod("當日", start: start, end: end)
        self.send_queryData(start, end)
    }
    @IBAction func m_btnWeekClick(_ sender: Any) {
        let start: Date = NSCalendar.current.date(byAdding: .day, value: -6, to: Date())!
        let end: Date = Date()
        self.showDatePeriod("近7日", start: start, end: end)
        self.send_queryData(start, end)
    }
    @IBAction func m_btnCustomizeClick(_ sender: Any) {
        let curDate = InputDatePickerStruct(minDate: nil, maxDate: Date(), curDate: Date())
        if let dateView = getUIByID(.UIID_DatePickerView) as? DatePickerView {
            dateView.frame = CGRect(origin: .zero, size: view.frame.size)
            dateView.showTwoDatePickerView(true, curDate, curDate) { start, end, sDate, eDate in
                var componenets = Calendar.current.dateComponents([.year, .month, .day], from: sDate!)
                componenets.month = componenets.month!+6
                if Calendar.current.compare(Calendar.current.date(from: componenets)!, to: eDate!, toGranularity: .day) == .orderedAscending {
                    self.showErrorMessage(nil, ErrorMsg_DateMonthOnlySix)
                }
                else {
                    self.showDatePeriod("自訂", start: sDate!, end: eDate!)
                    self.send_queryData(sDate!, eDate!)
                }
            }
            view.addSubview(dateView)
        }
    }
}

extension GPGoldPriceViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_GPGoldPriceCell.NibName()!) as! GPGoldPriceCell
        cell.set("牌價日期", "牌價時間", "銀行買進", "銀行賣出")
        cell.backgroundColor = .white
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_aryData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_GPGoldPriceCell.NibName()!, for: indexPath) as! GPGoldPriceCell
        let data: GoldPriceData = m_aryData[indexPath.row]
        
        cell.set(data.m_strDate.dateFormatter(form: "yyyyMMdd", to: "MM/dd"), data.m_strTime, data.m_strBuy, data.m_strSell)
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 32
    }
}
