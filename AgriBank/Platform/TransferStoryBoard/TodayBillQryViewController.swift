//
//  TodayBillQryViewController.swift
//  AgriBank
//
//  Created by ABOT on 2019/12/19.
//  Copyright © 2019 Systex. All rights reserved.
//


import UIKit

let TodayBillQryView_ShowAccount_Title = "帳號"
let ReturnTitle = "本日待補票據有包含已回檔紀錄，請洽櫃台確認票據狀態。"
let Pm330Title = "已逾15:30，如仍需存入票款，請改以匯款或臨櫃方式辦理。"
let RemartTitle = "查詢資料僅供參考，確實數字請與開戶單位聯絡。"
var wkSTATUS = "A"
var TodayBillQry_Cell_Height:CGFloat = 60
var RowDouble:CGFloat = 1
var MemoLineConter:CGFloat = 1


class TodayBillQryViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate,OneRowDropDownViewDelegate, UIActionSheetDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var chooseAccountView: UIView!
    @IBOutlet weak var LineView: UIView!
    @IBOutlet weak var TodayBillABtn: UIButton!
    @IBOutlet weak var TodayBill0Btn: UIButton!
    @IBOutlet weak var TodayBill1Btn: UIButton!
    
    private var topDropView:OneRowDropDownView? = nil
    private var accountList:[AccountStruct]? = nil                  // 帳號列表
    private var currentTextField:UITextField? = nil
    private var accountIndex:Int? = nil                             // 目前選擇放款帳號
    private var result:[String:Any]? = nil                          // 電文Response
    private var ReturnNum:String? = "0"                       //電文ReturnNum
    private var oneResult:[String:Any]? = nil                       // 電文Response
    private var curIndex:Int? = nil                                 // result["Result"]
    private var inputAccount:String? = nil                          // 由「帳戶總覽」帶入的帳號
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: UIID.UIID_TodayBillQryCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_TodayBillQryCell.NibName()!)
        // navigationController?.delegate = self
        setShadowView(LineView,.Bottom)
        topDropView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        topDropView?.m_lbFirstRowTitle.textAlignment = .center
        topDropView?.frame = chooseAccountView.frame
        topDropView?.frame.origin = .zero
        topDropView?.delegate = self
        topDropView?.setOneRow(TodayBillQryView_ShowAccount_Title, Choose_Title)
        topDropView?.titleWeight.constant = (topDropView?.titleWeight.constant)! / 2
        chooseAccountView.addSubview(topDropView!)
        SetBtnColor()
        getTransactionID("03011", TransactionID_Description)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                setLoading(true)
                //收到TransactionID後 判斷3007送查詢
                postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
                
            }
            else {
                super.didResponse(description, response)
            }
            
        case "ACCT0101":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]]{
                for category in array {
                    if let type = category["ACTTYPE"] as? String, let result = category["AccountInfo"] as? [[String:Any]], type == Account_Check_Type {
                        accountList = [AccountStruct]()
                        for actInfo in result {
                            if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? String, let ebkfg = actInfo["EBKFG"] as? String  {
                                accountList?.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
                            }
                        }
                    }
                }
                //2019-9-2 add by sweney -取index=0轉出帳號
                if(accountList?.count)! > 0 {
                    accountIndex = 0
                    if let info = accountList?[accountIndex!]{
                        topDropView?.setOneRow(TodayBillQryView_ShowAccount_Title, info.accountNO)
                        postRequest("TRAN/TRAN0901", "TRAN0901", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03011","Operate":"getAcntInfo","TransactionId":transactionId,"ACTNO":accountList?[accountIndex!].accountNO ?? "","STATUS":wkSTATUS], true), AuthorizationManage.manage.getHttpHead(true))// STATUS:A:全部0:未處理1:以扣帳
                    }
                }
            }
            else {
                super.didResponse(description, response)
            }
        case "TRAN0901":
            let data = response.object(forKey: ReturnData_Key) as? [String:Any]
            result = data
            let wkreturn = response.object(forKey: "ReturnNum") as?  String
            ReturnNum = wkreturn
            
            tableView.reloadData()
        default: super.didResponse(description, response)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.sectionFooterHeight))
        view.backgroundColor = UIColor.white
        RowDouble = 1
        
        //備註提示
        let labelTitle = UILabel(frame:CGRect(x:10,y:3, width: 40,height:TodayBillQry_Cell_Height))
        labelTitle.text = "備註"
        labelTitle.font = Default_Font
        labelTitle.textColor = Cell_Title_Color
        labelTitle.textAlignment = .center
        
        let label = UILabel(frame: CGRect(x: 60 ,y: 0, width: view.frame.width-60, height:TodayBillQry_Cell_Height))
        label.text = RemartTitle
        label.font = Default_Font
        label.textColor = Cell_Detail_Color
        label.textAlignment = .left
        label.numberOfLines = 0
        view.addSubview(label)
        view.addSubview(labelTitle)
        
        //時間提示
        let currnetDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.init(identifier: Calendar.Identifier.iso8601)
        dateFormatter.dateFormat = "HHmm"
        if dateFormatter.string(from: currnetDate) >= "1530" {
            let labelTitle = UILabel(frame:CGRect(x:10,y:TodayBillQry_Cell_Height+3, width: 40,height:TodayBillQry_Cell_Height))
            labelTitle.text = "注意"
            labelTitle.font = Default_Font
            labelTitle.textColor = Orange_Color
            labelTitle.textAlignment = .center
            let label = UILabel(frame: CGRect(x: 60, y: TodayBillQry_Cell_Height, width: view.frame.width-60, height:TodayBillQry_Cell_Height))
            label.text = Pm330Title
            label.font = Default_Font
            label.textColor = Orange_Color
            label.textAlignment = .left
            label.numberOfLines = 0
            view.addSubview(label)
            view.addSubview(labelTitle)
            RowDouble = 2
            
        }
        //回檔提示
        if  ReturnNum != "0" {
            let labelTitle = UILabel(frame:CGRect(x:10,y:(TodayBillQry_Cell_Height)*RowDouble+3, width: 40,height:TodayBillQry_Cell_Height))
            labelTitle.text = "注意"
            labelTitle.font = Default_Font
            labelTitle.textColor = Orange_Color
            labelTitle.textAlignment = .center
            
            let label = UILabel(frame: CGRect(x: 60 ,y: TodayBillQry_Cell_Height*RowDouble, width: view.frame.width-60, height:TodayBillQry_Cell_Height))
            label.text = ReturnTitle
            label.font = Default_Font
            label.textColor = Orange_Color
            label.textAlignment = .left
            label.numberOfLines = 0
            view.addSubview(label)
            view.addSubview(labelTitle)

        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
            MemoLineConter = 1
        
        if  ReturnNum != "0" {
            MemoLineConter = MemoLineConter + 1
        }
        let currnetDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.init(identifier: Calendar.Identifier.iso8601)
        dateFormatter.dateFormat = "HHmm"
        if dateFormatter.string(from: currnetDate) >= "1530" {
            MemoLineConter = MemoLineConter + 1
        }
        return TodayBillQry_Cell_Height*MemoLineConter+5
        
    }
    
    
    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        if accountList != nil && accountList?.count != 0 {
            let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
            for index in accountList! {
                actSheet.addButton(withTitle: index.accountNO)
            }
            actSheet.tag = ViewTag.View_AccountActionSheet.rawValue
            actSheet.show(in: view)
        }
        else {
            showErrorMessage(nil, "\(Get_Null_Title)\(sender.m_lbFirstRowTitle.text!)")
        }
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            switch actionSheet.tag {
            case ViewTag.View_AccountActionSheet.rawValue:
                accountIndex = buttonIndex-1
                topDropView?.setOneRow(TodayBillQryView_ShowAccount_Title, accountList?[accountIndex!].accountNO ?? "")
                SetBtnColor ()
                
                if accountList!.count > 0 {
                    setLoading(true)
                    postRequest("TRAN/TRAN0901", "TRAN0901", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03011","Operate":"getAcntInfo","TransactionId":transactionId,"ACTNO":accountList?[accountIndex!].accountNO ?? "","STATUS":wkSTATUS], true), AuthorizationManage.manage.getHttpHead(true))// STATUS:A:全部0:未處理1:以扣帳
                }
                
            default: break
            }
        }
    }
    
    @IBAction func TodayBillA(_ sender: Any) {
        
        wkSTATUS = "A"
        SetBtnColor()
        if accountList!.count > 0 {
            setLoading(true)
            postRequest("TRAN/TRAN0901", "TRAN0901", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03011","Operate":"getAcntInfo","TransactionId":transactionId,"ACTNO":accountList?[accountIndex!].accountNO ?? "","STATUS":wkSTATUS], true), AuthorizationManage.manage.getHttpHead(true))// STATUS:A:全部0:未處理1:以扣帳
        }
    }
    @IBAction func TodayBill0(_ sender: Any) {
        
        wkSTATUS = "0"
        SetBtnColor()
        if accountList!.count > 0 {
            setLoading(true)
        postRequest("TRAN/TRAN0901", "TRAN0901", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03011","Operate":"getAcntInfo","TransactionId":transactionId,"ACTNO":accountList?[accountIndex!].accountNO ?? "","STATUS":wkSTATUS], true), AuthorizationManage.manage.getHttpHead(true))// STATUS:A:全部0:未處理1:以扣帳
    }
    }
    @IBAction func TodayBill1(_ sender: Any) {
        
        wkSTATUS = "1"
        SetBtnColor()
        if accountList!.count > 0 {
            postRequest("TRAN/TRAN0901", "TRAN0901", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03011","Operate":"getAcntInfo","TransactionId":transactionId,"ACTNO":accountList?[accountIndex!].accountNO ?? "","STATUS":wkSTATUS], true), AuthorizationManage.manage.getHttpHead(true))// STATUS:A:全部0:未處理1:以扣帳
        }
    }
    
    //tv row counter
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let array = result?["Result"] as? [[String:String]] {
            return array.count
        }
        return 0
    }
    //tv set row infor
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_TodayBillQryCell.NibName()!, for: indexPath) as! TodayBillQryCell
        if let array = result?["Result"] as? [[String:String]] {
            
            if let CKNO = array[indexPath.row]["CKNO"]  {
                cell.CKNOLabel.text = CKNO.trimmingCharacters(in: .whitespaces)
            }
            if let TXAMT = array[indexPath.row]["TXAMT"]  {
                cell.TXAMTLabel.text = TXAMT.trimmingCharacters(in: .whitespaces)
            }
            if let STATUSC = array[indexPath.row]["STATUSC"] {
                cell.STATUSTLabel.text = STATUSC.trimmingCharacters(in: .whitespaces)
            }
            if let ERRCODEC = array[indexPath.row]["ERRCODEC"],let ERRCODE = array[indexPath.row]["ERRCODE"] {
                cell.ERRCODECLabel.text = ERRCODE.trimmingCharacters(in: .whitespaces) + ERRCODEC.trimmingCharacters(in: .whitespaces)
            }
            
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 118
    }
    
    
    func  numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (result?["Result"] as? [[String:String]]) != nil {
            curIndex = indexPath.row
            
        }
    }
    func SetBtnColor () {
        result = nil
        ReturnNum="0"
    
        tableView.reloadData()
        switch wkSTATUS {
        case "A":
            TodayBillABtn.setBackgroundImage(UIImage(named: "ButtonSmall"), for: .normal)
            TodayBillABtn.setTitleColor(UIColor.white, for: .normal)
            TodayBillABtn.layer.borderWidth = 0
            
            TodayBill1Btn.layer.cornerRadius = 8
            TodayBill1Btn.layer.borderWidth = Layer_BorderWidth
            TodayBill1Btn.setTitleColor(Orange_Color, for: .normal)
            TodayBill1Btn.setBackgroundImage(nil, for: .normal)
            TodayBill1Btn.layer.borderColor = Orange_Color.cgColor
            
            
            TodayBill0Btn.layer.cornerRadius = 8
            TodayBill0Btn.layer.borderWidth = Layer_BorderWidth
            TodayBill0Btn.setTitleColor(Orange_Color, for: .normal)
            TodayBill0Btn.setBackgroundImage(nil, for: .normal)
            TodayBill0Btn.layer.borderColor = Orange_Color.cgColor
            
        case "0":
            TodayBill0Btn.setBackgroundImage(UIImage(named: "ButtonSmall"), for: .normal)
            TodayBill0Btn.setTitleColor(UIColor.white, for: .normal)
            TodayBill0Btn.layer.borderWidth = 0
            
            TodayBill1Btn.layer.cornerRadius = 8
            TodayBill1Btn.layer.borderWidth = Layer_BorderWidth
            TodayBill1Btn.setTitleColor(Orange_Color, for: .normal)
            TodayBill1Btn.setBackgroundImage(nil, for: .normal)
            TodayBill1Btn.layer.borderColor = Orange_Color.cgColor
            
            
            TodayBillABtn.layer.cornerRadius = 8
            TodayBillABtn.layer.borderWidth = Layer_BorderWidth
            TodayBillABtn.setTitleColor(Orange_Color, for: .normal)
            TodayBillABtn.setBackgroundImage(nil, for: .normal)
            TodayBillABtn.layer.borderColor = Orange_Color.cgColor
        case "1":
            TodayBill1Btn.setBackgroundImage(UIImage(named: "ButtonSmall"), for: .normal)
            TodayBill1Btn.setTitleColor(UIColor.white, for: .normal)
            TodayBill1Btn.layer.borderWidth = 0
            
            TodayBillABtn.layer.cornerRadius = 8
            TodayBillABtn.layer.borderWidth = Layer_BorderWidth
            TodayBillABtn.setTitleColor(Orange_Color, for: .normal)
            TodayBillABtn.setBackgroundImage(nil, for: .normal)
            TodayBillABtn.layer.borderColor = Orange_Color.cgColor
            
            
            TodayBill0Btn.layer.cornerRadius = 8
            TodayBill0Btn.layer.borderWidth = Layer_BorderWidth
            TodayBill0Btn.setTitleColor(Orange_Color, for: .normal)
            TodayBill0Btn.setBackgroundImage(nil, for: .normal)
            TodayBill0Btn.layer.borderColor = Orange_Color.cgColor
        default:
            TodayBillABtn.setBackgroundImage(UIImage(named: "ButtonSmall"), for: .normal)
            TodayBillABtn.setTitleColor(UIColor.white, for: .normal)
            TodayBillABtn.layer.borderWidth = 0
            
            TodayBill1Btn.layer.cornerRadius = 8
            TodayBill1Btn.layer.borderWidth = Layer_BorderWidth
            TodayBill1Btn.setTitleColor(Orange_Color, for: .normal)
            TodayBill1Btn.setBackgroundImage(nil, for: .normal)
            TodayBill1Btn.layer.borderColor = Orange_Color.cgColor
            
            
            TodayBill0Btn.layer.cornerRadius = 8
            TodayBill0Btn.layer.borderWidth = Layer_BorderWidth
            TodayBill0Btn.setTitleColor(Orange_Color, for: .normal)
            TodayBill0Btn.setBackgroundImage(nil, for: .normal)
            TodayBill0Btn.layer.borderColor = Orange_Color.cgColor
        }
        
    }
}
