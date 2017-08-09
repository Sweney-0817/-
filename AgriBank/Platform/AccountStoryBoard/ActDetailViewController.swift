//
//  ActDetailViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/6/15.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let ActDetailView_ShowDetail_Segue = "ShowDetail"
let ActDetailView_TypeList = ["活期存款","支票存款","定期存款","放款"]
let ActDetailView_CellTitleList = [ActDetailView_TypeList[0]:["交易日期","借款記號","交易金額"],
                                   ActDetailView_TypeList[1]:["交易日期","票號","交易金額"],
                                   ActDetailView_TypeList[2]:["記帳日","交易金額","結存本金"],
                                   ActDetailView_TypeList[3]:["交易日期","攤還本金","本金餘額"]]

class ActDetailViewController: BaseViewController, ChooseTypeDelegate, UITableViewDataSource, UITableViewDelegate, OneRowDropDownViewDelegate {
    @IBOutlet weak var chooseTypeView: ChooseTypeView!    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var transDayView: UIView!
    @IBOutlet weak var chooseAccountView: UIView!
    private var typeListIndex = 0
    private var chooseAccount:String? = nil
    private var categoryList = [String:[ActOverviewStruct]]()
    private var categoryType = [String:String]()
    private var typeList = ActDetailView_TypeList
    
    // MARK: - public
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
    }
    
    func SetInitial(_ currentType:String?, _ account:String?)  {
        if currentType != nil && account != nil {
            typeListIndex = ActDetailView_TypeList.index(of: currentType!) ?? typeListIndex
            chooseTypeView.setTypeList(ActDetailView_TypeList, setDelegate: self, typeListIndex)
            chooseAccount = account
        }
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        chooseTypeView.setTypeList(ActDetailView_TypeList, setDelegate: self, typeListIndex)
        
        tableView.register(UINib(nibName: UIID.UIID_OverviewCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_OverviewCell.NibName()!)

        setShadowView(transDayView)
        let view = getUIByID(.UIID_OneRowDropDownView) as! OneRowDropDownView
        view.frame = chooseAccountView.frame
        view.frame.origin = .zero
        view.setOneRow("帳號", "")
        chooseAccountView.addSubview(view)
        
        setLoading(true)
        getTransactionID("02002", TransactionID_Description)
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
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_OverviewCell.NibName()!, for: indexPath) as! OverviewCell
        cell.title1Label.text = ActDetailView_CellTitleList[typeList[typeListIndex]]?[0]
        cell.title2Label.text = ActDetailView_CellTitleList[typeList[typeListIndex]]?[1]
        cell.title3Label.text = ActDetailView_CellTitleList[typeList[typeListIndex]]?[2]
        return cell
    }

    // MARK: - ChooseTypeDelegate
    func clickChooseTypeBtn(_ name:String) {
    }
    
    // MARK: - Xib Event
    @IBAction func clickDateBtn(_ sender: Any) {
        let btn = (sender as! UIButton)
        if btn.title(for: .normal) == "自訂" {
            let background = UIView.init(frame: view.frame)
            background.backgroundColor = Gray_Color
            background.tag = ViewTag.View_DoubleDatePickerBackground.rawValue
            view.addSubview(background)
            
            let start = UIDatePicker.init(frame: CGRect.init(x: 30, y: 130, width: 320, height: 200))
            start.datePickerMode = .date
            start.locale = Locale(identifier: "zh_CN")
            start.backgroundColor = .white
            background.addSubview(start)
            
            let startLabel = UILabel.init(frame: CGRect.init(x: 30, y: 100, width: 320, height: 30))
            startLabel.text = "起始日"
            startLabel.font = Cell_Font_Size
            startLabel.backgroundColor = Green_Color
            startLabel.textAlignment = .center
            startLabel.textColor = .white
            background.addSubview(startLabel)
            
            let end = UIDatePicker.init(frame: CGRect.init(x: 30, y: 380, width: 320, height: 200))
            end.backgroundColor = .white
            end.datePickerMode = .date
            end.locale = Locale(identifier: "zh_CN")
            background.addSubview(end)
            
            let endLabel = UILabel.init(frame: CGRect.init(x: 30, y: 350, width: 320, height: 30))
            endLabel.text = "截止日"
            endLabel.font = Cell_Font_Size
            endLabel.backgroundColor = Green_Color
            endLabel.textAlignment = .center
            endLabel.textColor = .white
            background.addSubview(endLabel)
            
            let button = UIButton.init(frame: CGRect.init(x: 30, y: 590, width: 320, height: 40))
            button.setBackgroundImage(UIImage.init(named: ImageName.ButtonLarge.rawValue), for: .normal)
            button.tintColor = .white
            button.setTitle("確定", for: .normal)
            button.addTarget(self, action: #selector(clickDetermineBtn(_:)), for: .touchUpInside)
            background.addSubview(button)
        }
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
        
    }
    
    // MARK: - ConnectionUtilityDelegate
    override func didRecvdResponse(_ description:String, _ response: NSDictionary) {
        setLoading(false)
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
                typeList.removeAll()
                for category in array {
                    if let type = category["ACTTYPE"] as? String, let result = category["Result"] as? [[String:Any]] {
                        // "ACTTYPE"->帳號類別: 活存：P, 支存：T, 定存：K, 放款：L, 綜存：M
                        switch type {
                        case "P":
                            categoryType[ActOverview_TypeList[0]] = type
                            categoryList[type] = [ActOverviewStruct]()
                        case "T":
                            categoryType[ActOverview_TypeList[1]] = type
                            categoryList[type] = [ActOverviewStruct]()
                        case "K":
                            categoryType[ActOverview_TypeList[2]] = type
                            categoryList[type] = [ActOverviewStruct]()
                        case "L":
                            categoryType[ActOverview_TypeList[3]] = type
                            categoryList[type] = [ActOverviewStruct]()
                        default: break
                        }
                        for actInfo in result {
                            if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? Double, let ebkfg = actInfo["EBKFG"] as? Int {
                                categoryList[type]?.append(ActOverviewStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
                            }
                        }
                    }
                }
                tableView.reloadData()
            }
            
        default: break
        }
    }
}
