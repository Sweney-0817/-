//
//  ActDetailViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/6/15.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let ActDetailView_ShowDetail_Segue = "ShowDetail"
let ActDetailView_CellTitleList = [ActOverview_TypeList[0]:["交易日期","借款記號","交易金額"],
                                   ActOverview_TypeList[1]:["交易日期","票號","交易金額"],
                                   ActOverview_TypeList[2]:["記帳日","交易金額","結存本金"],
                                   ActOverview_TypeList[3]:["交易日期","攤還本金","本金餘額"]]
let ActDetailView_ShowAccount_Title = "帳號"

class ActDetailViewController: BaseViewController, ChooseTypeDelegate, UITableViewDataSource, UITableViewDelegate, OneRowDropDownViewDelegate, UIActionSheetDelegate {
    @IBOutlet weak var chooseTypeView: ChooseTypeView!    
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
    private var currentType:String? = nil        // 目前選擇的帳戶Type
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
                (chooseAccountView.subviews.first as! OneRowDropDownView).setOneRow(ActDetailView_ShowAccount_Title, chooseAccount ?? Choose_Title)
                chooseTypeView.setTypeList(typeList, setDelegate: self, typeList?.index(of: currentType!))
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
        view.setOneRow(ActDetailView_ShowAccount_Title, Choose_Title)
        chooseAccountView.addSubview(view)
        
        getTransactionID("02041", TransactionID_Description)
        
        /*  規格需求  */
        let date = Date()
        let componenets = Calendar.current.dateComponents([.year, .month, .day], from: date)
        if let day = componenets.day, let month = componenets.month, let year = componenets.year {
            endDate = "\(year)/\(String(format: "%02d", month))/\(String(format: "%02d", day))"
        }
        
