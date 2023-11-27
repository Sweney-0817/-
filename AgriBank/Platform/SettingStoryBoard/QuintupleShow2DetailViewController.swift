//
//  QuintupleShow2DetailViewController.swift
//  AgriBank
//
//  Created by ABOT on 2021/9/14.
//  Copyright © 2021 Systex. All rights reserved.
//

import UIKit
let show2GoToQuintupleView_Segue = "show2GoToQuintupleView"
let show2GoToQuintupleResult_Segue = "show2GoToQuintupleResult"
class QuintupleShow2DetailViewController:BaseViewController ,UITableViewDataSource, UITableViewDelegate {
    private var barTitle:String? = nil
    private var list:[[String:String]]? = nil
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ButBack: UIButton!
    @IBOutlet weak var BtnShowRefundCode: UIButton!
    private var memo:String? = nil
    private var isSuccess = false
    private var titleStatus = ""
    private var readStatus = ""
    private var transId = ""
    private var errorMessage = ""
    private var QuintupleCodeInfo: [String: String] = [:]
    private var txnNo = ""
    // MARK: - Public
//     func setInitial(_ list:[[String:String]]?, _ isSuccess:Bool, _ title:String, _ memo:String? = nil) {
//           self.list = list
//           self.isSuccess = isSuccess
//           self.titleStatus = title
//           self.memo = memo
//       }
    func setList(_ title:String, _ list:[[String:String]],_ reads:String, _ m_txnNo:String) {
        self.barTitle = title
        self.list = list
        readStatus = reads
        self.txnNo = m_txnNo
    }
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if readStatus == "2"{
            
        }
        navigationItem.leftBarButtonItem = nil
        navigationItem.setHidesBackButton(true, animated:true)
               // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.register(UINib(nibName: UIID.UIID_ResultCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultCell.NibName()!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.topItem?.title = barTitle
    }
    
  //取消綁定
    @IBAction func BtnCancleBind(_ sender: Any) {
        enterFeatureByID(.FeatureID_Home, false)
     /*   getTransactionID("09008", TransactionID_Description)
        let message = "確認取消綁定？"
        let confirmHandler : ()->Void = {

            self.setLoading(true)
            if AuthorizationManage.manage.GetLoginInfo() != nil{
                self.postRequest("QR/QR1004", "QR1004", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"11003","Operate":"dataCongirm","TransactionId":self.transactionId,"txnNo":self.txnNo], true), AuthorizationManage.manage.getHttpHead(true))
            }

        }
        let cancelHandler : ()->Void = {()}
        showAlert(title: "注意", msg: message , confirmTitle: "確認送出", cancleTitle: "取消", completionHandler: confirmHandler, cancelHandelr: cancelHandler)
*/
    }
 //更改領取方式
    @IBAction func BtnChangeRewardCode(_ sender: Any) {
        transactionId = tempTransactionId
         performSegue(withIdentifier: show2GoToQuintupleView_Segue, sender: nil)
        isBack = "ChangeReward"
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == FirstQuintuple_BackSeq
          {
              let controller = segue.destination as! QuintupleViewController
              
          }
        //取消綁定
        if segue.identifier == show2GoToQuintupleResult_Segue
           {
               let controller = segue.destination as! QuintupleResultViewController
               var list = [[String:String]]()
            if let BINDNO =  QuintupleCodeInfo[("原綁定序號")]{
                    list.append([Response_Key: "原綁定序號", Response_Value:BINDNO ])
                    
               }
               else {
                   list.append([Response_Key: "原綁定序號", Response_Value:""])
                   
               }
            if let BINDStatus =  QuintupleCodeInfo[("綁定狀態")]{
                   list.append([Response_Key: "綁定狀態", Response_Value:BINDStatus ])
               }
               else {
                   list.append([Response_Key: "綁定狀態", Response_Value:""])
               }
            if let CnlBINDTime =  QuintupleCodeInfo[("取消綁定時間")]{
                   list.append([Response_Key: "取消綁定時間", Response_Value:CnlBINDTime ])
               }
               else {
                   list.append([Response_Key: "取消綁定時間", Response_Value:""])
               }
               controller.setList(QuintupleTitle, list)
           }
    }
 // MARK: - UITableViewDelegate
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            let height = ResultCell.GetStringHeightByWidthAndFontSize(list?[indexPath.row][Response_Value] ?? "", tableView.frame.size.width)
            return height
        }
        
        func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            if section == 0 {
                return tableView.sectionFooterHeight
            }
            else {
                if memo == nil {
                    return 0
                }
                else {
                    return MemoView.GetStringHeightByWidthAndFontSize(memo!, tableView.frame.width)
                }
            }
        }
        
        func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
            if section == 0 {
                let head = getUIByID(.UIID_ShowMessageHeadView) as! ShowMessageHeadView
                head.titleLabel.text = titleStatus
                head.imageView.image = isSuccess ? UIImage(named: ImageName.CowSuccess.rawValue) : UIImage(named: ImageName.CowFailure.rawValue)
                return head
            }
            else {
                if memo == nil {
                    return nil
                }
                else {
                    let footer = getUIByID(.UIID_MemoView) as! MemoView
                    footer.set(memo!)
                    return footer
                }
            }
        }
        // MARK: - UITableViewDataSource
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
               return list?.count ?? 0
           }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell
            cell.set((list?[indexPath.row][Response_Key])!, (list?[indexPath.row][Response_Value])!)
            return cell
        }
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
     override func didResponse(_ description:String, _ response: NSDictionary) {
               switch description {
              
                case "QR1004":
                   if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {
                       if let message = response.object(forKey: ReturnMessage_Key) as? String {
                           errorMessage = message
                           showAlert(title: "綁定時發生錯誤", msg:errorMessage, confirmTitle: "確定", cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                       }
                    }
                   else
                    {
                        
                        if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]]{
                            for item in array {
                                let Key: String = item["Key"] as! String
                                let Value: String = item["Value"] as! String
                                QuintupleCodeInfo[Key] = Value
                            }
                           
                        }
                        transactionId = tempTransactionId
                        
                       performSegue(withIdentifier: show2GoToQuintupleResult_Segue, sender: nil)
                           }
                
               case TransactionID_Description:
                   if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                       transactionId = tranId
//                       setLoading(true)
//                    if isBack == "YES"{
//                        isBack = ""
//                        postRequest("Usif/USIF0101", "USIF0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"08001","Operate":"queryData","TransactionId":tranId], true), AuthorizationManage.manage.getHttpHead(true))
//                    }else{
//                        var ibind = ""
//                        if readStatus == "0"{
//                            ibind = "0"
//                        }else{
//                            ibind = "1"
//                        }
//                        postRequest("QR/QR1001", "QR1001", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"110011","Operate":"dataContirm","TransactionId":tranId,"uid": AgriBank_DeviceID,"rebind":ibind], true), AuthorizationManage.manage.getHttpHead(true))
//                    }
//
                   }
                   else {
                      super.didResponse(description, response)
                   }

               default: super.didResponse(description, response)
               }
           }
    }
/*
 list    [[String : String]]?    1 value    some
 [0]    [String : String]    8 key/value pairs
 [0]    (key: String, value: String)
 key    String    "Content"
 value    String    "已綁定"
 [1]    (key: String, value: String)
 key    String    "Read"
 value    String    "2"
 [2]    (key: String, value: String)
 key    String    "Version"
 value    String    ""
 [3]    (key: String, value: String)
 key    String    "rewardTp"
 value    String    "0"
 [4]    (key: String, value: String)
 key    String    "txnNo"
 value    String    "0004931039"
 [5]    (key: String, value: String)
 key    String    "donateCode"
 value    String    ""
 [6]    (key: String, value: String)
 key    String    "phone"
 value    String    " "  //chris0728
 [7]    (key: String, value: String)
 key    String    "CIFERR"
 value    String    "D120998998"
 */


