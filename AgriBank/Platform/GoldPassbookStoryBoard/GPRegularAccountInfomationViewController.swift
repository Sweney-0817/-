//
//  GPRegularAccountInfomationViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/8/14.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit
struct settingData {
    var m_strDate: String
    var m_strType: String
    var m_strAmount: String
    var m_strStop: String
    var m_strBtn: String
}
let sameAmount = "定期定額"
let sameQuantity = "定期定量"
let diffAmount = "定期不定額"
let amountTitle = "投資金額"
let basePrice = "基準價格"
let stopTitle = "暫停訖日"
let diffAmountCommand = "此投資方式請洽臨櫃辦理"
let btnTitleNew = "申請"
let btnTitleChange = "變更"
let btnTitleCheck = "檢視"
class GPRegularAccountInfomationViewController: BaseViewController {
    var m_uiActView: OneRowDropDownView? = nil
    var m_aryActList: [String] = [String]()
    var m_aryData: [settingData] = [settingData]()
    var m_uiDiffAmountDetail: GPDiffAmountDetailView? = nil
    
    @IBOutlet var m_vActView: UIView!
    @IBOutlet var m_svContent: UIScrollView!
    @IBOutlet var m_lbCurrency: UILabel!
    @IBOutlet var m_lbTransOutAct: UILabel!
    
    @IBOutlet var m_lbAmountTitle1: UILabel!
    @IBOutlet var m_lbStopTitle1: UILabel!
    @IBOutlet var m_lbType1: UILabel!
    @IBOutlet var m_lbAmount1: UILabel!
    @IBOutlet var m_lbStop1: UILabel!
    @IBOutlet var m_consStopHeight1: NSLayoutConstraint!
    @IBOutlet var m_btn1: UIButton!
    
    @IBOutlet var m_lbAmountTitle2: UILabel!
    @IBOutlet var m_lbStopTitle2: UILabel!
    @IBOutlet var m_lbType2: UILabel!
    @IBOutlet var m_lbAmount2: UILabel!
    @IBOutlet var m_lbStop2: UILabel!
    @IBOutlet var m_consStopHeight2: NSLayoutConstraint!
    @IBOutlet var m_btn2: UIButton!
    
    @IBOutlet var m_lbAmountTitle3: UILabel!
    @IBOutlet var m_lbStopTitle3: UILabel!
    @IBOutlet var m_lbType3: UILabel!
    @IBOutlet var m_lbAmount3: UILabel!
    @IBOutlet var m_lbStop3: UILabel!
    @IBOutlet var m_consStopHeight3: NSLayoutConstraint!
    @IBOutlet var m_btn3: UIButton!

