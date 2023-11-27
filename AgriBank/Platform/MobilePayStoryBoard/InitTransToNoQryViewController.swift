//
//  InitTransToNoQryViewController.swift
//  AgriBank
//
//  Created by ABOT on 2020/3/10.
//  Copyright © 2020 Systex. All rights reserved.
//

import UIKit

let InT_Edit_Segue = "GoToInitActNoEdit"

let NTTransTo_OutAccount = "轉出帳號"
let NTTransTo_Currency = "幣別"

var  InT_BKNO     = "" //銀行代號
var  InT_TRAC     = "" //轉入帳號
var  InT_NOTE     = "" //註記
var  InT_P_KEY    = "" //db key
var  InT_SORT     = "" //註記

class InitTransToNoQryViewController: BaseViewController,TwoRowDropDownViewDelegate  ,OneRowDropDownViewDelegate,UITableViewDelegate,UITableViewDataSource ,UIActionSheetDelegate {
   
      
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
      private var oneDropView:OneRowDropDownView? = nil
    private var topDropView:TwoRowDropDownView? = nil
    private var accountList:[AccountStruct]? = nil      // 帳號列表
    private var accountIndex:Int? = nil                 // 目前選擇轉出帳號
    private var inputAccount:String? = nil              // 由「帳戶總覽」帶入的帳號
      private var errorMessage = ""
    private var agreedAccountList:[[String:Any]]? = nil // 約定帳戶列表
    private var m_DDTransInBank: OneRowDropDownView? = nil //
    private var curIndex:Int? = nil
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //define UIID ,then add it
        tableView.register(UINib(nibName: UIID.UIID_InitTransToCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_InitTransToCell.NibName()!)
      
        //新增轉出帳號下拉選單
        topDropView = getUIByID(.UIID_TwoRowDropDownView) as? TwoRowDropDownView
        topDropView?.setTwoRow(NTTransTo_OutAccount, Choose_Title,NTTransTo_Currency,"") 
        topDropView?.frame = topView.frame
               topDropView?.frame.origin = .zero
               topDropView?.delegate = self
               topView.addSubview(topDropView!)
               setShadowView(topView)
               topView.layer.borderWidth = Layer_BorderWidth
               topView.layer.borderColor = Gray_Color.cgColor
        
        addObserverToKeyBoard()
               addGestureForKeyBoard()
        
        getTransactionID("02001", TransactionID_Description)
    }
    
    
    
