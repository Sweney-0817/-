//
//  GPSingleBuyViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/7/31.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit

class GPSingleBuyViewController: BaseViewController {
    var m_uiActView: OneRowDropDownView? = nil
    var m_strBuyGram: String = "0"
    var m_strCurrency: String = "台幣"
    var m_strOutAct: String = "1234567890"
    var m_aryActList : [[String:String]] = [[String:String]]()
    @IBOutlet var m_vActView: UIView!
    @IBOutlet var m_tvContentView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initActView()
        self.initTableView()
        self.addGestureForKeyBoard()
        self.send_getActList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK:- Init Methods
    private func initActView() {
        m_uiActView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        m_uiActView?.delegate = self
        m_uiActView?.frame = m_vActView.frame
        m_uiActView?.frame.origin = .zero
        m_uiActView?.setOneRow(GPAccountTitle, Choose_Title)
        m_uiActView?.m_lbFirstRowTitle.textAlignment = .center
        m_vActView.addSubview(m_uiActView!)
        
        setShadowView(m_vActView)
    }
    private func initTableView() {
        m_tvContentView.delegate = self
        m_tvContentView.dataSource = self
        m_tvContentView.register(UINib(nibName: UIID.UIID_ResultCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultCell.NibName()!)
        m_tvContentView.register(UINib(nibName: UIID.UIID_ResultEditCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultEditCell.NibName()!)
        m_tvContentView.allowsSelection = false
        m_tvContentView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
    // MARK:- UI Methods
    func showActList() {
        if (m_aryActList.count > 0) {
            let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
            for info in m_aryActList {
                if let act = info["Act"] {
                    actSheet.addButton(withTitle: act)
                }
            }
            actSheet.tag = ViewTag.View_AccountActionSheet.rawValue
            actSheet.show(in: view)
        }
        else {
            showErrorMessage(nil, ErrorMsg_GetList_InCommonAccount)
        }
    }
    // MARK:- Logic Methods
    
    // MARK:- WebService Methods
    private func makeFakeData() {
        m_aryActList.removeAll()
        var temp : [String:String] = [String:String]()
        for i in 0..<20 {
            temp["Act"] = String.init(format: "%05d", i)
            temp["Amount"] = String.init(format: "%d", i*1000+100)
            m_aryActList.append(temp)
        }
    }
    func send_getActList() {
        self.makeFakeData()
//        postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
    }
    // MARK:- Handle Actions
    @IBAction func m_btnNextClick(_ sender: Any) {
        let strGoldPassbookAct: String = self.m_uiActView!.getContentByType(.First)
        let strCurrency: String = self.m_strCurrency
        let strOutAct: String = self.m_strOutAct
        let strBuyGram: String = self.m_strBuyGram
        NSLog("Next[%@][%@][%@][%@]", strGoldPassbookAct, strCurrency, strOutAct, strBuyGram)
    }

}
extension GPSingleBuyViewController : OneRowDropDownViewDelegate {
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        self.dismissKeyboard()
        if (m_aryActList.count == 0) {
            self.send_getActList()
        }
        else {
            self.showActList()
        }
    }
}
extension GPSingleBuyViewController : UIActionSheetDelegate {
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet.cancelButtonIndex != buttonIndex {
            switch (actionSheet.tag) {
            case ViewTag.View_AccountActionSheet.rawValue:
                let iIndex : Int = buttonIndex - 1
                let info : [String:String] = m_aryActList[iIndex]
                let act : String = info["Act"]!
                m_uiActView?.setOneRow(GPAccountTitle, act)
            default:
                break
            }
        }
    }
}
extension GPSingleBuyViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell
            cell.set("計價幣別", m_strCurrency)
            cell.selectionStyle = .none
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell
            cell.set("轉出帳號", m_strOutAct)
            cell.selectionStyle = .none
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultEditCell.NibName()!, for: indexPath) as! ResultEditCell
            cell.set("", placeholder: "請輸入申購數量(公克)")
            cell.m_tfEditData.delegate = self
            cell.selectionStyle = .none
            return cell
        default:
            return UITableViewCell()
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
extension GPSingleBuyViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        guard DetermineUtility.utility.isAllNumber(newString) else {
            return false
        }
        
        let newLength = (textField.text?.count)! - range.length + string.count
        let maxLength = Max_MobliePhone_Length
        if newLength <= maxLength {
            m_strBuyGram = newString
            return true
        }
        else {
            return false
        }
    }
}
