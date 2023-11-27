//
//  CardlessQryViewController.swift
//  AgriBank
//
//  Created by ABOT on 2022/9/19.
//  Copyright © 2022 Systex. All rights reserved.
//

import UIKit
let CardlessQryView_ShowAccount_Title = "帳號"
let CardlessView_ShowDetail_Segue = ""
let CardlessRemartTitle = "查詢資料僅供參考，確實數字請與開戶單位聯絡。"
var CardlessQry_Cell_Height:CGFloat = 60
var CardlessRowDouble:CGFloat = 1
var CardlessMemoLineConter:CGFloat = 1
var wkQSTATUS:String = "0"
var wkType3 = false
var wkType3Result:[String:Any]? = nil
 


class CardlessQryViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate,OneRowDropDownViewDelegate, UIActionSheetDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var chooseAccountView: UIView!
    @IBOutlet weak var LineView: UIView!
    @IBOutlet weak var Cardless0Btn: UIButton!
    @IBOutlet weak var Cardless1Btn: UIButton!
    @IBOutlet weak var Cardless2Btn: UIButton!
    
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
        tableView.register(UINib(nibName: UIID.UIID_CardlessQryCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_CardlessQryCell.NibName()!)
        // navigationController?.delegate = self
        setShadowView(LineView,.Bottom)
        topDropView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        topDropView?.m_lbFirstRowTitle.textAlignment = .center
        topDropView?.frame = chooseAccountView.frame
        topDropView?.frame.origin = .zero
        topDropView?.delegate = self
        topDropView?.setOneRow(CardlessQryView_ShowAccount_Title, Choose_Title)
        topDropView?.titleWeight.constant = (topDropView?.titleWeight.constant)! / 2
        chooseAccountView.addSubview(topDropView!)
        wkQSTATUS = "0"
        SetBtnColor()
      //  getTransactionID("16003", TransactionID_Description)
        
        postRequest("ACCT/ACCT0105", "ACCT0105", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"16003","Operate":"getAcnt","TransactionId":transactionId,"GetType":"1"], true), AuthorizationManage.manage.getHttpHead(true))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
          
        switch description {
//        case TransactionID_Description:
//            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
//                transactionId = tranId
//                setLoading(true)
//                postRequest("ACCT/ACCT0105", "ACCT0105", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"16003","Operate":"getAcnt","TransactionId":transactionId,"GetType":"1"], true), AuthorizationManage.manage.getHttpHead(true))
//
//            }
//            else {
//                super.didResponse(description, response)
//            }
//
        case "ACCT0105":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]]{
                accountList = [AccountStruct]()
                for category in array {
                            if let actNO = category["ACTNO"] as? String, let curcd = category["CURCD"] as? String, let bal = category["BAL"] as? String, let ebkfg = category["WCARDSTAT"] as? String  {
                                accountList?.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
                            }
                }
                    
                //2019-9-2 add by sweney -取index=0轉出帳號
                if(accountList?.count)! > 0 {
                    accountIndex = 0
                    if let info = accountList?[accountIndex!]{
                        topDropView?.setOneRow(CardlessQryView_ShowAccount_Title, info.accountNO)
                        let fmt = DateFormatter()
                        fmt.dateFormat = "yyyyMMdd"
                        //今天
                        let QrySDate: String = fmt.string(from: Date())
                        let currentDate = Date()
                        var dateComponent = DateComponents()
                        dateComponent.month = 1 //+1 month
                        //1個月後
                        let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
                        let QryEDate: String = fmt.string(from: futureDate!)
                        postRequest("TRAN/TRAN1104", "TRAN1104", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"16005","Operate":"getData","TransactionId":transactionId,"OUTACT":accountList?[accountIndex!].accountNO ?? "","SDATE":QrySDate,"EDATE":QryEDate,"QSTAT":"0"], true), AuthorizationManage.manage.getHttpHead(true))// QSTSAT:0:未提款0:已提款1:已取消
                    }
                }else{
                    //請使用晶片金融卡至ＡＴＭ設定提款帳號
                    let mmsg = "請使用晶片金融卡至ＡＴＭ設定提款帳號"
                    showAlert(title: UIAlert_Default_Title, msg: mmsg, confirmTitle: "確認", cancleTitle: nil, completionHandler: {
                        self.enterFeatureByID(.FeatureID_Home, true)
                    }, cancelHandelr: {()})
                }
            }
            else {
                super.didResponse(description, response)
            }
        case "TRAN1104-3":
                if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]]{
                    if array.count > 0 {
                        wkType3Result =  data
                        tableView.reloadData()
                    }
                }
           