        let newDate = Calendar.current.date(byAdding: .day, value: -7, to: date) ?? date
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
        let controller = segue.destination as! ShowDetailViewController
        var list = [[String:String]]()
        if currentType != nil, let dic = resultList?[currentIndex] {
            switch currentType! {
            case ActOverviewType.Type1.description():
                if let TXDAY = dic["TXDAY"] as? String {
                    list.append([Response_Key: "交易日期", Response_Value:TXDAY])
                }
                else {
                    list.append([Response_Key: "交易日期", Response_Value:""])
                }
                if let CRDB = dic["CRDB"] as? String {
                    list.append([Response_Key: "借貸紀號", Response_Value:CRDB == "1" ? "支出" : "存入"])
                }
                else {
                    list.append([Response_Key: "借貸紀號", Response_Value:""])
                }
                if let KINBR = dic["KINBR"] as? String {
                    list.append([Response_Key: "輸入行", Response_Value:KINBR])
                }
                else {
                    list.append([Response_Key: "輸入行", Response_Value:""])
                }
                if let DSCPT = dic["DSCPT"] as? String {
                    list.append([Response_Key: "交易摘要", Response_Value:DSCPT])
                }
                else {
                    list.append([Response_Key: "交易摘要", Response_Value:""])
                }
                if let HCODE = dic["HCODE"] as? String {
                    list.append([Response_Key: "更正記號", Response_Value:HCODE == "0" ? "-" : HCODE])
                }
                else {
                    list.append([Response_Key: "更正記號", Response_Value:""])
                }
                if let TXAMT = dic["TXAMT"] as? String {
                    list.append([Response_Key: "交易金額", Response_Value:TXAMT.separatorThousand()])
                }
                else {
                    list.append([Response_Key: "交易金額", Response_Value:""])
                }
                if let OAVBAL = dic["OAVBAL"] as? String {
                    list.append([Response_Key: "餘額", Response_Value:OAVBAL.separatorThousand()])
                }
                else {
                    list.append([Response_Key: "餘額", Response_Value:""])
                }
                if let MACTNO = dic["MACTNO"] as? String {
                    list.append([Response_Key: "對方帳號", Response_Value:MACTNO])
                }
                else {
                    list.append([Response_Key: "對方帳號", Response_Value:""])
                }
                if let TXRM = dic["TXRM"] as? String {
                    list.append([Response_Key: "備註", Response_Value:TXRM])
                }
                else {
                    list.append([Response_Key: "備註", Response_Value:""])
                }
                
            case ActOverviewType.Type2.description():
                if let TXDAY = dic["TXDAY"] as? String {
                    list.append([Response_Key: "交易日期", Response_Value:TXDAY])
                }
                else {
                    list.append([Response_Key: "交易日期", Response_Value:""])
                }
                if let CKSRT = dic["CKSRT"] as? String {
                    list.append([Response_Key: "票種", Response_Value:CKSRT == "1" ? "支票" : "本票"])
                }
                else {
                    list.append([Response_Key: "票種", Response_Value:""])
                }
                if let CKNO = dic["CKNO"] as? String {
                    list.append([Response_Key: "票號", Response_Value:CKNO])
                }
                else {
                    list.append([Response_Key: "票號", Response_Value:""])
                }
                if let DSCPT = dic["DSCPT"] as? String {
                    list.append([Response_Key: "交易摘要", Response_Value:DSCPT])
                }
                else {
                    list.append([Response_Key: "交易摘要", Response_Value:""])
                }
                if let HCODE = dic["HCODE"] as? String {
                    list.append([Response_Key: "更正記號", Response_Value:HCODE == "0" ? "-" : HCODE])
                }
                else {
                    list.append([Response_Key: "更正記號", Response_Value:""])
                }
                if let CRDB = dic["CRDB"] as? String {
                    list.append([Response_Key: "借貸紀號", Response_Value:CRDB == "1" ? "支出" : "存入"])
                }
                else {
                    list.append([Response_Key: "借貸紀號", Response_Value:""])
                }
                if let TXAMT = dic["TXAMT"] as? String {
                    list.append([Response_Key: "交易金額", Response_Value:TXAMT.separatorThousand()])
                }
                else {
                    list.append([Response_Key: "交易金額", Response_Value:""])
                }
                if let AVBAL = dic["AVBAL"] as? String {
                    list.append([Response_Key: "餘額", Response_Value:AVBAL.separatorThousand()])
                }
                else {
                    list.append([Response_Key: "餘額", Response_Value:""])
                }
                if let REMARK = dic["REMARK"] as? String {
                    list.append([Response_Key: "備註", Response_Value:REMARK])
                }
                else {
                    list.append([Response_Key: "備註", Response_Value:""])
                }
                
            case ActOverviewType.Type3.description():
                if let ENTDAY = dic["ENTDAY"] as? String {
                    list.append([Response_Key: "記帳日", Response_Value:ENTDAY])
                }
                else {
                    list.append([Response_Key: "記帳日", Response_Value:""])
                }
                if let TRNACT = dic["TRNACT"] as? String {
                    list.append([Response_Key: "對方帳號", Response_Value:TRNACT])
                }
                else {
                    list.append([Response_Key: "對方帳號", Response_Value:""])
                }
                if let TXCD = dic["TXCD"] as? String {
                    list.append([Response_Key: "交易代號", Response_Value:TXCD])
                }
                else {
                    list.append([Response_Key: "交易代號", Response_Value:""])
                }
                if let HCODE = dic["HCODE"] as? String {
                    list.append([Response_Key: "更正記號", Response_Value:HCODE == "0" ? "-" : HCODE])
                }
                else {
                    list.append([Response_Key: "更正記號", Response_Value:""])
                }
                if let TAXAMT = dic["TAXAMT"] as? String {
                    list.append([Response_Key: "所得稅", Response_Value:TAXAMT.separatorThousand()])
                }
                else {
                    list.append([Response_Key: "所得稅", Response_Value:""])
                }
                if let PRTAX = dic["PRTAX"] as? String {
                    list.append([Response_Key: "印花稅", Response_Value:PRTAX.separatorThousand()])
                }
                else {
                    list.append([Response_Key: "印花稅", Response_Value:""])
                }
                if let BALNINT = dic["BALNINT"] as? String {
                    list.append([Response_Key: "淨利/結存本金", Response_Value:BALNINT.separatorThousand()])
                }
                else {
                    list.append([Response_Key: "淨利/結存本金", Response_Value:""])
                }
                if let PRIBAL = dic["PRIBAL"] as? String {
                    list.append([Response_Key: "補充保費", Response_Value:PRIBAL.separatorThousand()])
                }
                else {
                    list.append([Response_Key: "補充保費", Response_Value:""])
                }
                if let AMTINT = dic["AMTINT"] as? String {
                    list.append([Response_Key: "交易金額", Response_Value:AMTINT.separatorThousand()])
                }
                else {
                    list.append([Response_Key: "交易金額", Response_Value:""])
                }
                if let LOWIRT = dic["LOWIRT"] as? String {
                    list.append([Response_Key: "利率", Response_Value:LOWIRT])
                }
                else {
                    list.append([Response_Key: "利率", Response_Value:""])
                }
                
            case ActOverviewType.Type4.description():
                if let TXDATE = dic["TXDATE"] as? String {
                    list.append([Response_Key: "交易日期", Response_Value:TXDATE])
                }
                else {
                    list.append([Response_Key: "交易日期", Response_Value:""])
                }
                if let TXCD = dic["TXCD"] as? String {
                    list.append([Response_Key: "交易代號", Response_Value:TXCD])
                }
                else {
                    list.append([Response_Key: "交易代號", Response_Value:""])
                }
                if let PRIAMT = dic["PRIAMT"] as? String {
                    list.append([Response_Key: "攤還本金/本金", Response_Value:PRIAMT.separatorThousand()])
                }
                else {
                    list.append([Response_Key: "攤還本金/本金", Response_Value:""])
                }
                if let INTAMT = dic["INTAMT"] as? String {
                    list.append([Response_Key: "利息", Response_Value:INTAMT])
                }
                else {
                    list.append([Response_Key: "利息", Response_Value:""])
                }
                if let BAL = dic["BAL"] as? String {
                    list.append([Response_Key: "本金餘額", Response_Value:BAL.separatorThousand()])
                }
                else {
                    list.append([Response_Key: "本金餘額", Response_Value:""])
                }
                if let DFAMT = dic["DFAMT"] as? String {
                    list.append([Response_Key: "違約金", Response_Value:DFAMT.separatorThousand()])
                }
                else {
                    list.append([Response_Key: "違約金", Response_Value:""])
                }
                if let DIAMT = dic["DIAMT"] as? String {
                    list.append([Response_Key: "延遲息", Response_Value:DIAMT.separatorThousand()])
                }
                else {
                    list.append([Response_Key: "延遲息", Response_Value:""])
                }
                
            default: break
            }
            controller.setList("\(currentType!)往來明細", list)
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
        if currentType != nil, let type = GetTypeByInputString(currentType!), let dic = resultList?[indexPath.row] {
            cell.title1Label.text = ActDetailView_CellTitleList[currentType!]?[0]
            cell.title2Label.text = ActDetailView_CellTitleList[currentType!]?[1]
            cell.title3Label.text = ActDetailView_CellTitleList[currentType!]?[2]
            switch type{
            case .Type1:
                if let TXDAY = dic["TXDAY"] as? String {
                    cell.detail1Label.text = TXDAY
                }
                if let CRDB = dic["CRDB"] as? String {
                    cell.detail2Label.text = CRDB == "1" ? "支出" : "存入"
                }
                if let TXAMT = dic["TXAMT"] as? String {
                    cell.detail3Label.text = TXAMT.separatorThousand()
                }
                
            case .Type2:
                if let TXDAY = dic["TXDAY"] as? String {
                    cell.detail1Label.text = TXDAY
                }
                if let CKNO = dic["CKNO"] as? String {
                    cell.detail2Label.text = CKNO
                }
                if let TXAMT = dic["TXAMT"] as? String {
                    cell.detail3Label.text = TXAMT.separatorThousand()
                }
            
            case .Type3:
                if let ENTDAY = dic["ENTDAY"] as? String {
                    cell.detail1Label.text = ENTDAY
                }
                if let AMTINT = dic["AMTINT"] as? String {
                    cell.detail2Label.text = AMTINT.separatorThousand()
                }
                if let BALNINT = dic["BALNINT"] as? String {
                    cell.detail3Label.text = BALNINT.separatorThousand()
                }
            
            case .Type4:
                if let TXDAY = dic["TXDAY"] as? String {
                    cell.detail1Label.text = TXDAY
                }
                if let PRIAMT = dic["PRIAMT"] as? String {
                    cell.detail2Label.text = PRIAMT.separatorThousand()
                }
                if let BAL = dic["BAL"] as? String {
                    cell.detail3Label.text = BAL.separatorThousand()
                }
                
            default: break
            }
            
        }
        return cell
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else {
                super.didResponse(description, response)
            }
            
        case "ACCT0101":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]]{
                typeList = [String]()
                for category in array {
                    if let type = category["ACTTYPE"] as? String, let result = category["AccountInfo"] as? [[String:Any]] {
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
                            
                        case "K":
                            categoryType[ActOverview_TypeList[1]] = type
                            categoryList[type] = [AccountStruct]()
                            addType = true
                            if typeList?.index(of: ActOverviewType.Type2.description()) == nil {
                                typeList?.append(ActOverviewType.Type2.description())
                            }
                            
                        case "T":
                            categoryType[ActOverview_TypeList[2]] = type
                            categoryList[type] = [AccountStruct]()
                            addType = true
                            if typeList?.index(of: ActOverviewType.Type3.description()) == nil {
                                typeList?.append(ActOverviewType.Type3.description())
                            }
                            
                        case "L":
                            categoryType[ActOverview_TypeList[3]] = type
                            categoryList[type] = [AccountStruct]()
                            addType = true
                            if typeList?.index(of: ActOverviewType.Type4.description()) == nil {
                                typeList?.append(ActOverviewType.Type4.description())
                            }
                            
                        default: break
                        }
                        
                        if addType {
                            for actInfo in result {
                                if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? String, let ebkfg = actInfo["EBKFG"] as? String, ebkfg == Account_EnableTrans {
                                    categoryList[type]?.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
                                }
                            }
                        }
                    }
                }
                
                if typeList?.count != 0 {
                    if currentType != nil {
                        chooseTypeView.setTypeList(typeList, setDelegate: self, typeList?.index(of: currentType!))
                    }
                    else {
                        currentType = typeList?.first
                        chooseTypeView.setTypeList(typeList, setDelegate: self)
                    }
                    
                    if chooseAccount != nil {
                        (chooseAccountView.subviews.first as! OneRowDropDownView).setOneRow(ActDetailView_ShowAccount_Title, chooseAccount!)
                        clickDateBtn(weekDayButton)
                        postGetAcntInfo()
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
            
        case "ACIF0201":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let result = data["Result"] as? [[String:Any]] {
                resultList = result
            }
            else {
                resultList = nil
            }
            tableView.reloadData()
            
        default: super.didResponse(description, response)
        }
    }

    // MARK: - ChooseTypeDelegate
    func clickChooseTypeBtn(_ name:String) {
        currentType = name
        chooseAccount = nil
        (chooseAccountView.subviews.first as! OneRowDropDownView).setOneRow(ActDetailView_ShowAccount_Title, Choose_Title)
        resultList = nil
        tableView.reloadData()
    }
    
    // MARK: - StoryBoadr Touch Event
    @IBAction func clickDateBtn(_ sender: Any) {
        if (chooseAccountView.subviews.first as! OneRowDropDownView).getContentByType(.First) == Choose_Title {
            showErrorMessage(nil, Choose_Title+(currentType ?? "")+ActDetailView_ShowAccount_Title)
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
                endDate = "\(year)/\(String(format: "%02d", month))/\(day)"
            }
            
            let newDate = Calendar.current.date(byAdding: .day, value: -7, to: date) ?? date
            let startComponenets = Calendar.current.dateComponents([.year, .month, .day], from: newDate)
            if let day = startComponenets.day, let month = startComponenets.month, let year = startComponenets.year {
                startDate = "\(year)/\(String(format: "%02d", month))/\(String(format: "%02d", day))"
            }
            postGetAcntInfo()
            dateLabel.text = startDate + (endDate != "" ? " - \(endDate)" : "")
            
        case customizeDayButton:
            if let dateView = getUIByID(.UIID_DatePickerView) as? DatePickerView {
                dateView.frame = view.frame
                dateView.frame.origin = .zero
                dateView.showTwoDatePickerView(true, nil, nil) { start, end, sDate, eDate in
                    var componenets = Calendar.current.dateComponents([.year, .month, .day], from: sDate!)
                    componenets.month = componenets.month!+2
                    if Calendar.current.compare(Calendar.current.date(from: componenets)!, to: eDate!, toGranularity: .day) == .orderedAscending {
                        self.showErrorMessage(nil, ErrorMsg_DateMonthOnlyTwo)
                    }
                    else {
                        self.startDate = "\(start.year)/\(start.month)/\(start.day)"
                        self.endDate = "\(end.year)/\(end.month)/\(end.day)"
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
        performSegue(withIdentifier: ActDetailView_ShowDetail_Segue, sender: nil)
    }
    
    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        if currentType != nil {
            let act = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
            if let type = categoryType[currentType!], let list = categoryList[type] {
                for info in list {
                    act.addButton(withTitle: info.accountNO)
                }
            }
            act.show(in: view)
        }
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            chooseAccount = actionSheet.buttonTitle(at: buttonIndex)
            (chooseAccountView.subviews.first as! OneRowDropDownView).setOneRow(ActDetailView_ShowAccount_Title, chooseAccount ?? Choose_Title)
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
        if currentType != nil && chooseAccount != nil, let type = categoryType[currentType!] {
            setLoading(true)
            let date = endDate.isEmpty ? startDate : endDate
            postRequest("ACIF/ACIF0201", "ACIF0201", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02041","Operate":"getAcntInfo","TransactionId":transactionId,"ACTTYPE":type,"ACTNO":chooseAccount!,"TXSDAY":startDate.replacingOccurrences(of: "/", with: ""),"TXEDAY":date.replacingOccurrences(of: "/", with: "")], true), AuthorizationManage.manage.getHttpHead(true))
        }
    }
    
    private func GetTypeByInputString(_ input:String) -> ActOverviewType? {
        var type:ActOverviewType? = nil
        switch input {
        case ActOverviewType.Type1.description(): type = .Type1
        case ActOverviewType.Type2.description(): type = .Type2
        case ActOverviewType.Type3.description(): type = .Type3
        case ActOverviewType.Type4.description(): type = .Type4
        default: break
        }
        return type
    }
    
}
