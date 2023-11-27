//
//  QRTaipowerDetailViewController.swift
//  AgriBank
//
//  Created by ABOT on 2021/12/29.
//  Copyright © 2021 Systex. All rights reserved.
//

import UIKit

let QRTPDetailView_ShowDetail_Segue = "ShowTPDetail"
let QRTPDetailView_CellTitleList = ["帳單期別","載具號碼","應繳總額"]
let QRTPDetailView_ShowAccount_Title = "電號"
let QRTPBarTitle = "台電交易紀錄"
 
class QRTaipowerDetailViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, OneRowDropDownViewDelegate, UIActionSheetDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var transDayView: UIView!
    @IBOutlet weak var chooseAccountView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var theDayButton: UIButton!
    @IBOutlet weak var weekDayButton: UIButton!
    @IBOutlet weak var customizeDayButton: UIButton!
    @IBOutlet weak var dateTypeLabel: UILabel!
    
    private var categoryList =  [String]()// Key: 電文(ACCT0101)response的"powerno"
    private var categoryType = [String:String]() // Key: ActOverviewType.description() value: 電文(ACCT0101)response的"ACTTYPE"
 
    private var choosePowerNo:String? = nil      // 目前選擇得電號
    private var startDate = ""                   // 起始日
    private var endDate = ""                     // 截止日
    private var resultList:[[String:Any]]? = nil // 電文response
    private var typeList:[String]? = nil         // 使用者帳戶清單的Type List
    private var currentIndex = 0                 // resultList Index
    // MARK: - Public
    func setInitial(_ type:String?, _ powerno:String?)  {
        choosePowerNo = powerno
        if choosePowerNo != nil {
            (chooseAccountView.subviews.first as! OneRowDropDownView).setOneRow(QRTPDetailView_ShowAccount_Title, choosePowerNo ?? Choose_Title)
            clickDateBtn(weekDayButton)
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
        getTransactionID("09013", TransactionID_Description)
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
        let controller = segue.destination as! ShowQRTaipowerDetailController
        var list = [[String:String]]()
      
        if  let dic = resultList?[currentIndex] {
            
            if let powerNo = dic["powerNo"] as? String {
                list.append([Response_Key: "電號", Response_Value: powerNo])
            }
            else {
                list.append([Response_Key: "電號", Response_Value:""])
            }
            
            
            if let Ym = dic["Ym"] as? String {
                list.append([Response_Key: "帳單期別", Response_Value:Ym])
            }
            else {
                list.append([Response_Key: "帳單期別", Response_Value:""])
            }
            
            if let TransDt = dic["TransDt"] as? String {
                list.append([Response_Key: "交易時間", Response_Value:TransDt])
            }
            else {
                list.append([Response_Key: "交易時間", Response_Value:""])
            }
            
            if let transID = dic["TransID"] as? String {
                list.append([Response_Key: "交易序號", Response_Value:transID.separatorThousand()])
            }
            else {
                list.append([Response_Key: "交易序號", Response_Value:""])
            }
            
            if let Invoice = dic["Invoice"] as? String {
                list.append([Response_Key: "載具號碼", Response_Value:Invoice ])
            }
            else {
                list.append([Response_Key: "載具號碼", Response_Value:"" ])
            }
            if let Invoice = dic["Amt"] as? String {
                list.append([Response_Key: "應繳總金額", Response_Value:Invoice ])
            }
            else {
                list.append([Response_Key: "應繳總金額", Response_Value:"" ])
            }
            
            controller.setList(QRTPBarTitle, list)
            
        }
    }
    
        // MARK: - UITableViewDataSource
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            var count = 0
            count = resultList?.count ?? 0
            return count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_OverviewCell.NibName()!, for: indexPath) as! OverviewCell
            if  let dic = resultList?[indexPath.row] {
                cell.title1Label.text = QRTPDetailView_CellTitleList[0]
                cell.title2Label.text = QRTPDetailView_CellTitleList[1]
                cell.title3Label.text = QRTPDetailView_CellTitleList[2]
                    if let Ym = dic["Ym"] as? String {
                        cell.detail1Label.text = Ym
                    }
                    if let Invoice = dic["Invoice"] as? String {
                        cell.detail2Label.text = Invoice
                    }
                    if let Amt = dic["Amt"] as? String {
                        cell.detail3Label.text = Amt.separatorThousand()
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
                    postRequest("QR/QR0506", "QR0506", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10002","Operate":"getPowerNoList","TransactionId":transactionId ], true), AuthorizationManage.manage.getHttpHead(true))
                }
                else {
                    super.didResponse(description, response)
                }
                
            case "QR0506":
                if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]]{
                    for category in array {
                        if let powerNo = category["powerNo"] as? String {
                            categoryList.append(powerNo)
                        }
                    }
                    if categoryList.count != 0 {
                        choosePowerNo = categoryList[0]
                        if choosePowerNo != nil {
                            (chooseAccountView.subviews.first as! OneRowDropDownView).setOneRow(QRTPDetailView_ShowAccount_Title, choosePowerNo!)
                            clickDateBtn(weekDayButton)
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
                
                
            case "QR0507":
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
            showErrorMessage(nil, Choose_Title + QRTPDetailView_ShowAccount_Title)
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
            postGetTaiPowerInfo()
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
            postGetTaiPowerInfo()
            dateLabel.text = startDate + (endDate != "" ? " - \(endDate)" : "")
            
        case customizeDayButton:
            if let dateView = getUIByID(.UIID_DatePickerView) as? DatePickerView {
                dateView.frame = CGRect(origin: .zero, size: view.frame.size)
                dateView.showTwoDatePickerView(true, nil, nil) { [self] start, end, sDate, eDate in
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
                        postGetTaiPowerInfo()
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
        performSegue(withIdentifier: QRTPDetailView_ShowDetail_Segue, sender: nil)
    }
                                 
    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
            if categoryList.count > 0 {
                let tpno = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
                for info in categoryList {
                    tpno.addButton(withTitle: info)
                }
                tpno.show(in: view)
            }
            else {
                showErrorMessage(nil, "\(Get_Null_Title)\(sender.m_lbFirstRowTitle.text!)")
 
        }
    }
                                 
                                 // MARK: - UIActionSheetDelegate
                                 func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
                    if buttonIndex != actionSheet.cancelButtonIndex {
                        choosePowerNo = actionSheet.buttonTitle(at: buttonIndex)
                        (chooseAccountView.subviews.first as! OneRowDropDownView).setOneRow(QRTPDetailView_ShowAccount_Title, choosePowerNo ?? Choose_Title)
                        if startDate.isEmpty && endDate.isEmpty {
                            clickDateBtn(weekDayButton)
                        }
                        if choosePowerNo != nil {
                            postGetTaiPowerInfo()
                        }
                    }
                }
                                 
    // MARK: - Private
    private func postGetTaiPowerInfo() {
        if  choosePowerNo != nil {
            resultList = nil
            tableView.reloadData()
            setLoading(true)
            let date = endDate.isEmpty ? startDate : endDate
            postRequest("QR/QR0507", "QR0507", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"09013","Operate":"getTaipowerData","TransactionId":transactionId ,"powerNo":choosePowerNo!,"INQSDY":startDate.replacingOccurrences(of: "/", with: ""),"INQEDY":date.replacingOccurrences(of: "/", with: "")], true), AuthorizationManage.manage.getHttpHead(true))
        }
    }
    
}
