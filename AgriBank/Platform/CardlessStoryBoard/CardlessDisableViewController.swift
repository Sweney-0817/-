//
//  CardlessDisableViewController.swift
//  AgriBank
//
//  Created by ABOT on 2022/9/21.
//  Copyright © 2022 Systex. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class CardlessDisableViewController:BaseViewController,UITableViewDelegate,UITableViewDataSource,WKNavigationDelegate{
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var LineView: UIView!
    private var errorMessage = ""
    private var result:[String:Any]? = nil                          // 電文Response
    private var oneResult:[String:Any]? = nil                       // 電文Response
    private var curIndex:Int? = nil
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: UIID.UIID_CardlessDisableCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_CardlessDisableCell.NibName()!)
        setShadowView(LineView,.Bottom)
       // getTransactionID("16003", TransactionID_Description)
        postRequest("ACCT/ACCT0105", "ACCT0105", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"16003","Operate":"getAcnt","TransactionId":transactionId,"GetType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //接收訊息處理
      override func didResponse(_ description:String, _ response: NSDictionary) {
          switch description {
          //get TransactionID
//          case TransactionID_Description:
//              if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
//                  transactionId = tranId
//                 setLoading(true)
//                  //收到TransactionID後  送查詢
//                  postRequest("ACCT/ACCT0105", "ACCT0105", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"16003","Operate":"getAcnt","TransactionId":transactionId,"GetType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
//              }
//              else {
//                  super.didResponse(description, response)
//              }
          case "ACCT0105Transaction":
              if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                  transactionId = tranId
                  postRequest("ACCT/ACCT0105", "ACCT0105", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"16003","Operate":"getAcnt","TransactionId":transactionId,"GetType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
              }
              
         //get 無卡帳號
          case "ACCT0105":
               let data = response.object(forKey: ReturnData_Key) as? [String:Any]
              result = data
              tableView.reloadData()
          //disable OK
          case "TRAN1105":
              if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {
                  if let message = response.object(forKey: ReturnMessage_Key) as? String {
                      errorMessage = message
                  }
              }else{
                  //重取帳號
                   getTransactionID("16003", "ACCT0105Transaction")
                 
              }
              
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
          let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_CardlessDisableCell.NibName()!, for: indexPath) as! CardlessDisableCell
          if let array = result?["Result"] as? [[String:String]] {
              
              if let ACTNO = array[indexPath.row]["ACTNO"] {
                  cell.CardlessAct.text = ACTNO.trimmingCharacters(in: .whitespaces)
              }
              if let WCARDSTAT = array[indexPath.row]["WCARDSTAT"] {
            switch WCARDSTAT
                  {
              case "1":
                cell.CardlessStatus.text = "正常"
                cell.CardlessDisableBtn.isHidden = false
              case "2":
                  cell.CardlessStatus.text = "停用"
                cell.CardlessDisableBtn.isHidden = true
              case "3":
                  cell.CardlessStatus.text = "關閉"
                cell.CardlessDisableBtn.isHidden = true
              default:
                  cell.CardlessStatus.text = "正常"
                cell.CardlessDisableBtn.isHidden = false
              }
                  //記住index in tag
                  cell.CardlessDisableBtn.tag=indexPath.row
                 cell.CardlessDisableBtn.addTarget(self, action: #selector(self.btnDelAction(_:)), for: .touchUpInside)
              }
          }
          return cell
      }
      
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
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
              
              if  let array = result?["Result"] as? [[String:String]] {
                ACTNO = (array[sender.tag]["ACTNO"]! as NSString)  as String
                  //show del msg
                  let confirmHandler : ()->Void = {
                  self.setLoading(true)
                      self.postRequest("TRAN/TRAN1105", "TRAN1105", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"16007","Operate":"commitTxn","TransactionId":self.transactionId,"OUTACT":ACTNO], true), AuthorizationManage.manage.getHttpHead(true))
                      
                  }
                  let cancelHandler : ()->Void = {()}
                  showAlert(title: "注意", msg: "請確定關閉帳號" + ACTNO + "預約提款功能，重新啟用須使用晶片金融卡至ATM設定" , confirmTitle: "確認送出", cancleTitle: "取消", completionHandler: confirmHandler, cancelHandelr: cancelHandler)
                  }
              }
    
      }

 
