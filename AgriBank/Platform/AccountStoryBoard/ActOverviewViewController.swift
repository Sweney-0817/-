//
//  ActOverviewViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/6/15.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let ActOverview_SectionAll_Height = CGFloat(48)
let ActOverview_Section_Height = CGFloat(20)
let ActOverview_ShowDetail_Segue = "ShowDetail"
let ActOverview_GoActDetail_Segue = "GoAccountDetail"
let ActOverview_CellTitleList = ["帳號","幣別","帳戶餘額"]

enum ActOverviewType:Int {
    case Type1
    case Type2
    case Type3
    case Type4
    case Type0
   
    func description() -> String {
        switch self {
        case .Type1: return "活期存款"
        case .Type2: return "支票存款"
        case .Type3: return "定期存款"
        case .Type4: return "放款"
        case .Type0: return "全部"
        }
    }
}

let ActOverview_TypeList = [ActOverviewType.Type1.description(),ActOverviewType.Type2.description(),ActOverviewType.Type3.description(),ActOverviewType.Type4.description()]

class ActOverviewViewController: BaseViewController, ChooseTypeDelegate, UITableViewDataSource, UITableViewDelegate, OverviewCellDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var chooseTypeView: ChooseTypeView!
    @IBOutlet weak var tableView: UITableView!
    private var categoryList = [String:[AccountStruct]]() // Key: 電文(ACCT0101)response的"ACTTYPE"
    private var categoryType = [String:String]()        // Key: ActOverviewType.description() value: 電文(ACCT0101)response的"ACTTYPE"
    private var typeList = [String]()                   // 使用者帳戶清單的Type List
    private var typeListIndex:Int = 0                   // ActOverview_TypeList 的 index
    private var currentType:ActOverviewType = .Type0    // 目前Type
    private var chooseAccount:String? = nil
    private var resultList = [String:Any]()
    private var pushByclickExpandBtn = false            // 判斷是否從cell觸發 進功能畫面
    
    // MARK: - public
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let controller = segue.destination as! ShowDetailViewController
        var list = [[String:String]]()
        let type = currentType == .Type0 ? (GetTypeByInputString(ActOverview_TypeList[typeListIndex]) ??  currentType) : currentType
        switch type {
        case .Type1:
            if let ACTNO = resultList["ACTNO"] as? String {
                list.append([Response_Key: "帳號", Response_Value:ACTNO])
            }
            if let AVBAL = resultList["AVBAL"] as? Double {
                list.append([Response_Key: "可用餘額", Response_Value:String(AVBAL)])
            }
            if let NAMT = resultList["NAMT"] as? Double {
                list.append([Response_Key: "本交金額", Response_Value:String(NAMT)])
            }
            if let ACTBAL = resultList["ACTBAL"] as? Double {
                list.append([Response_Key: "帳戶餘額", Response_Value:String(ACTBAL)])
            }
         
        case .Type2:
            if let ACTNO = resultList["ACTNO"] as? String {
                list.append([Response_Key: "帳號", Response_Value:ACTNO])
            }
            if let PRIBAL = resultList["PRIBAL"] as? Double {
                list.append([Response_Key: "帳戶餘額", Response_Value:String(PRIBAL)])
            }
            if let AVBAL = resultList["AVBAL"] as? Double {
                list.append([Response_Key: "可用金額", Response_Value:String(AVBAL)])
            }
            if let NAMT = resultList["NAMT"] as? Double {
                list.append([Response_Key: "本交票金額", Response_Value:String(NAMT)])
            }
            if let STPBAL = resultList["STPBAL"] as? Double {
                list.append([Response_Key: "扣押總金額", Response_Value:String(STPBAL)])
            }
            if let LTXDAY = resultList["LTXDAY"] as? String {
                list.append([Response_Key: "拒往日/上交日", Response_Value:LTXDAY])
            }
            if let LNLMT = resultList["LNLMT"] as? String {
                list.append([Response_Key: "透支限額", Response_Value:LNLMT])
            }
            
        case .Type3:
            if let ACTNO = resultList["ACTNO"] as? String {
                list.append([Response_Key: "帳號", Response_Value:ACTNO])
            }
            if let CTNO = resultList["CTNO"] as? String {
                list.append([Response_Key: "存單號碼", Response_Value:CTNO])
            }
            if let CIDAY = resultList["CIDAY"] as? String {
                list.append([Response_Key: "起存日", Response_Value:CIDAY])
            }
            if let EDAY = resultList["EDAY"] as? String {
                list.append([Response_Key: "到期日", Response_Value:EDAY])
            }
            if let MCNT = resultList["MCNT"] as? String {
                list.append([Response_Key: "期間(月)", Response_Value:MCNT])
            }
            if let CENT = resultList["CENT"] as? String {
                list.append([Response_Key: "期間(日)", Response_Value:CENT])
            }
            if let INTRT = resultList["INTRT"] as? Double {
                list.append([Response_Key: "利率", Response_Value:String(INTRT)])
            }
            if let CTBAL = resultList["CTBAL"] as? Double {
                list.append([Response_Key: "存單面額", Response_Value:String(CTBAL)])
            }
            if let IRTID = resultList["IRTID"] as? String {
                list.append([Response_Key: "利率型態", Response_Value:(IRTID == "1" ? "固定":"機動")])
            }
            if let MRTGE = resultList["MRTGE"] as? String {
                list.append([Response_Key: "設質記號", Response_Value:(MRTGE == "0" ? "未設質":"已設質")])
            }
            if let ATERM = resultList["ATERM"] as? String {
                list.append([Response_Key: "自動轉期記號", Response_Value:(ATERM == "00" ? "不轉期":"轉期")])
            }
            
        case .Type4:
            if let ACTNO = resultList["ACTNO"] as? String {
                list.append([Response_Key: "帳號", Response_Value:ACTNO])
            }
            if let SUBNO = resultList["SUBNO"] as? Double {
                list.append([Response_Key: "分號", Response_Value:String(SUBNO)])
            }
            if let APAMT = resultList["APAMT"] as? Double {
                list.append([Response_Key: "初貸金額", Response_Value:String(APAMT)])
            }
            if let ACTBAL = resultList["ACTBAL"] as? Double {
                list.append([Response_Key: "貸款餘額", Response_Value:String(ACTBAL)])
            }
            if let APSDAY = resultList["APSDAY"] as? String {
                list.append([Response_Key: "貸放起日", Response_Value:APSDAY])
            }
            if let APEDAY = resultList["APEDAY"] as? String {
                list.append([Response_Key: "貸放止日", Response_Value:APEDAY])
            }
            if let RATECD = resultList["RATECD"] as? String {
                var type = ""
                switch RATECD {
                case "01": type = "固定利率"
                case "02": type = "定期固定利率"
                case "03": type = "定期機動利率"
                case "04": type = "機動利率"
                default: break
                }
                list.append([Response_Key: "利率型態", Response_Value:type])
            }
            if let IRT = resultList["IRT"] as? Double {
                list.append([Response_Key: "計息利率(%)", Response_Value:String(IRT)])
            }
            if let PRCD = resultList["PRCD"] as? String {
                var type = ""
                switch PRCD {
                case "01": type = "按期繳息到期還本"
                case "02": type = "先收息後本息平均攤還"
                case "03": type = "先收息後本金平均攤還"
                case "04": type = "本息平均攤還"
                case "05": type = "本金平均攤還"
                case "06": type = "到期繳息還本"
                case "09": type = "約定還本方式"
                default: break
                }
                list.append([Response_Key: "利率型態", Response_Value:type])
            }
            if let OIDATE = resultList["OIDATE"] as? String {
                list.append([Response_Key: "上次收息日", Response_Value:OIDATE])
            }
            if let PRDATE = resultList["PRDATE"] as? String {
                list.append([Response_Key: "預定還本日", Response_Value:PRDATE])
            }
            if let IDATE = resultList["IDATE"] as? String {
                list.append([Response_Key: "預定收息日", Response_Value:IDATE])
            }
            if let PAYACTNO = resultList["PAYACTNO"] as? String {
                list.append([Response_Key: "自動扣繳帳號", Response_Value:PAYACTNO])
            }
            
        default: break
        }
        
        controller.setList("\(type.description())往來明細", list)
    }
    
    // MARK: - Private
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
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: UIID.UIID_OverviewCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_OverviewCell.NibName()!)
        navigationController?.delegate = self
        setLoading(true)
        getTransactionID("02031", TransactionID_Description)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                for category in array {
                    if let type = category["ACTTYPE"] as? String, let result = category["Result"] as? [[String:Any]] {
                        var addType = false
                        // "ACTTYPE"->帳號類別: 活存：P, 支存：K, 定存：T, 放款：L, 綜存：M
                        switch type {
                        case "P":
                            categoryType[ActOverview_TypeList[0]] = type
                            categoryList[type] = [AccountStruct]()
                            addType = true
                            if typeList.index(of: ActOverviewType.Type1.description()) == nil {
                                typeList.append(ActOverviewType.Type1.description())
                            }
                            
                        case "K":
                            categoryType[ActOverview_TypeList[1]] = type
                            categoryList[type] = [AccountStruct]()
                            addType = true
                            if typeList.index(of: ActOverviewType.Type2.description()) == nil {
                                typeList.append(ActOverviewType.Type2.description())
                            }
                            
                        case "T":
                            categoryType[ActOverview_TypeList[2]] = type
                            categoryList[type] = [AccountStruct]()
                            addType = true
                            if typeList.index(of: ActOverviewType.Type3.description()) == nil {
                                typeList.append(ActOverviewType.Type3.description())
                            }
                            
                        case "L":
                            categoryType[ActOverview_TypeList[3]] = type
                            categoryList[type] = [AccountStruct]()
                            addType = true
                            if typeList.index(of: ActOverviewType.Type4.description()) == nil {
                                typeList.append(ActOverviewType.Type4.description())
                            }
                            
                        default: break
                        }
                        
                        if addType {
                            for actInfo in result {
                                if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? Double, let ebkfg = actInfo["EBKFG"] as? Int {
                                    categoryList[type]?.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
                                }
                            }
                        }
                    }
                }
                
                if typeList.count != 0 {
                    typeList.insert(ActOverviewType.Type0.description(), at: 0)
                    chooseTypeView.setTypeList(typeList, setDelegate: self)
                    tableView.reloadData()
                }
            }
            else {
                super.didRecvdResponse(description, response)
            }
            
        case "ACIF0101":
            if let data = response.object(forKey: "Data") as? [String:Any] {
                resultList = data
                performSegue(withIdentifier: ActOverview_ShowDetail_Segue, sender: nil)
            }
            else {
                super.didRecvdResponse(description, response)
            }
            
        default: break
        }
    }
    
    // MARK: - ChooseTypeDelegate
    func clickChooseTypeBtn(_ name:String) {
        if name == ActOverviewType.Type0.description() {
            if currentType != .Type0 {
                currentType = .Type0
                typeListIndex = 0
                tableView.sectionHeaderHeight = ActOverview_SectionAll_Height
                tableView.reloadData()
            }
        }
        else {
            if let index = ActOverview_TypeList.index(of: name), let type = GetTypeByInputString(name) {
                typeListIndex = index
                if currentType != type {
                    currentType = type
                    tableView.sectionHeaderHeight = ActOverview_Section_Height
                    tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        if currentType == .Type0 {
            return typeList.count != 0 ? typeList.count-1 : typeList.count
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        let index = currentType == .Type0 ? (ActOverview_TypeList.index(of: typeList[section+1]) ??  0): typeListIndex
        if let type = categoryType[ActOverview_TypeList[index]], let array = categoryList[type] {
            count = array.count
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_OverviewCell.NibName()!, for: indexPath) as! OverviewCell
        cell.title1Label.text = ActOverview_CellTitleList[0]
        cell.title2Label.text = ActOverview_CellTitleList[1]
        cell.title3Label.text = ActOverview_CellTitleList[2]
        let index = currentType == .Type0 ? (ActOverview_TypeList.index(of: typeList[indexPath.section+1]) ??  0) : typeListIndex
        if let type = categoryType[ActOverview_TypeList[index]], let array = categoryList[type] {
            cell.detail1Label.text = array[indexPath.row].accountNO
            cell.detail2Label.text = array[indexPath.row].currency
            cell.detail3Label.text = String(array[indexPath.row].balance)
            if let cellType = GetTypeByInputString(ActOverview_TypeList[index]) {
                cell.AddExpnadBtn(self, cellType, (array[indexPath.row].status == Account_EnableTrans,true))
            }
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var secView:TypeSection? = nil
        if currentType == .Type0 {
            secView = getUIByID(.UIID_TypeSection) as? TypeSection
            secView?.titleLabel.text = typeList[section+1]
        }
        return secView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if currentType == .Type0 {
            typeListIndex =  ActOverview_TypeList.index(of: typeList[indexPath.section+1]) ?? 0
        }
        
        if categoryType[ActOverview_TypeList[typeListIndex]] != nil, let cell = tableView.cellForRow(at: indexPath) as? OverviewCell {
            setLoading(true)
            postRequest("ACIF/ACIF0101", "ACIF0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02031","Operate":"getAcntInfo","TransactionId":transactionId,"ACTTYPE":categoryType[ActOverview_TypeList[typeListIndex]]!,"ACTNO":cell.detail1Label.text!], true), AuthorizationManage.manage.getHttpHead(true))
        }
    }
    
    // MARK: - OverviewCellDelegate
    func clickExpandBtn1(_ btn:UIButton, _ value:[String:String]) {
        if currentType == .Type0 {
            typeListIndex = btn.tag
        }
        else {
            typeListIndex = ActOverview_TypeList.index(of: currentType.description()) ?? 0
        }
        let type = currentType == .Type0 ? (GetTypeByInputString(ActOverview_TypeList[typeListIndex]) ??  currentType) : currentType
        switch type {
        case .Type1:
            enterFeatureByID(.FeatureID_NTTransfer, false)
            
        case .Type2:
            enterFeatureByID(.FeatureID_NTTransfer, false)
        
        case .Type3:
            chooseAccount = value[ActOverview_CellTitleList.first!]
            enterFeatureByID(.FeatureID_AccountDetailView, false)
            pushByclickExpandBtn = true
    
        case .Type4:
            enterFeatureByID(.FeatureID_LoanPrincipalInterest, false)
            
        default: break
        }
    }
    
    func clickExpandBtn2(_ btn:UIButton, _ value:[String:String]) {
        if currentType == .Type0 {
            typeListIndex = btn.tag
        }
        else {
            typeListIndex = ActOverview_TypeList.index(of: currentType.description()) ?? 0
        }
        let type = currentType == .Type0 ? (GetTypeByInputString(ActOverview_TypeList[typeListIndex]) ??  currentType) : currentType
        switch type {
        case .Type1:
            chooseAccount = value[ActOverview_CellTitleList.first!]
            enterFeatureByID(.FeatureID_AccountDetailView, false)
            pushByclickExpandBtn = true
            
        case .Type2:
            chooseAccount = value[ActOverview_CellTitleList.first!]
            enterFeatureByID(.FeatureID_AccountDetailView, false)
            pushByclickExpandBtn = true
            
        case .Type4:
            chooseAccount = value[ActOverview_CellTitleList.first!]
            enterFeatureByID(.FeatureID_AccountDetailView, false)
            pushByclickExpandBtn = true
            
        default: break
        }
    }
    
    // MARK: - UINavigationControllerDelegate
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if pushByclickExpandBtn && viewController is ActDetailViewController {
            (viewController as! ActDetailViewController).SetInitial(ActOverview_TypeList[typeListIndex], chooseAccount)
            navigationController.delegate = nil
        }
    }
}
