//
//  USAccountShowViewController.swift
//  AgriBank
//
//  Created by ABOT on 2019/10/5.
//  Copyright © 2019 Systex. All rights reserved.
//

import UIKit
import WebKit

let USAccountAdd_Segue = "GoUSAdd"
let USAccountEdit_Segue = "GoUSEdit"


var IN_BR_CODE    = "" //銀行代號
var FullName      = "" //銀行名稱
var ACTNO         = "" //轉入帳號
var EXPLANATION   = "" //說明
var NOTE          = "" //備註
var P_KEY         = "" // db key
var EMAIL_ADDR    = "" //email


class USAccountShowViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, WKNavigationDelegate {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var BtnAdd: UIButton!
    @IBOutlet weak var LineView: UIView!
    private var topDropView:OneRowDropDownView? = nil
       private var errorMessage = ""
    
    private var result:[String:Any]? = nil                          // 電文Response
    private var oneResult:[String:Any]? = nil                       // 電文Response
    private var curIndex:Int? = nil                                 // result["Result"] => Array, Array的Index
 
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: UIID.UIID_USAccountViewCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_USAccountViewCell.NibName()!)
        self.BtnAdd.isHidden = false
        setShadowView(LineView,.Bottom)
        getTransactionID("03007", TransactionID_Description)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
  //接收訊息處理
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        //get TransactionID
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
               setLoading(true)
                //收到TransactionID後 判斷3007送查詢
                if let WkCd = response.object(forKey: "WorkCode") as? String , WkCd == "03007" {
                postRequest("TRAN/TRAN0704", "TRAN0704", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03007","Operate":"dataList","TransactionId":transactionId], true), AuthorizationManage.manage.getHttpHead(true))
                }else {
                       self.postRequest("TRAN/TRAN0703", "TRAN0703", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03008","Operate":"DelCommAcct","TransactionId":transactionId,"P_KEY":P_KEY], true), AuthorizationManage.manage.getHttpHead(true))
                }
            }
            else {
                super.didResponse(description, response)
            }
            
       //get 常用帳號
        case "TRAN0704":
             let data = response.object(forKey: ReturnData_Key) as? [String:Any]
           result = data
            // let array = result?["Result"] as? [[String:String]]
             
            tableView.reloadData()
        //delet 常用帳號
        case "TRAN0703":
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {
                if let message = response.object(forKey: ReturnMessage_Key) as? String {
                    errorMessage = message
                }
            }else{
                   enterFeatureByID(.FeatureID_USAccount ,false)
            }
            
           // performSegue(withIdentifier: USAccountResult_Seque, sender: nil)
            // self.setLoading(false)
            
            
        default: super.didResponse(description, response)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_USAccountViewCell.NibName()!, for: indexPath) as! USAccountViewCell
        if let array = result?["Result"] as? [[String:String]] {
            
            if let IN_BR_CODE = array[indexPath.row]["IN_BR_CODE"]  {
                cell.bankcodeLabel.text = IN_BR_CODE.trimmingCharacters(in: .whitespaces)
            }
            if let FullName = array[indexPath.row]["FullName"]  {
                cell.bankNameLabel.text = FullName.trimmingCharacters(in: .whitespaces)
            }
            if let ACTNO = array[indexPath.row]["ACTNO"] {
                cell.AccountLabel.text = ACTNO.trimmingCharacters(in: .whitespaces)
            }
            if let EXPLANATION = array[indexPath.row]["EXPLANATION"] {
                cell.RemarkLabel.text = EXPLANATION.trimmingCharacters(in: .whitespaces)
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
    
        
   
    
    func  numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (result?["Result"] as? [[String:String]]) != nil {
            curIndex = indexPath.row
          
        }
    }
  
    
        
        func  btnDelAction(_ sender: UIButton)  {
            
            if  let array = result?["Result"] as? [[String:String]]{
                IN_BR_CODE   = (array[sender.tag]["IN_BR_CODE"]! as NSString) as String
                FullName     = (array[sender.tag]["FullName"]! as NSString) as String
                ACTNO        = (array[sender.tag]["ACTNO"]! as NSString) as String
                EXPLANATION  = (array[sender.tag]["EXPLANATION"]! as NSString) as String
                P_KEY        = (array[sender.tag]["P_KEY"]! as NSString) as String
            }
            //show del msg
            let confirmHandler : ()->Void = {
          self.setLoading(true)
                self.getTransactionID("03008", TransactionID_Description)
                
            }
            let cancelHandler : ()->Void = {()}
            showAlert(title: "注意", msg: "請確認要刪除這筆轉入帳號?\n" + IN_BR_CODE + "-" + FullName + "\n" + ACTNO  + EXPLANATION , confirmTitle: "確認送出", cancleTitle: "取消", completionHandler: confirmHandler, cancelHandelr: cancelHandler)
        }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == USAccountEdit_Segue {
            let controller = segue.destination as! USAccountEditViewController
            var list = [[String:String]]()
            list.append([Response_Key: "銀行代號", Response_Value:IN_BR_CODE])
            list.append([Response_Key: "銀行名稱", Response_Value:FullName])
            list.append([Response_Key: "EMAIL", Response_Value:EMAIL_ADDR])
            list.append([Response_Key: "轉轉入帳號", Response_Value:ACTNO])
            list.append([Response_Key: "說明", Response_Value:EXPLANATION])
            list.append([Response_Key: "備註", Response_Value:NOTE])
            list.append([Response_Key: "P_KEY", Response_Value:P_KEY])
           
            controller.setList(list)
        }
    }
        
        func  btnEditAction(_ sender: UIButton) {
           
            if  let array = result?["Result"] as? [[String:String]]{
                
                 IN_BR_CODE = (array[sender.tag]["IN_BR_CODE"]! as NSString) as String
                 FullName = (array[sender.tag]["FullName"]! as NSString) as String
                 ACTNO = (array[sender.tag]["ACTNO"]! as NSString) as String
                 EXPLANATION = (array[sender.tag]["EXPLANATION"]! as NSString) as String
                 EMAIL_ADDR = (array[sender.tag]["EMAIL_ADDR"]! as NSString) as String
                 NOTE = (array[sender.tag]["NOTE"]! as NSString) as String
                 P_KEY = (array[sender.tag]["P_KEY"]! as NSString) as String
              
            performSegue(withIdentifier: USAccountEdit_Segue, sender: self)
                
            }
        }

    @IBAction func BtnAdd(_ sender: Any) {
        performSegue(withIdentifier: USAccountAdd_Segue, sender: nil)
     
 
    }
}

