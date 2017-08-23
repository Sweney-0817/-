//
//  LoanPrincipalInterestViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/7.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let PayLoan_Segue = "GoPayLoan"
let LoanPrincipalInterest_Accout_Title = "放款帳號"
let LoanPrincipalInterest_Accout_Default = "請選擇放款帳號"

class LoanPrincipalInterestViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, OneRowDropDownViewDelegate, UIActionSheetDelegate {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var loanAmountLabel: UILabel!
    @IBOutlet weak var currentAmountLabel: UILabel!
    @IBOutlet weak var needPayAmountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    private var topDropView:OneRowDropDownView? = nil
    private var accountList:[AccountStruct]? = nil                  // 帳號列表
    private var result:[String:Any]? = nil                          // 電文Response
    private var curIndex:Int? = nil
    
    // MARK: - Public
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != PayLoan_Segue {
            let detail = segue.destination as! LoanPrincipalInterestDetailViewController
            var list = [[String:String]]()
            list.append([Response_Key: "放款帳號", Response_Value:topDropView?.getContentByType(.First) ?? ""])
            if let ACTBAL = result?["ACTBAL"] as? String {
                list.append([Response_Key: "目前本金餘額", Response_Value:ACTBAL])
            }
            else {
                list.append([Response_Key: "目前本金餘額", Response_Value:""])
            }
            if let TPRIAMT = result?["TPRIAMT"] as? String {
                list.append([Response_Key: "應繳本金", Response_Value:TPRIAMT])
            }
            else {
                list.append([Response_Key: "應繳本金", Response_Value:""])
            }
            if let TINTAMT = result?["TINTAMT"] as? String {
                list.append([Response_Key: "應繳利息", Response_Value:TINTAMT])
            }
            else {
                list.append([Response_Key: "應繳利息", Response_Value:""])
            }
            if let TODIAMT = result?["TODIAMT"] as? String {
                list.append([Response_Key: "應繳諭期息", Response_Value:TODIAMT])
            }
            else {
                list.append([Response_Key: "應繳諭期息", Response_Value:""])
            }
            if let TDFAMT = result?["TDFAMT"] as? String {
                list.append([Response_Key: "應繳違約金", Response_Value:TDFAMT])
            }
            else {
                list.append([Response_Key: "應繳違約金", Response_Value:""])
            }
            if let SINTAMT = result?["SINTAMT"] as? String {
                list.append([Response_Key: "上次短收利息", Response_Value:SINTAMT])
            }
            else {
                list.append([Response_Key: "上次短收利息", Response_Value:""])
            }
            if let TOTAL = result?["TOTAL"] as? String {
                list.append([Response_Key: "應繳總額", Response_Value:TOTAL])
            }
            else {
                list.append([Response_Key: "應繳總額", Response_Value:""])
            }
            detail.setList(list)
        }
        else {
            
        }
    }
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: UIID.UIID_LoanPrincipalInterestCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_LoanPrincipalInterestCell.NibName()!)
        setShadowView(middleView!)
        
        topDropView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        topDropView?.setOneRow(LoanPrincipalInterest_Accout_Title, LoanPrincipalInterest_Accout_Default)
        topDropView?.frame = topView.frame
        topDropView?.frame.origin = .zero
        topDropView?.delegate = self
        topView.addSubview(topDropView!)
        
        setLoading(true)
        getTransactionID("03006", TransactionID_Description)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickMoreBtn(_ sender: Any) {
        
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let array = result?["Result"] as? [[String:String]] {
            return array.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_LoanPrincipalInterestCell.NibName()!, for: indexPath) as! LoanPrincipalInterestCell
        if indexPath.row == 0 {
            cell.payBtn.isHidden = false
        }
        else {
            cell.payBtn.isHidden = true
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0  {
            performSegue(withIdentifier: PayLoan_Segue, sender: nil)
        }
    }
    
    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        if accountList != nil {
            let actSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: UIActionSheet_Cancel_Title, destructiveButtonTitle: nil)
            for index in accountList! {
                actSheet.addButton(withTitle: index.accountNO)
            }
            actSheet.tag = ViewTag.View_AccountActionSheet.rawValue
            actSheet.show(in: view)
        }
    }
    
    // MARK: - ConnectionUtilityDelegate
    override func didRecvdResponse(_ description:String, _ response: NSDictionary) {
        setLoading(false)
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: "Data") as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                setLoading(true)
                postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else {
                super.didRecvdResponse(description, response)
            }
            
        case "ACCT0101":
            if let data = response.object(forKey: "Data") as? [String:Any], let array = data["Result"] as? [[String:Any]] {
                for category in array {
                    if let type = category["ACTTYPE"] as? String, let result = category["AccountInfo"] as? [[String:Any]], type == Account_Loan_Type {
                        accountList = [AccountStruct]()
                        for actInfo in result {
                            if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? Double, let ebkfg = actInfo["EBKFG"] as? Int, ebkfg == Account_EnableTrans {
                                accountList?.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
                            }
                        }
                    }
                }
            }
            else {
                super.didRecvdResponse(description, response)
            }
            
        case "TRAN0601":
            if let data = response.object(forKey: "Data") as? [String:Any], let dic = data["Result"] as? [String:Any] {
                result = dic
                if let APAMT = result?["APAMT"] as? String {
                    loanAmountLabel.text = APAMT
                }
                if let ACTBAL = result?["ACTBAL"] as? String {
                    currentAmountLabel.text = ACTBAL
                }
                if let TOTAL = result?["TOTAL"] as? String {
                    needPayAmountLabel.text = TOTAL
                }
                tableView.reloadData()
            }
            else {
                super.didRecvdResponse(description, response)
            }
            
        default: super.didRecvdResponse(description, response)
        }
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            switch actionSheet.tag {
            case ViewTag.View_AccountActionSheet.rawValue:
                topDropView?.setOneRow(LoanPrincipalInterest_Accout_Title, actionSheet.buttonTitle(at: buttonIndex) ?? "")
                setLoading(true)
                postRequest("TRAN/TRAN0601", "TRAN0601", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03006","Operate":"getList","TransactionId":transactionId,"REFNO":actionSheet.buttonTitle(at: buttonIndex) ?? "","PRDCNT":"0"], true), AuthorizationManage.manage.getHttpHead(true)) // PRDCNT:繳息期數=>0-為查回全部,1-為可繳交第一期
                
            default: break
            }
        }
    }
}