//           let fmt = DateFormatter()
//           fmt.dateFormat = "yyyyMMdd"
//           //今天
//           let QrySDate: String = fmt.string(from: Date())
//           let currentDate = Date()
//           var dateComponent = DateComponents()
//           dateComponent.month = -1 //+1 month
//           //1個月後
//           let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
//           let QryEDate: String = fmt.string(from: futureDate!)
//           super.didResponse(description, response)
//           postRequest("TRAN/TRAN1104", "TRAN1104", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"16005","Operate":"getData","TransactionId":transactionId,"OUTACT":accountList?[accountIndex!].accountNO ?? "","SDATE":QryEDate,"EDATE":QrySDate,"QSTAT":"2"], true), AuthorizationManage.manage.getHttpHead(true))// QSTSAT:0:未提款1:已提款2:已取消
                     
        case "TRAN1104":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any]{
            result = data
           // result = [data,wkType3Result].flatMap { $0 }
                
                tableView.reloadData()
            }
            //}
        default:  super.didResponse(description, response)
            
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.sectionFooterHeight))
        view.backgroundColor = UIColor.white
        RowDouble = 1
        
        //備註提示
        let labelTitle = UILabel(frame:CGRect(x:10,y:3, width: 40,height:CardlessQry_Cell_Height))
        labelTitle.text = "備註"
        labelTitle.font = Default_Font
        labelTitle.textColor = Cell_Title_Color
        labelTitle.textAlignment = .center
        
        let label = UILabel(frame: CGRect(x: 60 ,y: 0, width: view.frame.width-60, height:CardlessQry_Cell_Height))
        label.text = CardlessRemartTitle
        label.font = Default_Font
        label.textColor = Cell_Detail_Color
        label.textAlignment = .left
        label.numberOfLines = 0
        view.addSubview(label)
        view.addSubview(labelTitle)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
       CardlessMemoLineConter = 1

        return CardlessQry_Cell_Height*MemoLineConter+5
        
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
                topDropView?.setOneRow(CardlessQryView_ShowAccount_Title, accountList?[accountIndex!].accountNO ?? "")
                SetBtnColor ()
                if accountList!.count > 0 {
                    let fmt = DateFormatter()
                    fmt.dateFormat = "yyyyMMdd"
                    //今天
                    let QrySDate: String = fmt.string(from: Date())
                    let currentDate = Date()
                    var dateComponent = DateComponents()
                    dateComponent.month = 1 //+1 month
                    //1個月後
                    let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
                    let QryEDate: String = fmt.string(from: futureDate!)
                    
                    setLoading(true)
                    postRequest("TRAN/TRAN1104", "TRAN1104", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"16005","Operate":"getData","TransactionId":transactionId,"OUTACT":accountList?[accountIndex!].accountNO ?? "","SDATE":QrySDate,"EDATE":QryEDate,"QSTAT":"0"], true), AuthorizationManage.manage.getHttpHead(true))
                    // QSTSAT:0:未提款0:已提款1:已取消
                    wkQSTATUS = "0"
                    SetBtnColor ()
                }
                
            default: break
            }
        }
    }
    
    @IBAction func Cardless0(_ sender: Any) {
        
        wkQSTATUS = "0"
        SetBtnColor()
        if accountList!.count > 0 {
            let fmt = DateFormatter()
            fmt.dateFormat = "yyyyMMdd"
            //今天
            let QrySDate: String = fmt.string(from: Date())
            let currentDate = Date()
            var dateComponent = DateComponents()
            dateComponent.month = -1 //+1 month
            //1個月後
            let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
            let QryEDate: String = fmt.string(from: futureDate!)
            
            setLoading(true)
            postRequest("TRAN/TRAN1104", "TRAN1104", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"16005","Operate":"getData","TransactionId":transactionId,"OUTACT":accountList?[accountIndex!].accountNO ?? "","SDATE":QryEDate,"EDATE":QrySDate,"QSTAT":"0"], true), AuthorizationManage.manage.getHttpHead(true))// QSTSAT:0:未提款1:已提款2:已取消
        }
    }
    @IBAction func Cardless1(_ sender: Any) {
        
        wkQSTATUS = "1"
        SetBtnColor()
       
        if accountList!.count > 0 {
            let fmt = DateFormatter()
            fmt.dateFormat = "yyyyMMdd"
            //今天
            let QrySDate: String = fmt.string(from: Date())
            let currentDate = Date()
            var dateComponent = DateComponents()
            dateComponent.month = -1 //+1 month
            //1個月後
            let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
            let QryEDate: String = fmt.string(from: futureDate!)
            
            setLoading(true)
            postRequest("TRAN/TRAN1104", "TRAN1104", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"16005","Operate":"getData","TransactionId":transactionId,"OUTACT":accountList?[accountIndex!].accountNO ?? "","SDATE":QryEDate,"EDATE":QrySDate,"QSTAT":"1"], true), AuthorizationManage.manage.getHttpHead(true))// QSTSAT:0:未提款0:已提款1:已取消
    }
    }
    @IBAction func Cardless2(_ sender: Any) {
        
        wkQSTATUS = "2"
        SetBtnColor()
        
        if accountList!.count > 0 {
            let fmt = DateFormatter()
            fmt.dateFormat = "yyyyMMdd"
            //今天
            let QrySDate: String = fmt.string(from: Date())
            let currentDate = Date()
            var dateComponent = DateComponents()
            dateComponent.month = -1 //+1 month
            //1個月後
            let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
            let QryEDate: String = fmt.string(from: futureDate!)
            
            postRequest("TRAN/TRAN1104", "TRAN1104-3", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"16005","Operate":"getData","TransactionId":transactionId,"OUTACT":accountList?[accountIndex!].accountNO ?? "","SDATE":QryEDate,"EDATE":QrySDate,"QSTAT":"3"], true), AuthorizationManage.manage.getHttpHead(true))// QSTSAT:0:未提款1:已提款2:已取消
            
            postRequest("TRAN/TRAN1104", "TRAN1104", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"16005","Operate":"getData","TransactionId":transactionId,"OUTACT":accountList?[accountIndex!].accountNO ?? "","SDATE":QryEDate,"EDATE":QrySDate,"QSTAT":"2"], true), AuthorizationManage.manage.getHttpHead(true))// QSTSAT:0:未提款1:已提款2:已取消
        }
    }
    
    //tv row counter
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var ctr = 0
        if let array = result?["Result"] as? [[String:String]] {
            ctr = ctr + array.count
        }
        if let array2 = wkType3Result?["Result"] as? [[String:String]] {
            ctr = ctr + array2.count
        }
       
        return ctr
    }
    //tv set row infor
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_CardlessQryCell.NibName()!, for: indexPath) as! CardlessQryCell
        var array:[[String:String]]? = nil
        
        if let array1 = result?["Result"] as? [[String:String]] {
            if array1.count > 0 {
                if array == nil {
                    array = array1
                }else{
                array!.append(contentsOf: array1)
                }
                result?["Result"] = array
            }
        }
        if let array2 = wkType3Result?["Result"] as? [[String:String]] {
            if array2.count > 0 {
                if array == nil {
                    array = array2
                }else{
                array!.append(contentsOf: array2)
                }
                result?["Result"] = array
            }
        }
               
        if array!.count > 0 {
            if let DATE = array![indexPath.row]["ReserveDATE"]  {
                if let TIME = array![indexPath.row]["ReserveTIME"]  {
                    cell.CDATELabel.text = DATE.trimmingCharacters(in: .whitespaces) + " " + TIME.trimmingCharacters(in: .whitespaces)
                }
            }
           
            if let TXAMT = array![indexPath.row]["TXAMT"]  {
                cell.CLTXAMTLabel.text = TXAMT.trimmingCharacters(in: .whitespaces)
            }
            if let STATUSC = array![indexPath.row]["STAT"] {
          switch STATUSC.trimmingCharacters(in: .whitespaces){
            case "0":
              cell.CLSTATUSTLabel.text = "未提款"
              cell.EntryRight.isHidden = false
              
            case "1":
                cell.CLSTATUSTLabel.text = "已提款"
              cell.EntryRight.isHidden = true
            case "2":
                cell.CLSTATUSTLabel.text = "已取消"
              cell.EntryRight.isHidden = true
          case "3":
              cell.CLSTATUSTLabel.text = "已失效"
            cell.EntryRight.isHidden = true
            default:
              cell.CLSTATUSTLabel.text = "未提款"
              cell.EntryRight.isHidden = false
                }
            }
           
        }
        return cell
    }
    
  
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 92
    }
    
    
    func  numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let array = result?["Result"] as? [[String:String]], let stat = array[indexPath.row]["STAT"], stat == "0" {
            curIndex = indexPath.row
            let curCell = array[indexPath.row]
            var data : [String:String] = [String:String]()
            data["WorkCode"] = "16006"
            data["Operate"] = "commitTxn"
            data["TransactionId"] = transactionId
            let fmt = DateFormatter()
            fmt.dateFormat = showDateFormat
            let DATE = fmt.date(from:curCell["ReserveDATE"]!)!
            let fmt2 = DateFormatter()
            fmt2.dateFormat = "yyyyMMdd"
            let RDATE = fmt2.string(from: DATE)
            data["ReserveDATE"] = RDATE
            data["ReserveOTP"] = curCell["ReserveOTP"]
            data["OUTACT"] = accountList?[accountIndex!].accountNO ?? ""
            data["TXAMT"] = curCell["TXAMT"]
            let confirmRequest = RequestStruct(strMethod: "TRAN/TRAN1103", strSessionDescription: "TRAN1103", httpBody: AuthorizationManage.manage.converInputToHttpBody2(data, true), loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false, timeOut: REQUEST_TIME_OUT)
            var dataConfirm = ConfirmResultStruct(image: ImageName.CowCheck.rawValue, title: Check_Transaction_Title, list: [[String:String]](), memo: "", confirmBtnName: "取消此預約", resultBtnName: "繼續交易", checkRequest: confirmRequest)
            dataConfirm.list?.append([Response_Key: "預約時間", Response_Value: curCell["ReserveDATE"]! + " " + curCell["ReserveTIME"]!])
            dataConfirm.list?.append([Response_Key: "失效時間", Response_Value: curCell["EXPDATE"]! + " " + curCell["EXPTIME"]!])
            dataConfirm.list?.append([Response_Key: "提款序號", Response_Value: curCell["ReserveOTP"]!])
            var tranact = (accountList?[accountIndex!].accountNO ?? "")
            let start = tranact.index(tranact.startIndex,offsetBy: 6)
            let end = tranact.index(tranact.startIndex,offsetBy: 4+6)
            tranact.replaceSubrange(start..<end, with: "****")
            dataConfirm.list?.append([Response_Key: "提款帳號",  Response_Value:tranact ])
            dataConfirm.list?.append([Response_Key: "提款金額", Response_Value: curCell["TXAMT"]!.separatorThousand()])
      // ( controller as! ConfirmViewController).setCardless(true)
             enterConfirmResultController(true, dataConfirm, true,"取消無卡提款預約")
        }
    }
    private func enterConfirmView() {
        
       
        
      
    }
 
    func SetBtnColor () {
        result = nil
        wkType3Result = nil
        tableView.reloadData()
        switch wkQSTATUS {
        case "0":
            Cardless0Btn.setBackgroundImage(UIImage(named: "ButtonSmall"), for: .normal)
            Cardless0Btn.setTitleColor(UIColor.white, for: .normal)
            Cardless0Btn.layer.borderWidth = 0
            
            Cardless1Btn.layer.cornerRadius = 8
            Cardless1Btn.layer.borderWidth = Layer_BorderWidth
            Cardless1Btn.setTitleColor(Orange_Color, for: .normal)
            Cardless1Btn.setBackgroundImage(nil, for: .normal)
            Cardless1Btn.layer.borderColor = Orange_Color.cgColor
            
            
            Cardless2Btn.layer.cornerRadius = 8
            Cardless2Btn.layer.borderWidth = Layer_BorderWidth
            Cardless2Btn.setTitleColor(Orange_Color, for: .normal)
            Cardless2Btn.setBackgroundImage(nil, for: .normal)
            Cardless2Btn.layer.borderColor = Orange_Color.cgColor
            
        case "1":
            Cardless1Btn.setBackgroundImage(UIImage(named: "ButtonSmall"), for: .normal)
            Cardless1Btn.setTitleColor(UIColor.white, for: .normal)
            Cardless1Btn.layer.borderWidth = 0
            
            Cardless0Btn.layer.cornerRadius = 8
            Cardless0Btn.layer.borderWidth = Layer_BorderWidth
            Cardless0Btn.setTitleColor(Orange_Color, for: .normal)
            Cardless0Btn.setBackgroundImage(nil, for: .normal)
            Cardless0Btn.layer.borderColor = Orange_Color.cgColor
            
            
            Cardless2Btn.layer.cornerRadius = 8
            Cardless2Btn.layer.borderWidth = Layer_BorderWidth
            Cardless2Btn.setTitleColor(Orange_Color, for: .normal)
            Cardless2Btn.setBackgroundImage(nil, for: .normal)
            Cardless2Btn.layer.borderColor = Orange_Color.cgColor
        case "2":
            Cardless2Btn.setBackgroundImage(UIImage(named: "ButtonSmall"), for: .normal)
            Cardless2Btn.setTitleColor(UIColor.white, for: .normal)
            Cardless2Btn.layer.borderWidth = 0
            
            Cardless1Btn.layer.cornerRadius = 8
            Cardless1Btn.layer.borderWidth = Layer_BorderWidth
            Cardless1Btn.setTitleColor(Orange_Color, for: .normal)
            Cardless1Btn.setBackgroundImage(nil, for: .normal)
            Cardless1Btn.layer.borderColor = Orange_Color.cgColor
            
            
            Cardless0Btn.layer.cornerRadius = 8
            Cardless0Btn.layer.borderWidth = Layer_BorderWidth
            Cardless0Btn.setTitleColor(Orange_Color, for: .normal)
            Cardless0Btn.setBackgroundImage(nil, for: .normal)
            Cardless0Btn.layer.borderColor = Orange_Color.cgColor
        default:
            Cardless0Btn.setBackgroundImage(UIImage(named: "ButtonSmall"), for: .normal)
            Cardless0Btn.setTitleColor(UIColor.white, for: .normal)
            Cardless0Btn.layer.borderWidth = 0
            
            Cardless1Btn.layer.cornerRadius = 8
            Cardless1Btn.layer.borderWidth = Layer_BorderWidth
            Cardless1Btn.setTitleColor(Orange_Color, for: .normal)
            Cardless1Btn.setBackgroundImage(nil, for: .normal)
            Cardless1Btn.layer.borderColor = Orange_Color.cgColor
            
            
            Cardless2Btn.layer.cornerRadius = 8
            Cardless2Btn.layer.borderWidth = Layer_BorderWidth
            Cardless2Btn.setTitleColor(Orange_Color, for: .normal)
            Cardless2Btn.setBackgroundImage(nil, for: .normal)
            Cardless2Btn.layer.borderColor = Orange_Color.cgColor
        }
        
    }
}

