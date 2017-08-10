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
let ActDetailView_ChooseAccount_Title = "請選擇查詢帳號"
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
    private var categoryList = [String:[ActOverviewStruct]]() // Key: 電文(ACCT0101)response的"ACTTYPE"
    private var categoryType = [String:String]() // Key: ActOverviewType.description() value: 電文(ACCT0101)response的"ACTTYPE"
    private var currentType:String? = nil        // 目前選擇的帳戶Type
    private var chooseAccount:String? = nil      // 目前選擇得帳號
    private var startDate = ""                   // 起始日
    private var endDate = ""                     // 截止日
    private var resultList:[[String:Any]]? = nil
    private var typeList:[String]? = nil         // 使用者帳戶清單的Type List
    
    // MARK: - public
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
    }
    
    func SetInitial(_ type:String?, _ account:String?)  {
        currentType = type
        chooseAccount = account
        if currentType != nil && chooseAccount != nil {
            if categoryType[currentType!] != nil {
            //  電文已經reponse SetInitial晚 
                (chooseAccountView.subviews.first as! OneRowDropDownView).setOneRow(ActDetailView_ShowAccount_Title, chooseAccount ?? ActDetailView_ChooseAccount_Title)
                chooseTypeView.setTypeList(typeList, setDelegate: self, typeList?.index(of: currentType!))
                setLoading(true)
                PostGetAcntInfo()
            }
        }
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: UIID.UIID_OverviewCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_OverviewCell.NibName()!)

        setShadowView(transDayView)
        let view = getUIByID(.UIID_OneRowDropDownView) as! OneRowDropDownView
        view.frame = chooseAccountView.frame
        view.frame.origin = .zero
        view.delegate = self
        view.setOneRow(ActDetailView_ShowAccount_Title, ActDetailView_ChooseAccount_Title)
        chooseAccountView.addSubview(view)
        
        clickDateBtn(weekDayButton)
        
        setLoading(true)
        getTransactionID("02041", TransactionID_Description)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            case .Type0:
                if let TXDAY = dic["TXDAY"] as? String {
                    cell.detail1Label.text = TXDAY
                }
                
                
            default: break
            }
            
        }
        return cell
    }

    // MARK: - ChooseTypeDelegate
    func clickChooseTypeBtn(_ name:String) {
        currentType = name
        chooseAccount = nil
        (chooseAccountView.subviews.first as! OneRowDropDownView).setOneRow(ActDetailView_ShowAccount_Title, ActDetailView_ChooseAccount_Title)
        resultList = nil
        tableView.reloadData()
    }
    
    // MARK: - Xib Event
    @IBAction func clickDateBtn(_ sender: Any) {
        let btn = (sender as! UIButton)
        switch btn {
        case theDayButton:
            let date = Date()
            startDate = "\(String(Calendar.current.component(.year, from: date)))/\(String(Calendar.current.component(.month, from: date)))/\(String(Calendar.current.component(.day, from: date)))"
//                let formatter = DateFormatter()
//                formatter.dateFormat = "yyyy/MM/dd"
//                startDate = formatter.string(from: date)
            
        case weekDayButton:
            let date = Date()
            startDate = "\(String(Calendar.current.component(.year, from: date)))/\(String(Calendar.current.component(.month, from: date)))/\(String(Calendar.current.component(.day, from: date)))"
            var newDateComponents = DateComponents()
            newDateComponents.day = 7
            let newDate  = Calendar.current.date(byAdding: newDateComponents, to: date) ?? date
            endDate = "\(String(Calendar.current.component(.year, from: newDate)))/\(String(Calendar.current.component(.month, from: newDate)))/\(String(Calendar.current.component(.day, from: newDate)))"
            
        case customizeDayButton:
            ShowDatePickerView()
            
        default: break
        }
        
        dateLabel.text = startDate + (endDate != "" ? "- \(endDate)" : "")
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ActDetailView_ShowDetail_Segue, sender: nil)
    }
    
    // MARK: - Selector
    func clickDetermineBtn(_ sender:Any) {
        if let datePickerView = view.viewWithTag(ViewTag.View_DoubleDatePickerBackground.rawValue) {
            datePickerView.removeFromSuperview()
        }
    }
    
    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        if currentType != nil {
            let act = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: UIActionSheet_Cancel_Title, destructiveButtonTitle: nil)
            if let type = categoryType[currentType!],  let list = categoryList[type] {
                for info in list {
                    act.addButton(withTitle: info.accountNO)
                }
            }
            act.show(in: view)
        }
    }
    
    // MARK: - ConnectionUtilityDelegate
    override func didRecvdResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: "Data") as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"1"], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else {
                super.didRecvdResponse(description, response)
            }
        
        case "ACCT0101":
            if let data = response.object(forKey: "Data") as? [String:Any], let array = data["Result"] as? [[String:Any]]{
                typeList = [String]()
                for category in array {
                    if let type = category["ACTTYPE"] as? String, let result = category["Result"] as? [[String:Any]] {
                        var addType = false
                        // "ACTTYPE"->帳號類別: 活存：P, 支存：K, 定存：T, 放款：L, 綜存：M
                        switch type {
                        case "P":
                            categoryType[ActOverview_TypeList[0]] = type
                            categoryList[type] = [ActOverviewStruct]()
                            addType = true
                            if typeList?.index(of: ActOverviewType.Type1.description()) == nil {
                                typeList?.append(ActOverviewType.Type1.description())
                            }
                            
                        case "K":
                            categoryType[ActOverview_TypeList[1]] = type
                            categoryList[type] = [ActOverviewStruct]()
                            addType = true
                            if typeList?.index(of: ActOverviewType.Type2.description()) == nil {
                                typeList?.append(ActOverviewType.Type2.description())
                            }
                            
                        case "T":
                            categoryType[ActOverview_TypeList[2]] = type
                            categoryList[type] = [ActOverviewStruct]()
                            addType = true
                            if typeList?.index(of: ActOverviewType.Type3.description()) == nil {
                                typeList?.append(ActOverviewType.Type3.description())
                            }
                            
                        case "L":
                            categoryType[ActOverview_TypeList[3]] = type
                            categoryList[type] = [ActOverviewStruct]()
                            addType = true
                            if typeList?.index(of: ActOverviewType.Type4.description()) == nil {
                                typeList?.append(ActOverviewType.Type4.description())
                            }
                            
                        default: break
                        }
                        
                        if addType {
                            for actInfo in result {
                                if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? Double, let ebkfg = actInfo["EBKFG"] as? Int, ebkfg == ActOverview_Account_EnableTrans {
                                    categoryList[type]?.append(ActOverviewStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
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
                        PostGetAcntInfo()
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
                super.didRecvdResponse(description, response)
            }
            
        case "ACIF0201":
            setLoading(false)
            if let data = response.object(forKey: "Data") as? [String:Any], let result = data["Result"] as? [[String:Any]] {
                resultList = result
                tableView.reloadData()
            }
            
        default: break
        }
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            chooseAccount = actionSheet.buttonTitle(at: buttonIndex)
            (chooseAccountView.subviews.first as! OneRowDropDownView).setOneRow(ActDetailView_ShowAccount_Title, chooseAccount ?? ActDetailView_ChooseAccount_Title)
            if chooseAccount != nil {
                setLoading(true)
                PostGetAcntInfo()
            }
        }
    }
    
    // MARK: - Private
    private func ShowDatePickerView() {
        let background = UIView(frame: view.frame)
        background.backgroundColor = Gray_Color
        background.tag = ViewTag.View_DoubleDatePickerBackground.rawValue
        view.addSubview(background)
        
        let start = UIDatePicker(frame: CGRect.init(x: 30, y: 130, width: 320, height: 200))
        start.datePickerMode = .date
        start.locale = Locale(identifier: "zh_CN")
        start.backgroundColor = .white
        background.addSubview(start)
        
        let startLabel = UILabel(frame: CGRect.init(x: 30, y: 100, width: 320, height: 30))
        startLabel.text = "起始日"
        startLabel.font = Cell_Font_Size
        startLabel.backgroundColor = Green_Color
        startLabel.textAlignment = .center
        startLabel.textColor = .white
        background.addSubview(startLabel)
        
        let end = UIDatePicker(frame: CGRect.init(x: 30, y: 380, width: 320, height: 200))
        end.backgroundColor = .white
        end.datePickerMode = .date
        end.locale = Locale(identifier: "zh_CN")
        background.addSubview(end)
        
        let endLabel = UILabel(frame: CGRect.init(x: 30, y: 350, width: 320, height: 30))
        endLabel.text = "截止日"
        endLabel.font = Cell_Font_Size
        endLabel.backgroundColor = Green_Color
        endLabel.textAlignment = .center
        endLabel.textColor = .white
        background.addSubview(endLabel)
        
        let button = UIButton(frame: CGRect.init(x: 30, y: 590, width: 320, height: 40))
        button.setBackgroundImage(UIImage.init(named: ImageName.ButtonLarge.rawValue), for: .normal)
        button.tintColor = .white
        button.setTitle("確定", for: .normal)
        button.addTarget(self, action: #selector(clickDetermineBtn(_:)), for: .touchUpInside)
        background.addSubview(button)
    }
    
    private func PostGetAcntInfo() {
        postRequest("ACIF/ACIF0201", "ACIF0201", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02041","Operate":"getAcntInfo","TransactionId":transactionId,"ACTTYPE":categoryType[currentType!] ?? "","ACTNO":chooseAccount!,"TXSDAY":startDate,"TXEDAY":endDate], true), AuthorizationManage.manage.getHttpHead(true))
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
        
}
