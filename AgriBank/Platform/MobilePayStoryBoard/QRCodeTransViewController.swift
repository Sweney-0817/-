//
//  QRCodeTransViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/6/26.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit

class QRCodeTransViewController: BaseViewController {
    @IBOutlet var m_vButtonView: UIView!
    @IBOutlet var m_btnReceipt: UIButton!
    @IBOutlet var m_btnPayment: UIButton!

    @IBOutlet var m_vReceiptView: UIView!
    @IBOutlet var m_vTopView: UIView!
    @IBOutlet var m_vActView: UIView!
    @IBOutlet var m_tfAmount: TextField!
    @IBOutlet var m_lbCommand: UILabel!
    @IBOutlet var m_vQRCodeArea: UIView!
    @IBOutlet var m_ivQRCode: UIImageView!
    
    @IBOutlet var m_vPaymentView: UIView!
    
    var m_uiActView:OneRowDropDownView? = nil
    var m_scanView : ScanCodeView? = nil

    var m_arrActList : [[String:String]] = [[String:String]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initActView()
//        self.addObserverToKeyBoard()
        self.addGestureForKeyBoard()
        self.getTransactionID("03001", TransactionID_Description)
    }
    func startScan() {
        m_scanView = Bundle.main.loadNibNamed("ScanCodeView", owner: self, options: nil)?.first as? ScanCodeView
        m_scanView!.set(CGRect(origin: .zero, size: m_vPaymentView.bounds.size), getQRCodeString)
        m_vPaymentView.addSubview(m_scanView!)
        self.m_scanView!.startScan()
    }
    func stopScan() {
        self.m_scanView!.stopScan()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.startScan()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK:- Init Methods
    func initActView() {
        m_uiActView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        m_uiActView?.delegate = self
        m_uiActView?.frame = m_vActView.frame
        m_uiActView?.frame.origin = .zero
        m_uiActView?.setOneRow("*帳戶", Choose_Title)
        m_uiActView?.m_lbFirstRowTitle.textAlignment = .center
        m_vActView.addSubview(m_uiActView!)

        setShadowView(m_vTopView, .Bottom)
        setShadowView(m_vButtonView, .Bottom)
    }
    // MARK:- UI Methods
    private func changeFunction(_ isReceipt:Bool) {
//        self.isPredesignated = isPredesignated
        if isReceipt {
            m_btnReceipt.backgroundColor = Green_Color
            m_btnReceipt.setTitleColor(.white, for: .normal)
            m_btnPayment.backgroundColor = .white
            m_btnPayment.setTitleColor(.black, for: .normal)
            m_vReceiptView.isHidden = false
            m_vPaymentView.isHidden = true
            self.stopScan()
        }
        else {
            m_btnPayment.backgroundColor = Green_Color
            m_btnPayment.setTitleColor(.white, for: .normal)
            m_btnReceipt.backgroundColor = .white
            m_btnReceipt.setTitleColor(.black, for: .normal)
            m_vReceiptView.isHidden = true
            m_vPaymentView.isHidden = false
            self.startScan()
        }
    }
    func showActList() {
        if (m_arrActList.count > 0) {
            let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
            for info in m_arrActList {
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
    func getQRCodeString(_ : String) {
        
    }
    // MARK:- WebService Methods
    private func makeFakeData() {
        m_arrActList.removeAll()
        var temp : [String:String] = [String:String]()
        for i in 0..<20 {
            temp["Act"] = String.init(format: "%05d", i)
            temp["Amount"] = String.init(format: "%d", i*1000+100)
            m_arrActList.append(temp)
        }
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
            //        case "ACCT0101":
            //            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]]{
            //                for category in array {
            //                    if let type = category["ACTTYPE"] as? String, let result = category["AccountInfo"] as? [[String:Any]], type == Account_Saving_Type {
            //                        accountList = [AccountStruct]()
            //                        for actInfo in result {
            //                            if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? String, let ebkfg = actInfo["EBKFG"] as? String, ebkfg == Account_EnableTrans {
            //                                accountList?.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
            //                            }
            //                        }
            //                    }
            //                }
            //
            //                if inputAccount != nil {
            //                    for index in 0..<(accountList?.count)! {
            //                        if let info = accountList?[index], info.accountNO == inputAccount! {
            //                            accountIndex = index
            //                            topDropView?.setThreeRow(NTTransfer_OutAccount, info.accountNO, NTTransfer_Currency, (info.currency == Currency_TWD ? Currency_TWD_Title:info.currency), NTTransfer_Balance, String(info.balance).separatorThousand())
            //                            break
            //                        }
            //                    }
            //                    inputAccount = nil
            //                }
            //            }
            //            else {
            //                super.didResponse(description, response)
            //            }
            //
            //        case "COMM0401":
            //            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:String]] {
            //                bankNameList = array
            //                showBankList()
            //            }
            //            else {
            //                super.didResponse(description, response)
            //            }
            //
            //        case "ACCT0102":
            //            if let data = response.object(forKey: ReturnData_Key) as? [String:Any] {
            //                if let array = data["Result"] as? [[String:Any]] {
            //                    agreedAccountList = array
            //                }
            //                showInAccountList(isPredesignated)
            //            }
            //            else {
            //                super.didResponse(description, response)
            //            }
            //
            //        case "ACCT0104":
            //            if let data = response.object(forKey: ReturnData_Key) as? [String:Any] {
            //                if let array = data["Result2"] as? [[String:Any]] {
            //                    commonAccountList = array
            //                }
            //                showInAccountList(isPredesignated)
            //            }
            //            else {
            //                super.didResponse(description, response)
            //            }
            //
            //        case "COMM0802":
            //            showNonPredesignated()
            //
            //        case "TRAN0103":
            //            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let Id = data["taskId"] as? String {
            //                VaktenManager.sharedInstance().getTasksOperation{ resultCode, tasks  in
            //                    if VIsSuccessful(resultCode) && tasks != nil {
            //                        self.transNonPredesignated(tasks! as! [VTask], Id)
            //                    }
            //                    else {
            //                        self.showErrorMessage(nil, "\(ErrorMsg_GetTasks_Faild) \(resultCode.rawValue)")
            //                    }
            //                }
            //            }
            //            else {
            //                showErrorMessage(nil, ErrorMsg_No_TaskId)
            //            }
            
        default: super.didResponse(description, response)
        }
    }
    // MARK:- Handle Actions
    @IBAction func m_btnReceiptClick(_ sender: Any) {
        self.dismissKeyboard()
        self.changeFunction(true)
    }
    @IBAction func m_btnPaymentClick(_ sender: Any) {
        self.dismissKeyboard()
        self.changeFunction(false)
    }
    @IBAction func m_btnMakeQRCodeClick(_ sender: Any) {
        self.dismissKeyboard()
        let strAct : String = (m_uiActView?.getContentByType(.First))!
        let strAmount : String = m_tfAmount.text!
        let strQRCode : String = "[\(strAct)][\(strAmount)]"
        self.m_ivQRCode.image = MakeQRCodeUtility.utility.generateQRCode(from: strQRCode)
    }
}

extension QRCodeTransViewController : OneRowDropDownViewDelegate {
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        self.dismissKeyboard()
        if (m_arrActList.count == 0) {
            self.send_getActList()
        }
        else {
            self.showActList()
        }
    }
}
extension QRCodeTransViewController : UIActionSheetDelegate {
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet.cancelButtonIndex != buttonIndex {
            switch (actionSheet.tag) {
            case ViewTag.View_AccountActionSheet.rawValue:
                let iIndex : Int = buttonIndex - 1
                let info : [String:String] = m_arrActList[iIndex]
                let act : String = info["Act"]!
//                let amount : String = info["Amount"]!
                m_uiActView?.setOneRow("*帳戶", act)
//                self.checkBtnConfirm()
            default:
                break
            }
        }
    }
}
