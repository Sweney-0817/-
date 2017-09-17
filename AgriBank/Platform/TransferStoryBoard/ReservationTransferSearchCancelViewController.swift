//
//  ReservationTransferSearchCancelViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/3.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let ReservationTransferSearchCancel_Segue = "GoReservationDetail"
let ReservationTransferSearchCancel_OutAccount = "轉出帳號"
let ReservationTransferSearchCancel_LoginInterval = "登入區間"
let ReservationTransferSearchCancel_CellTitle = ["登入日期","轉入帳號","金額"]

class ReservationTransferSearchCancelViewController: BaseViewController, OneRowDropDownViewDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate {
    @IBOutlet weak var specificDateBtn: UIButton!
    @IBOutlet weak var fixedDateBtn: UIButton!
    @IBOutlet weak var chooseAccountView: UIView!
    @IBOutlet weak var loginIntervalView: UIView!
    @IBOutlet weak var tableView: UITableView!
    private var chooseAccountDorpView:OneRowDropDownView? = nil
    private var loginIntervalDropView:OneRowDropDownView? = nil
    private var accountList:[AccountStruct]? = nil      // 帳號列表
    private var startDate = ""
    private var endDate = ""
    private var isSpecific = true
    private var resultList = [[String:String]]()
    private var curResultIndex:Int? = nil
    
    // MARK: - Override
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! ReservationTransferDetailViewController
        controller.transactionId = transactionId
        var list = [[String:String]]()
        var input = ReservationTransDetailStruct()
        input.outAccount = chooseAccountDorpView?.getContentByType(.First) ?? ""
        if curResultIndex != nil && curResultIndex! < resultList.count {
            let dic = resultList[curResultIndex!]
            if let RGDAY = dic["RGDAY"] {
                input.loginDate = RGDAY
                list.append([Response_Key:"登錄日期", Response_Value:RGDAY])
            }
            else {
                list.append([Response_Key:"登錄日期", Response_Value:""])
            }
            if let RVDAY = dic["RVDAY"] {
                input.reservationTransDate = RVDAY
                list.append([Response_Key:"預約轉帳日", Response_Value:RVDAY])
            }
            else {
                list.append([Response_Key:"預約轉帳日", Response_Value:""])
            }
            if let LSTDT = dic["LSTDT"] {
                list.append([Response_Key:"上次轉帳日期", Response_Value:LSTDT])
            }
            else {
                list.append([Response_Key:"上次轉帳日期", Response_Value:""])
            }
            if let TXTNO = dic["TXTNO"] {
                input.serialNumber = TXTNO
                list.append([Response_Key:"登錄序號", Response_Value:TXTNO])
            }
            else {
                list.append([Response_Key:"登錄序號", Response_Value:""])
            }
            if let TRACTNO = dic["TRACTNO"] {
                list.append([Response_Key:"轉入帳號", Response_Value:TRACTNO])
            }
            else {
                list.append([Response_Key:"轉入帳號", Response_Value:""])
            }
            if let TRBANK = dic["TRBANK"] {
                input.bankCode = TRBANK
                list.append([Response_Key:"銀行代碼", Response_Value:TRBANK])
            }
            else {
                list.append([Response_Key:"銀行代碼", Response_Value:""])
            }
            if let AMOUNT = dic["AMOUNT"] {
                input.amount = AMOUNT
                list.append([Response_Key:"金額", Response_Value:AMOUNT])
            }
            else {
                list.append([Response_Key:"金額", Response_Value:""])
            }
            if let DSCPTX = dic["DSCPTX"] {
                input.memo = DSCPTX
                list.append([Response_Key:"交易備註", Response_Value:DSCPTX])
            }
            else {
                list.append([Response_Key:"交易備註", Response_Value:""])
            }
            if let ERRCODE = dic["ERRCODE"] {
                list.append([Response_Key:"處理結果", Response_Value:ERRCODE])
            }
            else {
                list.append([Response_Key:"處理結果", Response_Value:""])
            }
            if let TRACTNO = dic["TRACTNO"] {
                input.inAccount = TRACTNO
            }
        }
        controller.setList(list, input)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        chooseAccountDorpView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        chooseAccountDorpView?.setOneRow(ReservationTransferSearchCancel_OutAccount, Choose_Title)
        chooseAccountDorpView?.frame = chooseAccountView.frame
        chooseAccountDorpView?.frame.origin = .zero
        chooseAccountDorpView?.delegate = self
        chooseAccountView.addSubview(chooseAccountDorpView!)
        
        loginIntervalDropView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        loginIntervalDropView?.setOneRow(ReservationTransferSearchCancel_LoginInterval, Choose_Title)
        loginIntervalDropView?.frame = loginIntervalView.frame
        loginIntervalDropView?.frame.origin = .zero
        loginIntervalDropView?.delegate = self
        loginIntervalView.addSubview(loginIntervalDropView!)
        setShadowView(loginIntervalView)
        
        tableView.register(UINib(nibName: UIID.UIID_OverviewCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_OverviewCell.NibName()!)
        
        setLoading(true)
        getTransactionID("03003", TransactionID_Description)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: "Data") as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                setLoading(true)
                postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else {
                super.didResponse(description, response)
            }
            
        case "ACCT0101":
            if let data = response.object(forKey: "Data") as? [String:Any], let array = data["Result"] as? [[String:Any]]{
                for category in array {
                    if let type = category["ACTTYPE"] as? String, let result = category["AccountInfo"] as? [[String:Any]], type == Account_Saving_Type {
                        accountList = [AccountStruct]()
                        for actInfo in result {
                            if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? String, let ebkfg = actInfo["EBKFG"] as? String, ebkfg == Account_EnableTrans {
                                accountList?.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
                            }
                        }
                    }
                }
            }
            else {
                super.didResponse(description, response)
            }
            
