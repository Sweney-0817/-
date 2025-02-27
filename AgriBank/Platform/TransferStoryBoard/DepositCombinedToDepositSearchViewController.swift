//
//  DepositCombinedToDepositSearchViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/6.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let DepositCombinedToDepositSearch_Segue = "GoDepositDetail"
let DepositCombinedToDepositSearch_Account_Title = "綜存帳號"
let DepositCombinedToDepositSearch_Cell_Title = ["定存帳號","定存金額","到期日"]

class DepositCombinedToDepositSearchViewController: BaseViewController, OneRowDropDownViewDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tableView: UITableView!
    private var topDropView:OneRowDropDownView? = nil
    private var accountList:[AccountStruct]? = nil                  // 帳號列表
    private var result:[[String:String]]? = nil                     // 電文Response
    private var curIndex:Int? = nil
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        topDropView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        topDropView?.setOneRow(DepositCombinedToDepositSearch_Account_Title, Choose_Title)
        topDropView?.frame = topView.frame
        topDropView?.frame.origin = .zero
        topDropView?.delegate = self
        topView.addSubview(topDropView!)
        setShadowView(topView)
        
        tableView.register(UINib(nibName: UIID.UIID_OverviewCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_OverviewCell.NibName()!)
        getTransactionID("03005", TransactionID_Description)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! DepositCombinedDetailViewController
        controller.transactionId = transactionId
        if curIndex != nil, let dic = result?[curIndex!] {
            var list = [[String:String]]()
            list.append([Response_Key: "定存帳號", Response_Value:dic["Deposit"] ?? ""])
            list.append([Response_Key: "定存金額", Response_Value:dic["CTBAL"]?.separatorThousand() ?? ""])
            list.append([Response_Key: "到期日", Response_Value:dic["EDAY"] ?? ""])
            //list.append([Response_Key: "起存日", Response_Value:dic["CIDAY"] ?? ""])
            //2020-2-5 mod by sweney 
            list.append([Response_Key: "起存日", Response_Value:dic["ISDAY"] ?? ""])
            list.append([Response_Key: "存單期別(月)", Response_Value:dic["PRDMM"] ?? ""])
            if let YRATE = dic["YRATE"] {
                list.append([Response_Key: "開戶利率", Response_Value:"\(YRATE)%"])
            }
            else {
                list.append([Response_Key: "開戶利率", Response_Value:""])
            }
            controller.setList(list, dic["Deposit"], topDropView?.getContentByType(.First))
        }
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
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]] {
                for category in array {
                    if let type = category["ACTTYPE"] as? String, let result = category["AccountInfo"] as? [[String:Any]], type == Account_Deposit_Type {
                        accountList = [AccountStruct]()
                        for actInfo in result {
                            if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? String, let ebkfg = actInfo["EBKFG"] as? String {
                                accountList?.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
                            }
                        }
                    }
                }
            }
            else {
                super.didResponse(description, response)
            }
            
        case "TRAN0501":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:String]] {
                result = array
                tableView.reloadData()
            }
            else {
                super.didResponse(description, response)
            }
            
        default: super.didResponse(description, response)
        }
    }
    
    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        if accountList != nil && (accountList?.count)! > 0 {
            let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
            accountList?.forEach{index in actSheet.addButton(withTitle: index.accountNO)}
            actSheet.tag = ViewTag.View_AccountActionSheet.rawValue
            actSheet.show(in: view)
        }
        else {
            showErrorMessage(nil, "\(Get_Null_Title)\(topDropView?.m_lbFirstRowTitle.text ?? "")")
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        curIndex = indexPath.row
        performSegue(withIdentifier: DepositCombinedToDepositSearch_Segue, sender: nil)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_OverviewCell.NibName()!, for: indexPath) as! OverviewCell
        cell.title1Label.text = DepositCombinedToDepositSearch_Cell_Title[0]
        cell.title2Label.text = DepositCombinedToDepositSearch_Cell_Title[1]
        cell.title3Label.text = DepositCombinedToDepositSearch_Cell_Title[2]
        if let Deposit = result?[indexPath.row]["Deposit"] {
            cell.detail1Label.text = Deposit
        }
        if let CTBAL = result?[indexPath.row]["CTBAL"] {
            cell.detail2Label.text = CTBAL.separatorThousand()
        }
        if let EDAY = result?[indexPath.row]["EDAY"] {
            cell.detail3Label.text = EDAY
        }
        return cell
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            switch actionSheet.tag {
            case ViewTag.View_AccountActionSheet.rawValue:
                topDropView?.setOneRow(DepositCombinedToDepositSearch_Account_Title, actionSheet.buttonTitle(at: buttonIndex) ?? "")
                setLoading(true)
                postRequest("TRAN/TRAN0501", "TRAN0501", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03005","Operate":"getList","TransactionId":transactionId,"REFNO":topDropView?.getContentByType(.First) ?? ""], true), AuthorizationManage.manage.getHttpHead(true))
                
            default: break
            }
        }
    }
}
