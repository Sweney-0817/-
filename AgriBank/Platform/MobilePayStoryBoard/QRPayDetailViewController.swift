//
//  QRPayDetailViewController.swift
//  AgriBank
//
//  Created by ABOT on 2020/1/6.
//  Copyright © 2020 Systex. All rights reserved.
//

import UIKit
let QRPayDetailView_ShowDetail_Segue = "ShowQRDetail"
let QRDetailView_CellTitleList = ["交易日期","交易金額","交易結果","財金交易序號"]
let QRDetailView_ShowAccount_Title = "帳號"
let QRBarTitle = "交易紀錄/退貨"
extension String{
    func rerplace(target:String,withString:String)->String{
        return self.replacingOccurrences(of: target, with: withString,options: NSString.CompareOptions.literal,range: nil)
    }
}
class QRPayDetailViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, OneRowDropDownViewDelegate, UIActionSheetDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var transDayView: UIView!
    @IBOutlet weak var chooseAccountView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var theDayButton: UIButton!
    @IBOutlet weak var weekDayButton: UIButton!
    @IBOutlet weak var customizeDayButton: UIButton!
    @IBOutlet weak var dateTypeLabel: UILabel!
    private var categoryList = [String:[AccountStruct]]() // Key: 電文(ACCT0101)response的"ACTTYPE"
    private var categoryType = [String:String]() // Key: ActOverviewType.description() value: 電文(ACCT0101)response的"ACTTYPE"
    private var currentType:String? = "P"        // 目前選擇的帳戶Type
    private var chooseAccount:String? = nil      // 目前選擇得帳號
    private var startDate = ""                   // 起始日
    private var endDate = ""                     // 截止日
    private var resultList:[[String:Any]]? = nil // 電文response
    private var typeList:[String]? = nil         // 使用者帳戶清單的Type List
    private var currentIndex = 0                 // resultList Index
 
    // MARK: - Public
    func setInitial(_ type:String?, _ account:String?)  {
        currentType = type
        chooseAccount = account
        if currentType != nil && chooseAccount != nil {
            if categoryType[currentType!] != nil {
                //  電文已經reponse SetInitial晚
                (chooseAccountView.subviews.first as! OneRowDropDownView).setOneRow(QRDetailView_ShowAccount_Title, chooseAccount ?? Choose_Title)
                clickDateBtn(weekDayButton)
            }
        }
    }
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: UIID.UIID_OverviewCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_OverviewCell.NibName()!)
        
        setShadowView(transDayView)
        let view = getUIByID(.UIID_OneRowDropDownView) as! OneRowDropDownView
        view.m_lbFirstRowTitle.textAlignment = .center
        view.frame = chooseAccountView.frame
        view.frame.origin = .zero
        view.delegate = self
        view.setOneRow(QRDetailView_ShowAccount_Title, Choose_Title)
        view.titleWeight.constant = view.titleWeight.constant / 2
        chooseAccountView.addSubview(view)
        
        getTransactionID("09007", TransactionID_Description)
        
        /*  規格需求  */
        let date = Date()
        let componenets = Calendar.current.dateComponents([.year, .month, .day], from: date)
        if let day = componenets.day, let month = componenets.month, let year = componenets.year {
            endDate = "\(year)/\(String(format: "%02d", month))/\(String(format: "%02d", day))"
        }
        
        let newDate = Calendar.current.date(byAdding: .day, value: -6, to: date) ?? date
        let startComponenets = Calendar.current.dateComponents([.year, .month, .day], from: newDate)
        if let day = startComponenets.day, let month = startComponenets.month, let year = startComponenets.year {
            startDate = "\(year)/\(String(format: "%02d", month))/\(String(format: "%02d", day))"
        }
        dateTypeLabel.text = weekDayButton.titleLabel?.text
        dateLabel.text = startDate + (endDate != "" ? " - \(endDate)" : "")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let controller = segue.destination as! ShowQRDetailViewController
        var list = [[String:String]]()
        var iDay = "";
        var iTime = "";
        if currentType != nil, let dic = resultList?[currentIndex] {
            
            let PCODE = dic["PCODE"] as? String
            if let CHIPTXSEQ = dic["CHIPTXSEQ"] as? String {
                list.append([Response_Key: "交易序號", Response_Value: CHIPTXSEQ])
            }
            else {
                list.append([Response_Key: "交易序號", Response_Value:""])
            }
            
            list.append([Response_Key: "轉出帳號", Response_Value:chooseAccount! ])
            //CHIPDAY 原交易日期
            //TXDAY 系統（主機）交易日期
            //2541時 CHIPDAY = TXDATE
            
            if let TXDATE = dic["TXDATE"] as? String {
                list.append([Response_Key: "交易日期", Response_Value:TXDATE])
                
            }
            else {
                list.append([Response_Key: "交易日期", Response_Value:""])
            }
           //CHIPDAY 原交易時間
            if let CHIPTIME = dic["CHIPTIME"] as? String {
                //2541才Show時間(因為CHIPTIME為原交易時間）
                    if PCODE == "2541" {
                    list.append([Response_Key: "交易時間", Response_Value:CHIPTIME])
                    iTime =  CHIPTIME.replacingOccurrences(of: ":", with: "")
                    }
            }
            else {
                list.append([Response_Key: "交易時間", Response_Value:""])
            }

            if let TXAMT = dic["TXAMT"] as? String {
                list.append([Response_Key: "交易金額", Response_Value:TXAMT.separatorThousand()])
            }
            else {
                list.append([Response_Key: "交易金額", Response_Value:""])
            }
            
            //20101112- add by sweney 新增訂單編號
            if let ORDERNO = dic["ORDERNO"] as? String {
                list.append([Response_Key: "訂單編號", Response_Value:ORDERNO ])
            }
            else {
                //沒有就不秀
                // list.append([Response_Key: "訂單編號", Response_Value:"" ])
            } 
            
            if let RC2 = dic["RC2"] as? String {
                list.append([Response_Key: "交易結果", Response_Value:RC2])
                if RC2 == "購物成功"{
                    RC2flag = "OK"
                }else{
                    RC2flag = ""
                }
               
            }
            else {
                list.append([Response_Key: "交易結果", Response_Value:""])
            }
            if let STANSEQ = dic["STANSEQ"] as? String {
                           list.append([Response_Key: "財金交易序號", Response_Value:STANSEQ])
                       }
                       else {
                           list.append([Response_Key: "財金交易序號", Response_Value:""])
                       }
            
            if let STANORG = dic["STANORG"] as? String {
                list.append([Response_Key: "原財金序號", Response_Value:STANORG])
            }
            else {
                list.append([Response_Key: "原財金序號", Response_Value:""])
            }
            if PCODE == "2541"{
                   if let CHIPDAY = dic["CHIPDAY"] as? String{
                       iDay = CHIPDAY.replacingOccurrences(of: "/", with: "")
                   }
                }else //不是2541多顯示一行原交易日期
                {
                    if let CHIPDAY = dic["CHIPDAY"] as? String{
                        list.append([Response_Key: "原交易日期", Response_Value:CHIPDAY])
                    }
                }
     //chiu set QRCodeInfo start
            QRCodeInfo["TransCode"] = dic["PCODE"] as? String
            QRCodeInfo["TransTime"] = iDay + iTime
            QRCodeInfo["CardBank"] = "600"
            QRCodeInfo["CardNumber"] = chooseAccount!
            QRCodeInfo["TSN"] = dic["STANSEQ"] as? String
            QRCodeInfo["TAC"] = dic["STANBKNO"] as? String
            QRCodeInfo["TXN"] = dic["STANBKNO"] as? String
            QRCodeInfo["STAN"] = dic["STANSEQ"] as? String
            QRCodeInfo["ORG"] = dic["STANORG"] as? String
           
    //chiu end
            controller.setList(QRBarTitle, list)
            
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if currentType != nil {
            count = resultList?.count ?? 0
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_OverviewCell.NibName()!, for: indexPath) as! OverviewCell
        if  let dic = resultList?[indexPath.row] {
            cell.title1Label.text = QRDetailView_CellTitleList[0]
            cell.title2Label.text = QRDetailView_CellTitleList[1]
            cell.title3Label.text = QRDetailView_CellTitleList[2]
            let CHIPTIME = dic["CHIPTIME"] as? String
            let PCODE = dic["PCODE"] as? String
                if let TXDATE = dic["TXDATE"] as? String {
                    cell.detail1Label.text = TXDATE
                    
                }
                
                if PCODE == "2541" {
                    cell.detail1Label.text = cell.detail1Label.text! + " " + CHIPTIME!
                    }
            
                if let TXAMT = dic["TXAMT"] as? String {
                    cell.detail2Label.text = TXAMT.separatorThousand()
                }
                if let RC2 = dic["RC2"] as? String {
                    cell.detail3Label.text = RC2
                    if let STANSEQ = dic["STANSEQ"] as? String{
                        cell.detail3Label.text = RC2  + "(序號：" + STANSEQ + ")"
                    }
                
                }
        }
        return cell
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
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]]{
                typeList = [String]()
                for category in array {
                    if let type = category["ACTTYPE"] as? String, let result = category["AccountInfo"] as? [[String:Any]], result.count > 0 {
                        var addType = false
                        // "ACTTYPE"->帳號類別: 活存：P, 支存：K, 定存：T, 放款：L, 綜存：M
                        switch type {
                        case "P":
                            categoryType[ActOverview_TypeList[0]] = type
                            categoryList[type] = [AccountStruct]()
                            addType = true
                            if typeList?.index(of: ActOverviewType.Type1.description()) == nil {
                                typeList?.append(ActOverviewType.Type1.description())
                            }
                        default: break
                        }
                        
                        if addType {
                            for actInfo in result {
                                if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? String, let ebkfg = actInfo["EBKFG"] as? String {
                                    categoryList[type]?.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
                                }
                            }
                        }
                    }
                }
                
                if typeList?.count != 0 {
                    
                    //2019-12-6 add by sweney 預設查詢帳號
                    if   let list = categoryList[currentType!] {
                        if list.count > 0 {
                            chooseAccount = list[0].accountNO
                        }
                    }
                    if chooseAccount != nil {
                       
                        (chooseAccountView.subviews.first as! OneRowDropDownView).setOneRow(ActDetailView_ShowAccount_Title, chooseAccount!)
                         clickDateBtn(weekDayButton)
                        //postGetAcntInfo()
                    }
                    else {
                        setLoading(false)
                    }
                }
                else {
                    setLoading(false)
                }
                tableView.reloadData()
            }
            else {
                super.didResponse(description, response)
            }
            
            
        case "QR0901":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let result = data["Result"] as? [[String:Any]] {
                resultList = result
                tableView.reloadData()
            }
            
        default: super.didResponse(description, response)
        }
    }
    
  
    // MARK: - StoryBoadr Touch Event
    @IBAction func clickDateBtn(_ sender: Any) {
        if (chooseAccountView.subviews.first as! OneRowDropDownView).getContentByType(.First) == Choose_Title {
            showErrorMessage(nil, Choose_Title+(currentType ?? "")+QRDetailView_ShowAccount_Title)
            return
        }
        let btn = (sender as! UIButton)
        dateTypeLabel.text = btn.titleLabel?.text
        switch btn {
        case theDayButton:
            let componenets = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            if let day = componenets.day, let month = componenets.month, let year = componenets.year {
                startDate = "\(year)/\(String(format: "%02d", month))/\(String(format: "%02d", day))"
            }
            endDate = ""
            postGetAcntInfo()
            dateLabel.text = startDate + (endDate != "" ? "- \(endDate)" : "")
            
        case weekDayButton:
            let date = Date()
            let componenets = Calendar.current.dateComponents([.year, .month, .day], from: date)
            if let day = componenets.day, let month = componenets.month, let year = componenets.year {
                endDate = "\(year)/\(String(format: "%02d", month))/\(String(format: "%02d", day))"
            }
            
            let newDate = Calendar.current.date(byAdding: .day, value: -6, to: date) ?? date
            let startComponenets = Calendar.current.dateComponents([.year, .month, .day], from: newDate)
            if let day = startComponenets.day, let month = startComponenets.month, let year = startComponenets.year {
                startDate = "\(year)/\(String(format: "%02d", month))/\(String(format: "%02d", day))"
            }
            postGetAcntInfo()
            dateLabel.text = startDate + (endDate != "" ? " - \(endDate)" : "")
            
        case customizeDayButton:
            if let dateView = getUIByID(.UIID_DatePickerView) as? DatePickerView {
                dateView.frame = CGRect(origin: .zero, size: view.frame.size)
                dateView.showTwoDatePickerView(true, nil, nil) { start, end, sDate, eDate in
                    var componenets = Calendar.current.dateComponents([.year, .month, .day], from: sDate!)
                    componenets.month = componenets.month!+2
                    self.startDate = "\(start.year)/\(start.month)/\(start.day)"
                    self.endDate = "\(end.year)/\(end.month)/\(end.day)"
                    //2020-1-6- add by sweney 6month check
                    var componenets6 = Calendar.current.dateComponents([.year, .month, .day], from:  Date())
                    componenets6.month = componenets6.month!-6
                    //2020-1-6- add by sweney 6month check
                    if Calendar.current.compare(Calendar.current.date(from: componenets6)!, to: sDate!, toGranularity: .day) == .orderedDescending {
                        let wkDateInfo = "自訂區間：" + self.startDate + (self.endDate != "" ? " - \(self.endDate)" : "")
                        self.showErrorMessage(nil, wkDateInfo + "\n" + ErrorMsg_DateMonthLesSix)
                    }
                    else  if Calendar.current.compare(Calendar.current.date(from: componenets)!, to: eDate!, toGranularity: .day) == .orderedAscending {
                        let wkDateInfo = "自訂區間：" + self.startDate + (self.endDate != "" ? " - \(self.endDate)" : "")
                        self.showErrorMessage(nil, wkDateInfo + "\n" + ErrorMsg_DateMonthOnlyTwo)
                    }
                        
                    else {
                        //                        self.startDate = "\(start.year)/\(start.month)/\(start.day)"
                        //                        self.endDate = "\(end.year)/\(end.month)/\(end.day)"
                        self.dateLabel.text = self.startDate + (self.endDate != "" ? " - \(self.endDate)" : "")
                        self.postGetAcntInfo()
                    }
                }
                view.addSubview(dateView)
            }
            
        default: break
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentIndex = indexPath.row
        performSegue(withIdentifier: QRPayDetailView_ShowDetail_Segue, sender: nil)
    }
    
    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        if currentType != nil {
            if let list = categoryList[currentType!] {
                if list.count > 0 {
                    let act = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
                    for info in list {
                        act.addButton(withTitle: info.accountNO)
                    }
                    act.show(in: view)
                }
                else {
                    showErrorMessage(nil, "\(Get_Null_Title)\(currentType ?? "")\(sender.m_lbFirstRowTitle.text!)")
                }
            }
        }
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            chooseAccount = actionSheet.buttonTitle(at: buttonIndex)
            (chooseAccountView.subviews.first as! OneRowDropDownView).setOneRow(QRDetailView_ShowAccount_Title, chooseAccount ?? Choose_Title)
            if startDate.isEmpty && endDate.isEmpty {
                clickDateBtn(weekDayButton)
            }
            if chooseAccount != nil {
                postGetAcntInfo()
            }
        }
    }
    
    // MARK: - Private
    private func postGetAcntInfo() {
        if currentType != nil && chooseAccount != nil {
            resultList = nil
            tableView.reloadData()
            setLoading(true)
            let date = endDate.isEmpty ? startDate : endDate
            postRequest("QR/QR0901", "QR0901", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"09007","Operate":"getAcntDetail","TransactionId":transactionId,"ACTTYPE":"P","ACTNO":chooseAccount!,"TXSDAY":startDate.replacingOccurrences(of: "/", with: ""),"TXEDAY":date.replacingOccurrences(of: "/", with: "")], true), AuthorizationManage.manage.getHttpHead(true))
        }
    }
    
 
}