    override func didReceiveMemoryWarning() {
           super.didReceiveMemoryWarning()
           // Dispose of any resources that can be recreated.
       }
    //接收處理
    override func didResponse(_ description:String, _ response: NSDictionary) {
        
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
               
                setLoading(true)
                
                   if let WkCd = response.object(forKey: "WorkCode") as? String , WkCd == "02001" {
                    //收到TransactionID後 送轉出帳號查詢
                    postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
                   }else{
                //03008 = > delete remark
                      self.postRequest("TRAN/TRAN0706", "TRAN0706", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03008","Operate":"DelCommAcct","TransactionId":self.transactionId,"P_KEY":InT_P_KEY], true), AuthorizationManage.manage.getHttpHead(true))
                }
            }
            else {
                super.didResponse(description, response)
            }
        case "ACCT0101":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]]{
                for category in array {
                    if let type = category["ACTTYPE"] as? String, let result = category["AccountInfo"] as? [[String:Any]], type == Account_Saving_Type {
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
                                if let info = accountList?[0] {
                                    topDropView?.setTwoRow(NTTransTo_OutAccount, info.accountNO, NTTransTo_Currency, (info.currency == Currency_TWD ? Currency_TWD_Title:info.currency) )
                                    setLoading(true)
                                                        postRequest("ACCT/ACCT0102", "ACCT0102", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02002","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0","ACTNO":info.accountNO  ], true), AuthorizationManage.manage.getHttpHead(true))
                            break
                        
                    }}
            }
            else {
                super.didResponse(description, response)
            }
        case "ACCT0102":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any] {
                if let array = data["Result"] as? [[String:Any]] {
                    agreedAccountList = array
                    
                    tableView.reloadData()
                    
                }}
            case "TRAN0706":
               if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {
                               if let message = response.object(forKey: ReturnMessage_Key) as? String {
                                   errorMessage = message
                               }
                           }else{
                                   postRequest("ACCT/ACCT0102", "ACCT0102", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02002","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0","ACTNO":accountList?[accountIndex!].accountNO ?? ""], true), AuthorizationManage.manage.getHttpHead(true))
                           }
                           
        default: super.didResponse(description, response)
        }
    }
    
     
   

       // MARK: - UITableViewDataSource
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           
                  return agreedAccountList?.count ?? 0
           
          }
    
        //tv set row infor
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_InitTransToCell.NibName()!, for: indexPath) as! InitTransToCell
           if let array = agreedAccountList as? [[String:String]] {
               
               if let BKNO = array[indexPath.row]["BKNO"]  {
                   cell.LabelBank.text = BKNO.trimmingCharacters(in: .whitespaces)
               }
               if let TRAC = array[indexPath.row]["TRAC"] {
                   cell.LabelActNo.text = TRAC.trimmingCharacters(in: .whitespaces)
               }
               if let NOTE = array[indexPath.row]["NOTE"] {
                   cell.LabelRemark.text = NOTE.trimmingCharacters(in: .whitespaces)
               }
               if let SORT = array[indexPath.row]["SORT"] {
                   if SORT == "255"{
                       cell.LabelSort.text = "排序:無"
                   }else{
                   cell.LabelSort.text = "排序:" + SORT.trimmingCharacters(in: .whitespaces)
                   }
               }
               //記住index in tag
               cell.btnDel.tag=indexPath.row
               cell.btnEdit.tag=indexPath.row
               
               cell.btnDel.addTarget(self, action: #selector(self.btnDelAction(_:)), for: .touchUpInside)
               cell.btnEdit.addTarget(self, action: #selector( self.btnEditAction(_:)), for: .touchUpInside)
               cell.btnDel.isHidden = false
               cell.btnEdit.isHidden = false
           }
           return cell
       }
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                  curIndex = indexPath.row
              }
       func  numberOfSections(in tableView: UITableView) -> Int {
              return 1
          }
       
       func  btnDelAction(_ sender: UIButton)  {
           
           if  let array = agreedAccountList as? [[String:String]]{
             InT_BKNO        = (array[sender.tag]["BKNO"]! as NSString) as String
             InT_TRAC        = (array[sender.tag]["TRAC"]! as NSString) as String
             InT_NOTE        = (array[sender.tag]["NOTE"]! as NSString) as String
             InT_P_KEY       = (array[sender.tag]["P_KEY"]! as NSString) as String
               InT_SORT = (array[sender.tag]["SORT"]! as NSString) as String
            if InT_P_KEY == "" {
                let alert = UIAlertView(title: "注意", message: "未編輯註記，無法刪除。", delegate: nil, cancelButtonTitle:Determine_Title)
                           alert.show()
            }else {
          
           //show del msg
           let confirmHandler : ()->Void = {
               self.setLoading(true)
            self.getTransactionID("03008", TransactionID_Description)
               //self.postRequest("TRAN/TRAN0706", "TRAN0706", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03008","Operate":"DelCommAcct","TransactionId":self.transactionId,"P_KEY":InT_P_KEY], true), AuthorizationManage.manage.getHttpHead(true))
               
           }
           let cancelHandler : ()->Void = {()}
           showAlert(title: "注意", msg: "請確認要刪除這筆轉入帳號註記?\n" + InT_BKNO + "\n" + InT_TRAC + "\n" + InT_NOTE  , confirmTitle: "確認送出", cancleTitle: "取消", completionHandler: confirmHandler, cancelHandelr: cancelHandler)
           }
        }
       }

       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == InT_Edit_Segue {
               let controller = segue.destination as! InitTransToNoEditViewController
               var list = [[String:String]]()
               list.append([Response_Key: "銀行代號", Response_Value:InT_BKNO])
               list.append([Response_Key: "轉轉入帳號", Response_Value:InT_TRAC])
               list.append([Response_Key: "註記", Response_Value:InT_NOTE])
               list.append([Response_Key: "P_KEY", Response_Value:InT_P_KEY])
               list.append([Response_Key: "排序", Response_Value:InT_SORT])
               controller.setList(list)
           }
       }
       
       func  btnEditAction(_ sender: UIButton) {
           if  let array = agreedAccountList as? [[String:String]]{
               InT_BKNO        = (array[sender.tag]["BKNO"]! as NSString) as String
               InT_TRAC        = (array[sender.tag]["TRAC"]! as NSString) as String
               InT_NOTE        = (array[sender.tag]["NOTE"]! as NSString) as String
               InT_P_KEY       = (array[sender.tag]["P_KEY"]! as NSString) as String
               InT_SORT        = (array[sender.tag]["SORT"]! as NSString) as String
               performSegue(withIdentifier: InT_Edit_Segue, sender: self)
           }
       }
     // MARK: -TwoRowDropDownViewDelegate
    func clickTwoRowDropDownView(_ sender: TwoRowDropDownView) {
        if accountList != nil {
            let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
                   accountList?.forEach{index in actSheet.addButton(withTitle: index.accountNO)}
                   actSheet.tag = ViewTag.View_AccountActionSheet.rawValue
                   actSheet.show(in: view)
               }
               else {
                   showErrorMessage(nil, "\(Get_Null_Title)\(topDropView?.m_lbFirstRowTitle.text ?? "")")
               }
    }
    
  
    // MARK: - OneRowDropDownViewDelegate
       func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
           if accountList != nil && accountList?.count != 0 {
            let actSheet = UIActionSheet(title: Choose_Title, delegate: self , cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
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
                 
                  topDropView?.setTwoRow(NTTransTo_OutAccount, accountList?[accountIndex!].accountNO ?? "", NTTransTo_Currency, (accountList?[accountIndex!].currency == Currency_TWD ? Currency_TWD_Title:accountList?[accountIndex!].currency)! )
                
                agreedAccountList = nil
                
                tableView.reloadData()
                
                  if accountList!.count > 0 {
                      setLoading(true)
                      postRequest("ACCT/ACCT0102", "ACCT0102", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02002","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0","ACTNO":accountList?[accountIndex!].accountNO ?? ""], true), AuthorizationManage.manage.getHttpHead(true))
                  }
                  
              default: break
              }
          }
      }
 
}
    
 
