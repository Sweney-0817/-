//
//  GPAccountInfomationViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/7/31.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit
let AccountInfomation_CellTitle = ["帳號","幣別","總公克數"]

class GPAccountInfomationViewController: BaseViewController {

    @IBOutlet var m_tvAccountInfomation: UITableView!
    var m_aryAccountInfomation: [[String:String]] = [[String:String]]()
    var curExpandCell:IndexPath? = nil          // 目前展開的cell
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initTableView()
//        self.send_getActList()
        self.send_test()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK:- Init Methods
    private func initTableView() {
        m_tvAccountInfomation.delegate = self
        m_tvAccountInfomation.dataSource = self
        m_tvAccountInfomation.register(UINib(nibName: UIID.UIID_OverviewCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_OverviewCell.NibName()!)
        m_tvAccountInfomation.allowsSelection = false
        m_tvAccountInfomation.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
    // MARK:- UI Methods
    
    // MARK:- Logic Methods
    
    // MARK:- WebService Methods
    private func makeFakeData() {
        m_aryAccountInfomation.removeAll()
        var temp : [String:String] = [String:String]()
        for i in 0..<20 {
            temp["Act"] = String.init(format: "%05d", i)
            temp["Currency"] = "TWD"
            temp["Amount"] = String.init(format: "%dg", i*100+10)
            m_aryAccountInfomation.append(temp)
        }
    }
    //for test
    func send_test() {
        postRequest("QR/QR0101", "QR0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"09001","Operate":"getTerms","TransactionId":"2017070600000001","LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
    }
    func send_getActList() {
        self.makeFakeData()
//        postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
    }
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                setLoading(true)
                self.send_getActList()
            }
            else {
                super.didResponse(description, response)
            }
        case "checkQRCode":
            performSegue(withIdentifier: "GoScanResult", sender: nil)
        case "checkPayTaxCode":
            performSegue(withIdentifier: "GoScanResult", sender: nil)
        case "QR0101":
            NSLog("%@", response)
        default: super.didResponse(description, response)
        }
    }
    // MARK:- Handle Actions

}
extension GPAccountInfomationViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_aryAccountInfomation.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_OverviewCell.NibName()!, for: indexPath) as! OverviewCell
        cell.title1Label.text = AccountInfomation_CellTitle[0]
        cell.title2Label.text = AccountInfomation_CellTitle[1]
        cell.title3Label.text = AccountInfomation_CellTitle[2]
        
        cell.detail1Label.text = m_aryAccountInfomation[indexPath.row]["Act"] ?? ""
        cell.detail2Label.text = m_aryAccountInfomation[indexPath.row]["Currency"] ?? ""
        cell.detail3Label.text = m_aryAccountInfomation[indexPath.row]["Amount"] ?? ""

        cell.AddExpnadBtn(self, indexPath)
        if curExpandCell == indexPath {
            cell.showExpandView()
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
extension GPAccountInfomationViewController : OverviewCellDelegate
{
    // MARK: - OverviewCellDelegate
    func clickExpandBtn1(_ btn:UIButton, _ value:[String:String]) {
        enterFeatureByID(.FeatureID_GPRegularAccountInfomation, true)
    }
    
    func clickExpandBtn2(_ btn:UIButton, _ value:[String:String]) {
        enterFeatureByID(.FeatureID_GPTransactionDetail, true)
    }
    
    func endExpanding(_ curRow:IndexPath?) {
        if curRow != curExpandCell {
            let oldCell = curExpandCell
            curExpandCell = curRow
            var temp = [IndexPath]()
            if oldCell != nil {
                temp.append(oldCell!)
            }
            if curExpandCell != nil {
                temp.append(curExpandCell!)
            }
            m_tvAccountInfomation.reloadRows(at: temp, with: .none)
        }
    }
}