    @IBOutlet var m_lbCommand: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initActView()
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
    // MARK:- UI Methods
    func showActList() {
        if (m_aryActList.count > 0) {
            let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
            for act in m_aryActList {
                actSheet.addButton(withTitle: act)
            }
            actSheet.tag = ViewTag.View_AccountActionSheet.rawValue
            actSheet.show(in: view)
        }
        else {
            showErrorMessage(nil, ErrorMsg_GetList_InCommonAccount)
        }
    }
    func setDate1(_ data: settingData) {
        m_lbType1.text = data.m_strType
        switch data.m_strType {
        case sameAmount:
            m_lbAmountTitle1.text = amountTitle
            m_lbStopTitle1.text = stopTitle
            m_lbAmount1.text = data.m_strAmount
            m_btn1.setTitle(data.m_strBtn, for: UIControlState.normal)
        case sameQuantity:
            m_lbAmountTitle1.text = amountTitle
            m_lbStopTitle1.text = stopTitle
            m_lbAmount1.text = data.m_strAmount
            m_btn1.setTitle(data.m_strBtn, for: UIControlState.normal)
        case diffAmount:
            m_lbAmountTitle1.text = basePrice
            m_lbStopTitle1.text = diffAmountCommand
            m_lbAmount1.text = data.m_strAmount
            m_btn1.setTitle(data.m_strBtn, for: UIControlState.normal)
        default:
            m_lbAmountTitle1.text = amountTitle
            m_lbStopTitle1.text = stopTitle
            m_lbAmount1.text = data.m_strAmount
            m_btn1.setTitle(data.m_strBtn, for: UIControlState.normal)
        }
        if (data.m_strStop.isEmpty == true && data.m_strType != diffAmount) {
            m_lbStop1.text = ""
            m_consStopHeight1.constant = 0
        }
        else {
            m_lbStop1.text = data.m_strStop
            m_consStopHeight1.constant = 36
        }
    }
    func setDate2(_ data: settingData) {
        m_lbType2.text = data.m_strType
        switch data.m_strType {
        case sameAmount:
            m_lbAmountTitle2.text = amountTitle
            m_lbStopTitle2.text = stopTitle
            m_lbAmount2.text = data.m_strAmount
            m_btn2.setTitle(data.m_strBtn, for: UIControlState.normal)
        case sameQuantity:
            m_lbAmountTitle2.text = amountTitle
            m_lbStopTitle2.text = stopTitle
            m_lbAmount2.text = data.m_strAmount
            m_btn2.setTitle(data.m_strBtn, for: UIControlState.normal)
        case diffAmount:
            m_lbAmountTitle2.text = basePrice
            m_lbStopTitle2.text = diffAmountCommand
            m_lbAmount2.text = data.m_strAmount
            m_btn2.setTitle(data.m_strBtn, for: UIControlState.normal)
        default:
            m_lbAmountTitle2.text = amountTitle
            m_lbStopTitle2.text = stopTitle
            m_lbAmount2.text = data.m_strAmount
            m_btn2.setTitle(data.m_strBtn, for: UIControlState.normal)
        }
        if (data.m_strStop.isEmpty == true && data.m_strType != diffAmount) {
            m_lbStop2.text = ""
            m_consStopHeight2.constant = 0
        }
        else {
            m_lbStop2.text = data.m_strStop
            m_consStopHeight2.constant = 36
        }
    }
    func setDate3(_ data: settingData) {
        m_lbType3.text = data.m_strType
        switch data.m_strType {
        case sameAmount:
            m_lbAmountTitle3.text = amountTitle
            m_lbStopTitle3.text = stopTitle
            m_lbAmount3.text = data.m_strAmount
            m_btn3.setTitle(data.m_strBtn, for: UIControlState.normal)
        case sameQuantity:
            m_lbAmountTitle3.text = amountTitle
            m_lbStopTitle3.text = stopTitle
            m_lbAmount3.text = data.m_strAmount
            m_btn3.setTitle(data.m_strBtn, for: UIControlState.normal)
        case diffAmount:
            m_lbAmountTitle3.text = basePrice
            m_lbStopTitle3.text = diffAmountCommand
            m_lbAmount3.text = data.m_strAmount
            m_btn3.setTitle(data.m_strBtn, for: UIControlState.normal)
        default:
            m_lbAmountTitle3.text = amountTitle
            m_lbStopTitle3.text = stopTitle
            m_lbAmount3.text = data.m_strAmount
            m_btn3.setTitle(data.m_strBtn, for: UIControlState.normal)
        }
        if (data.m_strStop.isEmpty == true && data.m_strType != diffAmount) {
            m_lbStop3.text = ""
            m_consStopHeight3.constant = 0
        }
        else {
            m_lbStop3.text = data.m_strStop
            m_consStopHeight3.constant = 36
        }
    }
    func showDiffAmountDetail(_ data: DiffAmountDetail) {
        if m_uiDiffAmountDetail == nil {
            m_uiDiffAmountDetail = getUIByID(.UIID_GPDiffAmountDetailView) as? GPDiffAmountDetailView
            m_uiDiffAmountDetail?.frame = view.frame
            m_uiDiffAmountDetail?.delegate = self
            m_uiDiffAmountDetail?.setData(data)
            view.addSubview(m_uiDiffAmountDetail!)
        }
    }
    // MARK:- Logic Methods
    func processBtnClick(_ data: settingData) {
        switch data.m_strBtn {
        case btnTitleNew:
            performSegue(withIdentifier: "showBuy", sender: data)
        case btnTitleChange:
            performSegue(withIdentifier: "showChange", sender: data)
        case btnTitleCheck:
            let data: DiffAmountDetail = DiffAmountDetail(m_strDate: "date", m_strAmount: "amount", m_strBasePrice: "baseprice", m_strUp: "up", m_strUpAmount: "upamount", m_strDown: "down", m_strDownAmount: "downamount", m_strAmountLimit: "amountlimit")
            self.showDiffAmountDetail(data)
        default:
            break
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let data: settingData = sender as! settingData
        super.prepare(for: segue, sender: sender)
        switch segue.identifier {
        case "showBuy":
            let controller = segue.destination as! GPRegularSubscriptionViewController
            controller.setData((m_uiActView?.getContentByType(.First))!, self.m_lbCurrency.text!, self.m_lbTransOutAct.text!, data.m_strDate)
        case "showChange":
            let controller = segue.destination as! GPRegularChangeViewController
            controller.setData((m_uiActView?.getContentByType(.First))!, self.m_lbTransOutAct.text!, data.m_strDate)
        default:
            return
        }
    }
    // MARK:- WebService Methods
    private func makeFakeAct() {
        m_aryActList.removeAll()
        for i in 0..<20 {
            m_aryActList.append(String.init(format: "%05d", i))
        }
    }
    private func makeFakeActData() {
        let data0: settingData = settingData(m_strDate: "6日", m_strType: "定期不定額", m_strAmount: "3,000,000", m_strStop: "", m_strBtn: "檢視")
        let data1: settingData = settingData(m_strDate: "16日", m_strType: "-", m_strAmount: "-", m_strStop: "", m_strBtn: "申請")
        let data2: settingData = settingData(m_strDate: "26日", m_strType: "定期定額", m_strAmount: "-", m_strStop: "2017/05/30", m_strBtn: "變更")
        m_aryData.removeAll()
        m_aryData.append(data0)
        m_aryData.append(data1)
        m_aryData.append(data2)
        self.m_lbCurrency.text = "台幣"
        self.m_lbTransOutAct.text = "1234567890"
        self.setDate1(m_aryData[0])
        self.setDate2(m_aryData[1])
        self.setDate3(m_aryData[2])
    }
    func send_getActList() {
        self.makeFakeAct()
//        postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
    }
    func send_getActData() {
        self.makeFakeActData()
    }
    // MARK:- Handle Actions
    @IBAction func m_btn1Click(_ sender: Any) {
        self.processBtnClick(m_aryData[0])
    }
    @IBAction func m_btn2Click(_ sender: Any) {
        self.processBtnClick(m_aryData[1])
    }
    @IBAction func m_btn3Click(_ sender: Any) {
        self.processBtnClick(m_aryData[2])
    }
    
}
extension GPRegularAccountInfomationViewController : OneRowDropDownViewDelegate {
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
extension GPRegularAccountInfomationViewController : UIActionSheetDelegate {
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet.cancelButtonIndex != buttonIndex {
            switch (actionSheet.tag) {
            case ViewTag.View_AccountActionSheet.rawValue:
                let iIndex : Int = buttonIndex - 1
                let act : String = m_aryActList[iIndex]
                m_uiActView?.setOneRow(GPAccountTitle, act)
                self.send_getActData()
                self.m_svContent.isHidden = false
            default:
                break
            }
        }
    }
}
extension GPRegularAccountInfomationViewController : GPDiffAmountDetailViewDelegate {
    func clickDiffAmountDetailViewCloseBtn() {
        m_uiDiffAmountDetail?.removeFromSuperview()
        m_uiDiffAmountDetail = nil
    }
}