        case "TRAN0301":
            if let data = response.object(forKey: "Data") as? [String:Any], let array = data["Result"] as? [[String:String]] {
                resultList = array
                tableView.reloadData()
            }
            else {
                super.didResponse(description, response)
            }
            
        default: super.didResponse(description, response)
        }
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickSpecificDateBtn(_ sender: Any) {
        specificDateBtn.setTitleColor(.white, for: .normal)
        specificDateBtn.backgroundColor = Green_Color
        fixedDateBtn.setTitleColor(.black, for: .normal)
        fixedDateBtn.backgroundColor = .white
        isSpecific = true
        cleanAllDate()
    }
    
    @IBAction func ClickFixedDateBtn(_ sender: Any) {
        fixedDateBtn.setTitleColor(.white, for: .normal)
        fixedDateBtn.backgroundColor = Green_Color
        specificDateBtn.setTitleColor(.black, for: .normal)
        specificDateBtn.backgroundColor = .white
        isSpecific = false
        cleanAllDate()
    }
    
    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        if sender == chooseAccountDorpView {
            if accountList != nil {
                let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: UIActionSheet_Cancel_Title, destructiveButtonTitle: nil)
                accountList?.forEach{index in actSheet.addButton(withTitle: index.accountNO)}
                actSheet.tag = ViewTag.View_AccountActionSheet.rawValue
                actSheet.show(in: view)
            }
            else {
                showErrorMessage(nil, "\(Choose_Title)\(chooseAccountDorpView?.m_lbFirstRowTitle.text ?? "")")
            }
        }
        else {
            if chooseAccountDorpView?.getContentByType(.First) != Choose_Title {
                if let dateView = getUIByID(.UIID_DatePickerView) as? DatePickerView {
                    dateView.frame = view.frame
                    dateView.frame.origin = .zero
                    var component = Calendar.current.dateComponents([.day], from: Date())
                    component.day = component.day!+1
                    let startDate = InputDatePickerStruct(minDate: component.date, maxDate: nil)
                    dateView.showTwoDatePickerView(isSpecific, startDate, nil) { startDate, endDate in
                        if self.isSpecific {
                            self.loginIntervalDropView?.setOneRow(ReservationTransferSearchCancel_LoginInterval, "\(startDate.year)/\(startDate.month)/\(startDate.day) - \(endDate.year)/\(endDate.month)/\(endDate.day)")
                            self.startDate = "\(startDate.year)\(startDate.month)\(startDate.day)"
                            self.endDate = "\(endDate.year)\(endDate.month)\(endDate.day)"
                        }
                        else {
                            self.loginIntervalDropView?.setOneRow(ReservationTransferSearchCancel_LoginInterval, "\(startDate.day) - \(endDate.day)")
                            self.startDate = startDate.day.replacingOccurrences(of: "日", with: "")
                            self.endDate = endDate.day.replacingOccurrences(of: "日", with: "")
                        }
                        self.getReservationTransferDetail()
                    }
                    view.addSubview(dateView)
                }
            }
            else {
                showErrorMessage(nil, "\(Choose_Title)\(chooseAccountDorpView?.m_lbFirstRowTitle.text ?? "")")
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_OverviewCell.NibName()!, for: indexPath) as! OverviewCell
        cell.title1Label.text = ReservationTransferSearchCancel_CellTitle[0]
        cell.title2Label.text = ReservationTransferSearchCancel_CellTitle[1]
        cell.title3Label.text = ReservationTransferSearchCancel_CellTitle[2]
        if let RGDAY = resultList[indexPath.row]["RGDAY"] {
            cell.detail1Label.text = RGDAY
        }
        if let TRACTNO = resultList[indexPath.row]["TRACTNO"] {
            cell.detail2Label.text = TRACTNO
        }
        if let AMOUNT = resultList[indexPath.row]["AMOUNT"] {
            cell.detail3Label.text = AMOUNT
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        curResultIndex = indexPath.row
        performSegue(withIdentifier: ReservationTransferSearchCancel_Segue, sender: nil)
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            switch actionSheet.tag {
            case ViewTag.View_AccountActionSheet.rawValue:
                if let info = accountList?[buttonIndex-1] {
                    chooseAccountDorpView?.setOneRow(ReservationTransferSearchCancel_OutAccount, info.accountNO)
                    getReservationTransferDetail()
                }
                
            default: break
            }
        }
    }
    
    // MARK: - Private
    private func cleanAllDate() {
        chooseAccountDorpView?.setOneRow(ReservationTransferSearchCancel_OutAccount, Choose_Title)
        startDate = ""
        endDate = ""
        loginIntervalDropView?.setOneRow(ReservationTransferSearchCancel_LoginInterval, Choose_Title)
        resultList.removeAll()
        tableView.reloadData()
    }
    
    private func getReservationTransferDetail() {
        if chooseAccountDorpView?.getContentByType(.First) != Choose_Title && !startDate.isEmpty && !endDate.isEmpty {
            setLoading(true)
            postRequest("TRAN/TRAN0301", "TRAN0301", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03003","Operate":"getList","TransactionId":transactionId,"ACTNO":chooseAccountDorpView?.getContentByType(.First) ?? "","KIND":isSpecific ? "1":"2","RVDAY":isSpecific ? startDate:"00000000","RVDAY2":isSpecific ? endDate:"00000000","IDD1":isSpecific ? "00":startDate,"IDD2":isSpecific ? "00":endDate], true), AuthorizationManage.manage.getHttpHead(true))
        }
    }
}
