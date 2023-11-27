//
//  OTPDeviceEditViewController.swift
//  AgriBank
//
//  Created by 數位資訊部 on 2020/11/19.
//  Copyright © 2020 Systex. All rights reserved.
//

import UIKit

//let USAccountAdd_Segue = "GoUSAdd"
let OTPDeviceEdit_Segue = "GoOTPDeviceEdit"

var MobileType    = "" //手機別
var CreateDate   = "" //申請日
var Remark       = "" //裝置暱稱
var MobileUID    = "" //行動裝置ID

class OTPDeviceEditViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate {


    @IBOutlet weak var tableView: UITableView!
    
    
    private var errorMessage = ""
    private var result:[String:Any]? = nil                          // 電文Response
    private var oneResult:[String:Any]? = nil                       // 電文Response
    private var curIndex:Int? = nil                                 // result["Result"] => Array, Array的Index
 
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(UINib(nibName: UIID.UIID_OtpDeviceToCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_OtpDeviceToCell.NibName()!)
        getTransactionID("13001", TransactionID_Description)
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
                //收到TransactionID後 判斷COMM0812送查詢
                let WkCd = response.object(forKey: "WorkCode") as? String
                if WkCd == "13001" {
                postRequest("COMM/COMM0812", "COMM0812", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"13001","Operate":"dataList","TransactionId":transactionId], true), AuthorizationManage.manage.getHttpHead(true))
                }else {
                    if WkCd == "13003"{
                        self.postRequest("COMM/COMM0813", "COMM0813", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"13003","Operate":"delMOTP","TransactionId":transactionId,"MobileUID":MobileUID], true), AuthorizationManage.manage.getHttpHead(true))
                    }
                       
                }
            }
            else {
                super.didResponse(description, response)
            }
            
       //get OTP裝置
        case "COMM0812":
             let data = response.object(forKey: ReturnData_Key) as? [String:Any]
           result = data
            // let array = result?["Result"] as? [[String:String]]
             
            tableView.reloadData()
        //delet OTP裝置
        case "COMM0813":
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {
                if let message = response.object(forKey: ReturnMessage_Key) as? String {
                    errorMessage = message
                }
            }else{
                enterFeatureByID(.FeatureID_MOTPEdit ,false)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_OtpDeviceToCell.NibName()!, for: indexPath) as! OtpDeviceToCell
        if let array = result?["Result"] as? [[String:String]] {
            MobileUID = array[indexPath.row]["MobileUID"]!
                if let MobileType = array[indexPath.row]["MobileType"]  {
                    cell.labelMobileType.text = MobileType.trimmingCharacters(in: .whitespaces)
                }
                if let DeviceRemark = array[indexPath.row]["Remark"]  {
                    cell.labelDeviceRemark.text = DeviceRemark.trimmingCharacters(in: .whitespaces)
                }
                if let CreateDate = array[indexPath.row]["CreateDate"] {
                    cell.labelCreateDate.text = CreateDate.trimmingCharacters(in: .whitespaces)
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
                MobileType    = (array[sender.tag]["MobileType"]! as NSString) as String
                CreateDate   = (array[sender.tag]["CreateDate"]! as NSString) as String
                Remark       = (array[sender.tag]["Remark"]! as NSString) as String
            }
            //show del msg
            let confirmHandler : ()->Void = {
          self.setLoading(true)
                self.getTransactionID("13003", TransactionID_Description)
                
            }
            let cancelHandler : ()->Void = {()}
            showAlert(title: "注意", msg: "請確認要註銷OTP服務裝置?\n" + Remark , confirmTitle: "確認送出", cancleTitle: "取消", completionHandler: confirmHandler, cancelHandelr: cancelHandler)
        }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == OTPDeviceEdit_Segue {
            let controller = segue.destination as! OTPDeviceInfoEditViewController
            var list = [[String:String]]()
            list.append([Response_Key: "手機別", Response_Value:MobileType])
            list.append([Response_Key: "申請日", Response_Value:CreateDate])
            list.append([Response_Key: "裝置暱稱", Response_Value:Remark])
            list.append([Response_Key: "行動裝置ID", Response_Value:MobileUID])
           
            controller.setList(list)
        }
    }
    
        func  btnEditAction(_ sender: UIButton) {
           
            if  let array = result?["Result"] as? [[String:String]]{
                
                MobileType = (array[sender.tag]["MobileType"]! as NSString) as String
                CreateDate = (array[sender.tag]["CreateDate"]! as NSString) as String
                Remark = (array[sender.tag]["Remark"]! as NSString) as String
                performSegue(withIdentifier: OTPDeviceEdit_Segue, sender: self)
                
            }
        }

}


