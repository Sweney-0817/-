//
//  GPRiskEvaluationViewController.swift
//  AgriBank
//
//  Created by ABOT on 2022/9/22.
//  Copyright © 2022 Systex. All rights reserved.
//

import UIKit
import Foundation

class GPRiskEvaluationViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate   {
    
    
    @IBOutlet weak var tableView: UITableView!
    private var result:[String:Any]? = nil                          // 電文Response
    var RiskAry = [[String]]()
    
    
 
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set tableinfo
        SetAry()
        
        
        
        // Do any additional setup after loading the view.
//        tableView.register(UINib(nibName: UIID.UIID_GPRiskCheckCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_GPRiskCheckCell.NibName()!)
//        tableView.register(UINib(nibName: UIID.UIID_GPRiskMulitCheckCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_GPRiskMulitCheckCell.NibName()!)
        // navigationController?.delegate = self
        tableView.allowsSelection = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
         
        getTransactionID("10015", TransactionID_Description)
        
        
    }
 
    
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                tempTransactionId = tranId
                setLoading(true)
                self.postRequest("Gold/Gold0702", "Gold0702", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10015","Operate":"getTerms","TransactionId":tempTransactionId,"uid": AgriBank_DeviceID,"MotpDeviceID": MOTPPushAPI.getDeviceID() ?? ""], true), AuthorizationManage.manage.getHttpHead(true))
                
            }
            else {
                super.didResponse(description, response)
            }
        case "Gold0701":
           
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]] {
                for Result in array {
                    if let Value = Result[Response_Value] as? String ,let KEY = Result[Response_Key] as? String  {
                        if KEY == "投資風險屬性等級" {
                            let alert = UIAlertView(title: "投資風險屬性等級", message:Value,  delegate: nil, cancelButtonTitle:Determine_Title)
                            alert.show()
                        }
                    }
                }
            }
            else {
                super.didResponse(description, response)
            }
        case "Gold0702":
            if let data = response.object(forKey: ReturnData_Key) as? [String:String] {
                if (data["Read"] == "Y") {
                   // requestAcnt()
                }
                else {
                    let controller = getControllerByID(.FeatureID_GPRiskRules)
                    (controller as! GPRiskRulesViewController).m_dicAcceptData = data
                    (controller as! GPRiskRulesViewController).m_nextFeatureID = .FeatureID_GPRiskRules
                    (controller as! GPRiskRulesViewController).transactionId = tempTransactionId
                    navigationController?.pushViewController(controller, animated: true)
                }
            }
        default: super.didResponse(description, response)
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let ItemKind = RiskAry[indexPath.row][4]
        //單選
        if (ItemKind == "O"){
            return 330
        }
        else{
            return 450  } 
    }
 
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return RiskAry.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let ItemKind = RiskAry[indexPath.row][4]
        
     
       
        //單選
        if (ItemKind == "O"){
            tableView.register(UINib(nibName: UIID.UIID_GPRiskCheckCell.NibName()!  , bundle: nil), forCellReuseIdentifier: UIID.UIID_GPRiskCheckCell.NibName()! + String(indexPath.row))
           
            let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_GPRiskCheckCell.NibName()! + String(indexPath.row), for: indexPath) as!  GPRiskChekCell
            
            let title = RiskAry[indexPath.row][2] + RiskAry[indexPath.row][3]
            (cell as! GPRiskChekCell).TitleLabel.text = title
            
            if RiskAry[indexPath.row][5] != "" {
                let R1 = RiskAry[indexPath.row][5].components(separatedBy: ",")
               (cell as! GPRiskChekCell).Radio1.titleText = R1[0]
                (cell as! GPRiskChekCell).Radio1.accessibilityLabel = R1[0]
                (cell as! GPRiskChekCell).Radio1.tag = (indexPath.row * 100) + 5//(Int(R1[1]) ?? 0)
                (cell as! GPRiskChekCell).Radio1.isHidden = false
                (cell as! GPRiskChekCell).Radio1.addTarget(self, action: #selector(self.RadioSelect(_:)), for: .touchUpInside)
            }else{
                (cell as! GPRiskChekCell).Radio1.titleText = ""
               // (cell as! GPRiskChekCell).Radio1.tag = 0
                (cell as! GPRiskChekCell).Radio1.isHidden = true
            }
            if RiskAry[indexPath.row][6] != "" {
                let R2 = RiskAry[indexPath.row][6].components(separatedBy: ",")
                (cell as! GPRiskChekCell).Radio2.titleText = R2[0]
                (cell as! GPRiskChekCell).Radio2.accessibilityLabel = R2[0]
                (cell as! GPRiskChekCell).Radio2.tag = (indexPath.row * 100) + 6//(Int(R2[1]) ?? 0)
                (cell as! GPRiskChekCell).Radio2.isHidden = false
                (cell as! GPRiskChekCell).Radio2.addTarget(self, action: #selector(self.RadioSelect(_:)), for: .touchUpInside)
            }else{
                (cell as! GPRiskChekCell).Radio2.titleText = ""
               // (cell as! GPRiskChekCell).Radio2.tag =  0
                (cell as! GPRiskChekCell).Radio2.isHidden = true
            }
            if RiskAry[indexPath.row][7] != "" {
                let R3 = RiskAry[indexPath.row][7].components(separatedBy: ",")
                (cell as! GPRiskChekCell).Radio3.titleText = R3[0]
                (cell as! GPRiskChekCell).Radio3.accessibilityLabel = R3[0]
                (cell as! GPRiskChekCell).Radio3.tag = (indexPath.row * 100) + 7//(Int(R3[1]) ?? 0)
                (cell as! GPRiskChekCell).Radio3.isHidden = false
                (cell as! GPRiskChekCell).Radio3.addTarget(self, action: #selector(self.RadioSelect(_:)), for: .touchUpInside)
            }else{
                (cell as! GPRiskChekCell).Radio3.titleText = ""
                //(cell as! GPRiskChekCell).Radio3.tag =  0
                (cell as! GPRiskChekCell).Radio3.isHidden = true
            }
            if RiskAry[indexPath.row][8] != "" {
                let R4 = RiskAry[indexPath.row][8].components(separatedBy: ",")
                (cell as! GPRiskChekCell).Radio4.titleText = R4[0]
                (cell as! GPRiskChekCell).Radio4.accessibilityLabel = R4[0]
                (cell as! GPRiskChekCell).Radio4.tag = (indexPath.row * 100) + 8//(Int(R4[1]) ?? 0)
                (cell as! GPRiskChekCell).Radio4.isHidden = false
                (cell as! GPRiskChekCell).Radio4.addTarget(self, action: #selector(self.RadioSelect(_:)), for: .touchUpInside)
            }else{
                (cell as! GPRiskChekCell).Radio4.titleText = ""
                //(cell as! GPRiskChekCell).Radio4.tag =   0
                (cell as! GPRiskChekCell).Radio4.isHidden = true
            }
            if RiskAry[indexPath.row][9] != "" {
                let R5 = RiskAry[indexPath.row][9].components(separatedBy: ",")
                (cell as! GPRiskChekCell).Radio5.titleText = R5[0]
                (cell as! GPRiskChekCell).Radio5.accessibilityLabel = R5[0]
                (cell as! GPRiskChekCell).Radio5.tag = (indexPath.row * 100) + 9//(Int(R5[1]) ?? 0)
                (cell as! GPRiskChekCell).Radio5.isHidden = false
                (cell as! GPRiskChekCell).Radio5.addTarget(self, action: #selector(self.RadioSelect(_:)), for: .touchUpInside)
            }else{
                (cell as! GPRiskChekCell).Radio5.titleText = ""
               // (cell as! GPRiskChekCell).Radio5.tag =  0
                (cell as! GPRiskChekCell).Radio5.isHidden = true
            }
            cell.reloadInputViews()
            return cell
        }
         else{
             
             
             tableView.register(UINib(nibName: UIID.UIID_GPRiskMulitCheckCell.NibName()!  , bundle: nil), forCellReuseIdentifier: UIID.UIID_GPRiskMulitCheckCell.NibName()! + String(indexPath.row))
             
             let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_GPRiskMulitCheckCell.NibName()! + String(indexPath.row) , for: indexPath) as! GPRiskMulitChekCell
             
             let title = RiskAry[indexPath.row][2] + RiskAry[indexPath.row][3]
             
             (cell as! GPRiskMulitChekCell).Titlelable.text =  title
             if RiskAry[indexPath.row][5] != "" {
                 let R6 = RiskAry[indexPath.row][5].components(separatedBy: ",")
                 (cell as! GPRiskMulitChekCell).checkbox1.titleText = R6[0]
                 (cell as! GPRiskMulitChekCell).checkbox1.accessibilityLabel = R6[0]
                 (cell as! GPRiskMulitChekCell).checkbox1.tag = (indexPath.row * 100) + 5//(Int(R1[1]) ?? 0)
                 (cell as! GPRiskMulitChekCell).checkbox1.isHidden = false
                 (cell as! GPRiskMulitChekCell).checkbox1.addTarget(self, action: #selector(self.checkboxCheck(_:)), for: .touchUpInside)
             }else{
                 (cell as! GPRiskMulitChekCell).checkbox1.titleText = ""
                 (cell as! GPRiskMulitChekCell).checkbox1.isHidden = true
             }
             if RiskAry[indexPath.row][6] != "" {
                 let R7 = RiskAry[indexPath.row][6].components(separatedBy: ",")
                 (cell as! GPRiskMulitChekCell).checkbox2.titleText = R7[0]
                 (cell as! GPRiskMulitChekCell).checkbox2.accessibilityLabel = R7[0]
                 (cell as! GPRiskMulitChekCell).checkbox2.tag = (indexPath.row * 100) + 6//(Int(R2[1]) ?? 0)
                 (cell as! GPRiskMulitChekCell).checkbox2.isHidden = false
                 (cell as! GPRiskMulitChekCell).checkbox2.addTarget(self, action: #selector(self.checkboxCheck(_:)), for: .touchUpInside)
             }else{
                 (cell as! GPRiskMulitChekCell).checkbox2.titleText = ""
                 (cell as! GPRiskMulitChekCell).checkbox2.isHidden = true
             }
             if RiskAry[indexPath.row][7] != "" {
                 let R8 = RiskAry[indexPath.row][7].components(separatedBy: ",")
                 (cell as! GPRiskMulitChekCell).checkbox3.titleText = R8[0]
                 (cell as! GPRiskMulitChekCell).checkbox3.accessibilityLabel = R8[0]
                 (cell as! GPRiskMulitChekCell).checkbox3.tag =  (indexPath.row * 100) + 7//(Int(R3[1]) ?? 0)
                 (cell as! GPRiskMulitChekCell).checkbox3.isHidden = false
                 (cell as! GPRiskMulitChekCell).checkbox3.addTarget(self, action: #selector(self.checkboxCheck(_:)), for: .touchUpInside)
             }else{
                 (cell as! GPRiskMulitChekCell).checkbox3.titleText = ""
                 (cell as! GPRiskMulitChekCell).checkbox3.isHidden = true
             }
             if RiskAry[indexPath.row][8] != "" {
                 let R9 = RiskAry[indexPath.row][8].components(separatedBy: ",")
                 (cell as! GPRiskMulitChekCell).checkbox4.titleText = R9[0]
                 (cell as! GPRiskMulitChekCell).checkbox4.accessibilityLabel = R9[0]
                 (cell as! GPRiskMulitChekCell).checkbox4.tag =  (indexPath.row * 100) + 8//(Int(R4[1]) ?? 0)
                 (cell as! GPRiskMulitChekCell).checkbox4.isHidden = false
                 (cell as! GPRiskMulitChekCell).checkbox4.addTarget(self, action: #selector(self.checkboxCheck(_:)), for: .touchUpInside)
             }else{
                 (cell as! GPRiskMulitChekCell).checkbox4.titleText = ""
                 (cell as! GPRiskMulitChekCell).checkbox4.isHidden = true
             }
             if RiskAry[indexPath.row][9] != "" {
                 let R10 = RiskAry[indexPath.row][9].components(separatedBy: ",")
                 (cell as! GPRiskMulitChekCell).checkbox5.titleText = R10[0]
                 (cell as! GPRiskMulitChekCell).checkbox5.accessibilityLabel = R10[0]
                 (cell as! GPRiskMulitChekCell).checkbox5.tag =  (indexPath.row * 100) + 9//(Int(R5[1]) ?? 0)
                 (cell as! GPRiskMulitChekCell).checkbox5.isHidden = false
                 (cell as! GPRiskMulitChekCell).checkbox5.addTarget(self, action: #selector(self.checkboxCheck(_:)), for: .touchUpInside)
             }else{
                 (cell as! GPRiskMulitChekCell).checkbox5.titleText = ""
                 (cell as! GPRiskMulitChekCell).checkbox5.isHidden = true
             }
             if RiskAry[indexPath.row][10] != "" {
                 let R11 = RiskAry[indexPath.row][10].components(separatedBy: ",")
                 (cell as! GPRiskMulitChekCell).checkbox6.titleText = R11[0]
                 (cell as! GPRiskMulitChekCell).checkbox6.accessibilityLabel = R11[0]
                 (cell as! GPRiskMulitChekCell).checkbox6.tag =  (indexPath.row * 100) + 10//(Int(R6[1]) ?? 0)
                 (cell as! GPRiskMulitChekCell).checkbox6.isHidden = false
                 (cell as! GPRiskMulitChekCell).checkbox6.addTarget(self, action: #selector(self.checkboxCheck(_:)), for: .touchUpInside)
             }else{
                 (cell as! GPRiskMulitChekCell).checkbox6.titleText = ""
                 (cell as! GPRiskMulitChekCell).checkbox6.isHidden = true
             }
             if RiskAry[indexPath.row][11] != "" {
                 let R12 = RiskAry[indexPath.row][11].components(separatedBy: ",")
                 (cell as! GPRiskMulitChekCell).checkbox7.titleText = R12[0]
                 (cell as! GPRiskMulitChekCell).checkbox7.accessibilityLabel = R12[0]
                 (cell as! GPRiskMulitChekCell).checkbox7.tag =  (indexPath.row * 100) + 11//(Int(R7[1]) ?? 0)
                 (cell as! GPRiskMulitChekCell).checkbox7.isHidden = false
                 (cell as! GPRiskMulitChekCell).checkbox7.addTarget(self, action: #selector(self.checkboxCheck(_:)), for: .touchUpInside)
             }else{
                 (cell as! GPRiskMulitChekCell).checkbox7.titleText = ""
                 (cell as! GPRiskMulitChekCell).checkbox7.isHidden = true
             }
             if RiskAry[indexPath.row][12] != "" {
                 let R13 = RiskAry[indexPath.row][12].components(separatedBy: ",")
                 (cell as! GPRiskMulitChekCell).checkbox8.titleText = R13[0]
                 (cell as! GPRiskMulitChekCell).checkbox8.accessibilityLabel = R13[0]
                 (cell as! GPRiskMulitChekCell).checkbox8.tag =  (indexPath.row * 100) + 12//(Int(R8[1]) ?? 0)
                 (cell as! GPRiskMulitChekCell).checkbox8.isHidden = false
                 (cell as! GPRiskMulitChekCell).checkbox8.addTarget(self, action: #selector(self.checkboxCheck(_:)), for: .touchUpInside)
                
             }else{
                 (cell as! GPRiskMulitChekCell).checkbox8.titleText = ""
                 (cell as! GPRiskMulitChekCell).checkbox8.isHidden = true
             }
             
             if (indexPath.row % 5) == 0 {
                 self.tableView.reloadData()
             }
           
          return cell
           
        }
       // return cell
    }
    
    
    
    func SetAry(){
        //0:電文Name 1:得分 2:題號 3:題目 4:O單選Ｘ複選 5:答案1 6:答案2 7:答案3 8:答案4 9:答案5 10:答案6 11:答案7 12:答案8
        RiskAry.append(["Question1_1","0","Q1_1",".請問您的年齡：","O","20歲以下/70歲以上,1","21~35歲,5","36~50歲,4","51~60歲,3","61~70歲,2","","",""])
        
        RiskAry.append(["Question1_2","0","Q1_2",".請問您的教育程度：","O","國小(含)以下,1","國中,2","高中職,3","大學/專科,4","碩士以上,5","","",""])
       
        RiskAry.append(["Question1_3","0","Q1_3",".請問您的職業：","O","待業中/學生,1","家管/退休人員,2","自由業,3","非金融/保險/律師/會計師之其他職業,4","金融/保險/律師/會計師,5","","",""])
        RiskAry.append(["Question1_4","0","Q1_4",".個人年收入：","O","0~50萬元以下,1","50萬元~100萬元,2","100萬元~300萬元,3","300萬元~800萬元,4","800萬元以上,5","","",""])
      
        RiskAry.append(["Question1_5","0","Q1_5",":.家庭年收入：","O","0~50萬元以下,1","50萬元~200萬元,2","200萬元~500萬元,3","500萬元~1000萬元,4","1000萬元以上,5","","",""])
        RiskAry.append(["Question2_1","0","Q2_1",".對於理財，您的主要資訊來源是(複選，不限本次申請項目)","X","親友建議或其他,1","電視/廣播/網路等被動訊息,2","金融機構/理財人員,3","專業財金網站,4","財金雜誌,5","","","","0,0,0,0,0"])
        RiskAry.append(["Question2_2","0","Q2_2",".請問您進行投資是為了什麼目的呢(複選，不限本次申請項目)?","X","支應目前/未來退休生活,1","置產/節稅,2","短期投資計畫,3","避險/資產配置,3","財富累積,4","追求投資利益,5","","","0,0,0,0,0,0"])
        RiskAry.append(["Question2_3","0","Q2_3",".請問您進行金融投資的經驗有多久(單選，本項係指存款以外之金融商品)?","O","完全沒有經驗,1","未滿3年,2","3年以上~未滿7年,3","7年以上~未滿10年,4","10年以上,5","","",""])
        RiskAry.append(["Question2_4","0","Q2_4",".請問您投資過，而且仍不排斥接觸的金融商品(複選)?","X","都沒有/只有存款,1","外匯商品,1","貨幣型基金、儲蓄型保險,2","債券、債券型基金,2","黃金存摺,3","股票、股票型基金、ETF、投資型保單,4","結構型商品,4","衍生性金融商品,5","0,0,0,0,0,0,0,0"])
       
        RiskAry.append(["Question2_5","0","Q2_5",".請問您目前主要將資產配置於何處(複選)","X","台外幣存款,1","事業投資,2","基金及保險,3","動產(珠寶、骨董、汽車…等非金融資產),4","不動產,5","","","","0,0,0,0,0"])
       
        RiskAry.append(["Question3_1","0","Q3_1",".一般情況下，您願意承受最大本金損失為?","O","下跌0%,1","下跌5%以內,2","下跌10%以內,3","下跌15%以內,4","下跌超過15%,5","","",""])
         
        RiskAry.append(["Question3_2","0","Q3_2",".若您整體投資資產下跌超過15%，對您的生活影響程度為何(單選)：","O","無法承受,1","影響程度大,2","中度影響,3","影響程度小,4","不會有影響,5","","",""])
        
        RiskAry.append(["Question3_3","0","Q3_3",".若您有一筆資金想投資，假設不考慮投資標的物內容，單由報酬率區間來看，您會選擇哪一種投資組合(單選)?","O","-3%~+3%,1","-10%~+10%,2","-15%~+15%,3","-25%~+%25,4","-40%~+40%,5","","",""])
        
        RiskAry.append(["Question3_4","0","Q3_4",".對於非存款類的財務投資，您最長可接受的投資時間為多久?","O","未滿一年,1","1年以上~未滿3年,2","3年以上~未滿5年,3","5年以上~未滿7年,4","7年以上,5","","",""])
      
        RiskAry.append(["Question3_5","0","Q3_5",".如有非預期且臨時的事件發生時，手上所持現金或可立即變現之有價證券可以支應多久的生活開銷?","O","3個月以下,1","3~6個月,3","6個月以上,5","","","","",""])
        
    }
    
   
    @IBAction func SendToServer(_ sender: Any) {
        var MsgStr = ""
        var PostAr  =
        ["WorkCode":"10016","Operate":"commitTxn","TransactionId":self.tempTransactionId ]
        for RiskAr in self.RiskAry {
            if RiskAr[1] == "0" {
                MsgStr  = MsgStr +  RiskAr[2] + " "
            }
            PostAr[RiskAr[0]] = RiskAr[1]
        }
        //print ( PostAr)
        if MsgStr == "" {
            showAlert(title: UIAlert_Default_Title, msg: "確定要送出評估？", confirmTitle: Determine_Title, cancleTitle: Cancel_Title, completionHandler: {
                // print(PostAr)
                self.setLoading(true)
                self.postRequest("Gold/Gold0701", "Gold0701", AuthorizationManage.manage.converInputToHttpBody( PostAr, true), AuthorizationManage.manage.getHttpHead(true))
            }, cancelHandelr: {()})
            
        }else{
            let alert = UIAlertView(title: UIAlert_Default_Title, message:MsgStr + "未填寫", delegate: nil, cancelButtonTitle:Determine_Title)
            alert.show()
        }
    }
    func  RadioSelect (_ sender: SKRadioButton)  {
        let wkIndex = sender.tag / 100
        let wkRow = sender.tag % 100
        let wkItem = RiskAry[wkIndex][wkRow].components(separatedBy: ",")
        let wkScorce:String = wkItem[1]
        RiskAry[wkIndex][1] = wkScorce
        // print(String(RiskAry[wkIndex][2]) + "_" + String(RiskAry[wkIndex][wkRow]) + "=" + wkScorce )
    
}
    func  checkboxCheck (_ sender: SKRadioButton)  {
        let wkIndex = sender.tag / 100
        let wkRow = sender.tag % 100
      
        var arScroce:[String] = RiskAry[wkIndex][13].components(separatedBy: ",")
        if sender.isSelected == true {
            arScroce[wkRow - 5 ] = "1"
        }else{
            arScroce[wkRow - 5 ] = "0"
        }
        var wkScorce = 0
        var wkArString:String = ""
        for i  in 0...(arScroce.count - 1){
            wkArString = wkArString + arScroce[i]
            if  arScroce[i]  == "1" {
                 let wkItem = RiskAry[wkIndex][i + 5].components(separatedBy: ",")
                 let iScorce = wkItem[1]
                if Int(iScorce)! > wkScorce {
                    wkScorce = Int(iScorce)!
                }
            }
            if i != arScroce.count - 1 {
                wkArString = wkArString + ","
            }
        }
        RiskAry[wkIndex][13] = wkArString
        RiskAry[wkIndex][1] = String(wkScorce)
       // print(RiskAry[wkIndex][2] + "_" + RiskAry[wkIndex][13] + "=" + RiskAry[wkIndex][1])
}
}
