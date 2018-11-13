//
//  GPRegularChangeViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/7/31.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit

let GPRegularChangeTitle = "定期投資變更"
let changeAmount = "修改金額"
let changeQuantity = "修改數量"
let pauseDebit = "暫停扣款"
let resumeDebit = "取消暫停扣款"
let stopDebit = "解除約定扣款"
let dataDateFormat = "yyyyMMdd"
let showDateFormat = "yyyy/MM/dd"

class GPRegularChangeViewController: BaseViewController {
    var m_uiSettingView: OneRowDropDownView? = nil
    var m_uiPauseStartView: OneRowDropDownView? = nil
    var m_uiPauseEndView: OneRowDropDownView? = nil
    var m_objPassData: GPPassData? = nil
    var m_iSettingIndex: Int = 0
    var m_strPauseStart: String = Choose_Title
    var m_strPauseEnd: String = Choose_Title
    var m_arySettingList: [String] = [String]()
    var m_strBuyAmount: String = ""
    var m_enumPauseStatus: GPPauseStatus = GPPauseStatus.GPPauseStatusNone

    @IBOutlet var m_lbGPAct: UILabel!
    @IBOutlet var m_lbTransOutAct: UILabel!
    @IBOutlet var m_lbTradeDate: UILabel!
    @IBOutlet var m_lbTradeTitle: UILabel!
    @IBOutlet var m_tfTradeInput: TextField!
    @IBOutlet var m_lbTradeAmount: UILabel!
    @IBOutlet var m_vSettingView: UIView!
    @IBOutlet var m_vPauseStartView: UIView!
    @IBOutlet var m_vPauseStartBottomLine: UIView!
    @IBOutlet var m_vPauseEndView: UIView!
    @IBOutlet var m_vPauseEndBottomLine: UIView!
    @IBOutlet var m_lbCommand: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        m_lbGPAct.text = m_objPassData?.m_accountStruct.accountNO
        m_lbTransOutAct.text = m_objPassData?.m_strTransOutAct
        m_lbTradeDate.text = (m_objPassData?.m_settingData.m_strDAY)! + "日"
        m_enumPauseStatus = checkPauseStatus((m_objPassData?.m_settingData.m_strSDAY)!, (m_objPassData?.m_settingData.m_strEDAY)!, (m_objPassData?.m_settingData.m_strDATE)!)
        if (m_objPassData?.m_settingData.m_strTYPE == GPRegularType.GPRegularTypeSameAmount) {//定期定額
            m_lbTradeTitle.text = "投資金額"
            m_tfTradeInput.placeholder = "請輸入投資金額"
            if (m_enumPauseStatus == .GPPauseStatusNone ||
                m_enumPauseStatus == .GPPauseStatusAfter) {
                m_arySettingList = [changeAmount, pauseDebit, stopDebit]
            }
            else if (m_enumPauseStatus == .GPPauseStatusBefore ||
                m_enumPauseStatus == .GPPauseStatusIng) {
                m_arySettingList = [changeAmount, resumeDebit, stopDebit]
                m_iSettingIndex = 1//暫停扣款時，預設扣款設定為"取消暫停扣款"
                m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
                m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
            }
        }
        else if (m_objPassData?.m_settingData.m_strTYPE == GPRegularType.GPRegularTypeSameQuantity) {//定期定量
            m_lbTradeTitle.text = "投資數量"
            m_tfTradeInput.placeholder = "請輸入投資數量"
            if (m_enumPauseStatus == .GPPauseStatusNone ||
                m_enumPauseStatus == .GPPauseStatusAfter) {
                m_arySettingList = [changeQuantity, pauseDebit, stopDebit]
            }
            else if (m_enumPauseStatus == .GPPauseStatusBefore ||
                m_enumPauseStatus == .GPPauseStatusIng) {
                m_arySettingList = [changeQuantity, resumeDebit, stopDebit]
                m_iSettingIndex = 1//暫停扣款時，預設扣款設定為"取消暫停扣款"
                m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
                m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
            }
        }
        else {
            m_arySettingList = [m_objPassData?.m_settingData.m_strTYPE.getTitle()] as! [String]
        }
        
        initSettingView()
        initPauseStartView()
        initPauseEndView()

        self.addGestureForKeyBoard()
        self.changeView(m_arySettingList[m_iSettingIndex])
        self.send_QueryData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.topItem?.title = GPRegularChangeTitle
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK:- Init Methods
    func setData(_ data: GPPassData) {
        m_objPassData = data
    }
    private func initSettingView() {
        m_uiSettingView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        m_uiSettingView?.delegate = self
        m_uiSettingView?.frame = m_vSettingView.frame
        m_uiSettingView?.frame.origin = .zero
        m_uiSettingView?.setOneRow("扣款設定", m_arySettingList[m_iSettingIndex])
        m_uiSettingView?.m_lbFirstRowTitle.textAlignment = .center
        m_vSettingView.addSubview(m_uiSettingView!)
    }
    private func initPauseStartView() {
        m_uiPauseStartView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        m_uiPauseStartView?.delegate = self
        m_uiPauseStartView?.frame = m_vPauseStartView.frame
        m_uiPauseStartView?.frame.origin = .zero
        m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart)
        m_uiPauseStartView?.m_lbFirstRowTitle.textAlignment = .center
        m_vPauseStartView.addSubview(m_uiPauseStartView!)
    }
    private func initPauseEndView() {
        m_uiPauseEndView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        m_uiPauseEndView?.delegate = self
        m_uiPauseEndView?.frame = m_vPauseEndView.frame
        m_uiPauseEndView?.frame.origin = .zero
        m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd)
        m_uiPauseEndView?.m_lbFirstRowTitle.textAlignment = .center
        m_vPauseEndView.addSubview(m_uiPauseEndView!)
    }

    // MARK:- UI Methods
    private func initView4ChangeAmount() {
        m_tfTradeInput.text = m_objPassData?.m_settingData.m_strAMT.separatorDecimal()
        m_tfTradeInput.isHidden = false
        m_strBuyAmount = (m_objPassData?.m_settingData.m_strAMT)!.separatorDecimal()
        m_lbTradeAmount.text = m_objPassData?.m_settingData.m_strAMT.separatorThousand()
        m_lbTradeAmount.isHidden = true
        if (m_enumPauseStatus == .GPPauseStatusNone) {
            m_vPauseStartView.isHidden = true
            m_vPauseStartBottomLine.isHidden = true
            m_vPauseEndView.isHidden = true
            m_vPauseEndBottomLine.isHidden = true
        }
        else if (m_enumPauseStatus == .GPPauseStatusBefore) {
            m_vPauseStartView.isHidden = false
            m_vPauseStartBottomLine.isHidden = false
            m_vPauseEndView.isHidden = false
            m_vPauseEndBottomLine.isHidden = false
            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
            m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat))
            m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat))
        }
        else if (m_enumPauseStatus == .GPPauseStatusIng) {
            m_vPauseStartView.isHidden = false
            m_vPauseStartBottomLine.isHidden = false
            m_vPauseEndView.isHidden = false
            m_vPauseEndBottomLine.isHidden = false
            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
            m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat))
            m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat))
        }
        else if (m_enumPauseStatus == .GPPauseStatusAfter) {
            m_vPauseStartView.isHidden = true
            m_vPauseStartBottomLine.isHidden = true
            m_vPauseEndView.isHidden = true
            m_vPauseEndBottomLine.isHidden = true
        }
    }
    private func initView4ChangeQuantity() {
        m_tfTradeInput.text = m_objPassData?.m_settingData.m_strAMT.separatorDecimal()
        m_tfTradeInput.isHidden = false
        m_strBuyAmount = (m_objPassData?.m_settingData.m_strAMT)!.separatorDecimal()
        m_lbTradeAmount.text = m_objPassData?.m_settingData.m_strAMT.separatorThousand()
        m_lbTradeAmount.isHidden = true

        if (m_enumPauseStatus == .GPPauseStatusNone) {
            m_vPauseStartView.isHidden = true
            m_vPauseStartBottomLine.isHidden = true
            m_vPauseEndView.isHidden = true
            m_vPauseEndBottomLine.isHidden = true
        }
        else if (m_enumPauseStatus == .GPPauseStatusBefore) {
            m_vPauseStartView.isHidden = false
            m_vPauseStartBottomLine.isHidden = false
            m_vPauseEndView.isHidden = false
            m_vPauseEndBottomLine.isHidden = false
            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
            m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat))
            m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat))
        }
        else if (m_enumPauseStatus == .GPPauseStatusIng) {
            m_vPauseStartView.isHidden = false
            m_vPauseStartBottomLine.isHidden = false
            m_vPauseEndView.isHidden = false
            m_vPauseEndBottomLine.isHidden = false
            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
            m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat))
            m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat))
        }
        else if (m_enumPauseStatus == .GPPauseStatusAfter) {
            m_vPauseStartView.isHidden = true
            m_vPauseStartBottomLine.isHidden = true
            m_vPauseEndView.isHidden = true
            m_vPauseEndBottomLine.isHidden = true
        }
    }
    private func initView4PauseDebit() {
        m_tfTradeInput.text = ""
        m_tfTradeInput.isHidden = true
        m_strBuyAmount = (m_objPassData?.m_settingData.m_strAMT)!.separatorDecimal()
        m_lbTradeAmount.text = m_objPassData?.m_settingData.m_strAMT.separatorThousand()
        m_lbTradeAmount.isHidden = false

        if (m_enumPauseStatus == .GPPauseStatusNone) {
            m_vPauseStartView.isHidden = false
            m_vPauseStartBottomLine.isHidden = false
            m_vPauseEndView.isHidden = false
            m_vPauseEndBottomLine.isHidden = false
            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
            m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat))
            m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat))
        }
        else if (m_enumPauseStatus == .GPPauseStatusBefore) {//理論上不會有
        }
        else if (m_enumPauseStatus == .GPPauseStatusIng) {//理論上不會有
        }
        else if (m_enumPauseStatus == .GPPauseStatusAfter) {
            m_vPauseStartView.isHidden = false
            m_vPauseStartBottomLine.isHidden = false
            m_vPauseEndView.isHidden = false
            m_vPauseEndBottomLine.isHidden = false
            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
            m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat))
            m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat))
        }
    }
    private func initView4ResumeDebit() {
        m_tfTradeInput.text = ""
        m_tfTradeInput.isHidden = true
        m_strBuyAmount = (m_objPassData?.m_settingData.m_strAMT)!.separatorDecimal()
        m_lbTradeAmount.text = m_objPassData?.m_settingData.m_strAMT.separatorThousand()
        m_lbTradeAmount.isHidden = false

        if (m_enumPauseStatus == .GPPauseStatusNone) {//理論上不會有
        }
        else if (m_enumPauseStatus == .GPPauseStatusBefore) {
            m_vPauseStartView.isHidden = false
            m_vPauseStartBottomLine.isHidden = false
            m_vPauseEndView.isHidden = false
            m_vPauseEndBottomLine.isHidden = false
            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
            m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
            m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
        }
        else if (m_enumPauseStatus == .GPPauseStatusIng) {
            m_vPauseStartView.isHidden = false
            m_vPauseStartBottomLine.isHidden = false
            m_vPauseEndView.isHidden = false
            m_vPauseEndBottomLine.isHidden = false
            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
            m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
            m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
        }
        else if (m_enumPauseStatus == .GPPauseStatusAfter) {//理論上不會有
        }
    }
    private func initView4StopDebit() {
        m_tfTradeInput.text = ""
        m_tfTradeInput.isHidden = true
        m_strBuyAmount = (m_objPassData?.m_settingData.m_strAMT)!.separatorDecimal()
        m_lbTradeAmount.text = m_objPassData?.m_settingData.m_strAMT.separatorThousand()
        m_lbTradeAmount.isHidden = false
        if (m_enumPauseStatus == .GPPauseStatusNone) {
            m_vPauseStartView.isHidden = true
            m_vPauseStartBottomLine.isHidden = true
            m_vPauseEndView.isHidden = true
            m_vPauseEndBottomLine.isHidden = true
        }
        else if (m_enumPauseStatus == .GPPauseStatusBefore) {
            m_vPauseStartView.isHidden = false
            m_vPauseStartBottomLine.isHidden = false
            m_vPauseEndView.isHidden = false
            m_vPauseEndBottomLine.isHidden = false
            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
            m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
            m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
        }
        else if (m_enumPauseStatus == .GPPauseStatusIng) {
            m_vPauseStartView.isHidden = false
            m_vPauseStartBottomLine.isHidden = false
            m_vPauseEndView.isHidden = false
            m_vPauseEndBottomLine.isHidden = false
            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
            m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
            m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
        }
        else if (m_enumPauseStatus == .GPPauseStatusAfter) {
            m_vPauseStartView.isHidden = true
            m_vPauseStartBottomLine.isHidden = true
            m_vPauseEndView.isHidden = true
            m_vPauseEndBottomLine.isHidden = true
        }
    }
    func showSettingList() {
            let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
            for setting in m_arySettingList {
                actSheet.addButton(withTitle: setting)
            }
            actSheet.tag = ViewTag.View_AccountActionSheet.rawValue
            actSheet.show(in: view)
    }
    func changeView(_ setting: String) {
        switch setting {
        case changeAmount:
            self.initView4ChangeAmount()
        case changeQuantity:
            self.initView4ChangeQuantity()
        case pauseDebit:
            self.initView4PauseDebit()
        case resumeDebit:
            self.initView4ResumeDebit()
        case stopDebit:
            self.initView4StopDebit()
        default:
            break
        }
    }
    // MARK:- Logic Methods
    private func checkPauseStatus(_ start: String, _ end: String, _ today: String) -> GPPauseStatus {
        //是否申請過暫停扣款
        let emptyDate: String = "00000000"
        let dateForm: String = dataDateFormat
        if (start == emptyDate || end == emptyDate) {
            return GPPauseStatus.GPPauseStatusNone
        }
        let startDate: Date? = start.toDate(dateForm)
        let endDate: Date? = end.toDate(dateForm)
        let todayDate: Date? = today.toDate(dateForm)
        if (startDate == nil || endDate == nil || todayDate == nil) {
            NSLog("===== 日期格式有誤[%@][%@][%@]", start, end, today)
            return GPPauseStatus.GPPauseStatusNone
        }
        if (todayDate?.compare(startDate!) == ComparisonResult.orderedAscending) {//今日在暫停區間前
            return GPPauseStatus.GPPauseStatusBefore
        }
        else if (todayDate?.compare(startDate!) == ComparisonResult.orderedDescending &&
            todayDate?.compare(endDate!) == ComparisonResult.orderedAscending) {//今日在暫停區間中
            return GPPauseStatus.GPPauseStatusIng
        }
        else if (todayDate?.compare(endDate!) == ComparisonResult.orderedDescending) {//今日在暫停區間後
            return GPPauseStatus.GPPauseStatusAfter
        }
        else {
            NSLog("===== 日期關係有誤[%@][%@][%@]", start, end, today)
            return GPPauseStatus.GPPauseStatusNone
        }
    }
    func enterConfirmView_SameAmount() {
        var data : [String:String] = [String:String]()
        data["WorkCode"] = "10009"
        data["Operate"] = "commitTxn"
        data["TransactionId"] = transactionId
        data["REFNO"] = m_objPassData?.m_accountStruct.accountNO
        data["INVACT"] = m_objPassData?.m_strTransOutAct
        data["DD"] = m_objPassData?.m_settingData.m_strDAY
        data["AMT"] = m_strBuyAmount
        data["SETUP"] = String(m_iSettingIndex)
        
        // 暫停起日, 暫停訖日
        if (m_iSettingIndex == 1) {
            data["STPSDAY"] = m_strPauseStart
            data["STPEDAY"] = m_strPauseEnd
        }
        else {
            data["STPSDAY"] = (m_objPassData?.m_settingData.m_strSDAY)!
            data["STPEDAY"] = (m_objPassData?.m_settingData.m_strEDAY)!
        }
        
        let confirmRequest = RequestStruct(strMethod: "Gold/Gold0402", strSessionDescription: "Gold0402", httpBody: AuthorizationManage.manage.converInputToHttpBody(data, true), loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false, timeOut: REQUEST_TIME_OUT)
        
        var dataConfirm = ConfirmResultStruct(image: ImageName.CowCheck.rawValue, title: Check_Transaction_Title, list: [[String:String]](), memo: "", confirmBtnName: "確認送出", resultBtnName: "繼續交易", checkRequest: confirmRequest)
        dataConfirm.list?.append([Response_Key: "黃金存摺帳號", Response_Value: (m_objPassData?.m_accountStruct.accountNO)!])
        dataConfirm.list?.append([Response_Key: "扣款帳號", Response_Value: (m_objPassData?.m_strTransOutAct)!])
        dataConfirm.list?.append([Response_Key: "扣款日期", Response_Value: (m_objPassData?.m_settingData.m_strDAY)! + "日"])
        dataConfirm.list?.append([Response_Key: "投資金額", Response_Value: m_strBuyAmount.separatorThousand()])
        dataConfirm.list?.append([Response_Key: "扣款設定", Response_Value: m_arySettingList[m_iSettingIndex]])
        if (m_vPauseStartView.isHidden == false) {
            dataConfirm.list?.append([Response_Key: "暫停起日", Response_Value: m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat)])
        }
        if (m_vPauseEndView.isHidden == false) {
            dataConfirm.list?.append([Response_Key: "暫停訖日", Response_Value: m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat)])
        }
        enterConfirmResultController(true, dataConfirm, true, GPRegularChangeTitle)
    }
    func enterConfirmView_SameQuantity() {
        var data : [String:String] = [String:String]()
        data["WorkCode"] = "10011"
        data["Operate"] = "commitTxn"
        data["TransactionId"] = transactionId
        data["REFNO"] = m_objPassData?.m_accountStruct.accountNO
        data["INVACT"] = m_objPassData?.m_strTransOutAct
        data["DD"] = m_objPassData?.m_settingData.m_strDAY
        data["QTY"] = m_strBuyAmount
        data["SETUP"] = String(m_iSettingIndex)
        
        // 暫停起日, 暫停訖日
        if (m_iSettingIndex == 1) {
            data["STPSDAY"] = m_strPauseStart
            data["STPEDAY"] = m_strPauseEnd
        }
        else {
            data["STPSDAY"] = (m_objPassData?.m_settingData.m_strSDAY)!
            data["STPEDAY"] = (m_objPassData?.m_settingData.m_strEDAY)!
        }
        
        let confirmRequest = RequestStruct(strMethod: "Gold/Gold0404", strSessionDescription: "Gold0404", httpBody: AuthorizationManage.manage.converInputToHttpBody(data, true), loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false, timeOut: REQUEST_TIME_OUT)
        
        var dataConfirm = ConfirmResultStruct(image: ImageName.CowCheck.rawValue, title: Check_Transaction_Title, list: [[String:String]](), memo: "", confirmBtnName: "確認送出", resultBtnName: "繼續交易", checkRequest: confirmRequest)
        dataConfirm.list?.append([Response_Key: "黃金存摺帳號", Response_Value: (m_objPassData?.m_accountStruct.accountNO)!])
        dataConfirm.list?.append([Response_Key: "扣款帳號", Response_Value: (m_objPassData?.m_strTransOutAct)!])
        dataConfirm.list?.append([Response_Key: "扣款日期", Response_Value: (m_objPassData?.m_settingData.m_strDAY)! + "日"])
        dataConfirm.list?.append([Response_Key: "投資數量(克)", Response_Value: m_strBuyAmount.separatorThousand()])
        dataConfirm.list?.append([Response_Key: "扣款設定", Response_Value: m_arySettingList[m_iSettingIndex]])
        if (m_vPauseStartView.isHidden == false) {
            dataConfirm.list?.append([Response_Key: "暫停起日", Response_Value: m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat)])
        }
        if (m_vPauseEndView.isHidden == false) {
            dataConfirm.list?.append([Response_Key: "暫停訖日", Response_Value: m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat)])
        }
        enterConfirmResultController(true, dataConfirm, true, GPRegularChangeTitle)
    }
    func enterConfirmView() {
        if (m_objPassData?.m_settingData.m_strTYPE == GPRegularType.GPRegularTypeSameAmount) {
//            getTransactionID("10009", TransactionID_Description)
            enterConfirmView_SameAmount()
        }
        else if (m_objPassData?.m_settingData.m_strTYPE == GPRegularType.GPRegularTypeSameQuantity) {
//            getTransactionID("10011", TransactionID_Description)
            enterConfirmView_SameQuantity()
        }
    }

    // MARK:- WebService Methods
    func send_QueryData() {
        let strAct: String = (m_objPassData?.m_accountStruct.accountNO)!
        let strType: String = "IC"
        postRequest("Gold/Gold0601", "Gold0601", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10014", "Operate":"queryData", "Type":strType, "REFNO":strAct], true), AuthorizationManage.manage.getHttpHead(true))
    }
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                if (m_objPassData?.m_settingData.m_strTYPE == GPRegularType.GPRegularTypeSameAmount) {
                    enterConfirmView_SameAmount()
                }
                else if (m_objPassData?.m_settingData.m_strTYPE == GPRegularType.GPRegularTypeSameQuantity) {
                    enterConfirmView_SameQuantity()
                }
            }
            else {
                super.didResponse(description, response)
            }
        case "Gold0601":
            if let data = response.object(forKey: ReturnData_Key) as? [String:String], let content = data["Content"] {
                m_lbCommand.text = content
            }
        default:
            super.didResponse(description, response)
        }
    }

    // MARK:- Handle Actions
    @IBAction func m_btnNextClick(_ sender: Any) {
        if (m_enumPauseStatus == .GPPauseStatusIng) {
        self.showAlert(title: nil, msg: "本筆定期投資已設定暫停扣款，請確認是否繼續？", confirmTitle: "是", cancleTitle: "否", completionHandler: { self.enterConfirmView() }, cancelHandelr: {()})
        }
        else {
            self.enterConfirmView()
        }
//        else {
//            return
//        }
    }
    override func clickBackBarItem() {
        for vc in (self.navigationController?.viewControllers)! {
            if (vc.isKind(of: GPRegularAccountInfomationViewController.self)) {
                navigationController?.popToViewController(vc, animated: true)
            }
        }
    }
}
extension GPRegularChangeViewController : OneRowDropDownViewDelegate {
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        self.dismissKeyboard()
        if (sender == m_uiSettingView) {
            showSettingList()
        }
        else if (sender == m_uiPauseStartView) {
            if let datePicker = getUIByID(.UIID_DatePickerView) as? DatePickerView {
                datePicker.frame = view.frame
                datePicker.frame.origin = .zero
                var today: Date = (m_objPassData?.m_settingData.m_strDATE.toDate(dataDateFormat))!
                if (m_strPauseStart != Choose_Title) {
                    today = m_strPauseStart.toDate(dataDateFormat)!
                }
                let curDate = InputDatePickerStruct(minDate: Date(), maxDate: nil, curDate: today)
                datePicker.showOneDatePickerView(true, curDate) { start in
                    self.m_strPauseStart = "\(start.year)\(start.month)\(start.day)"
                    self.m_uiPauseStartView?.setOneRow("暫停起日", self.m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat))
//                    self.m_uiPauseStartView?.setOneRow("暫停起日", "\(start.year)/\(start.month)/\(start.day)")
                }
                view.addSubview(datePicker)
            }
            
        }
        else if (sender == m_uiPauseEndView) {
            if let datePicker = getUIByID(.UIID_DatePickerView) as? DatePickerView {
                datePicker.frame = view.frame
                datePicker.frame.origin = .zero
                var today: Date = (m_objPassData?.m_settingData.m_strDATE.toDate(dataDateFormat))!
                if (m_strPauseEnd != Choose_Title) {
                    today = m_strPauseEnd.toDate(dataDateFormat)!
                }
                let curDate = InputDatePickerStruct(minDate: Date(), maxDate: nil, curDate: today)
                datePicker.showOneDatePickerView(true, curDate) { end in
                    self.m_strPauseEnd = "\(end.year)\(end.month)\(end.day)"
                    self.m_uiPauseEndView?.setOneRow("暫停訖日", self.m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat))
//                    self.m_uiPauseEndView?.setOneRow("暫停訖日", "\(end.year)/\(end.month)/\(end.day)")
                }
                view.addSubview(datePicker)
            }
        }
    }
}
extension GPRegularChangeViewController : UIActionSheetDelegate {
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet.cancelButtonIndex != buttonIndex {
            switch (actionSheet.tag) {
            case ViewTag.View_AccountActionSheet.rawValue:
                m_iSettingIndex = buttonIndex - 1
                m_uiSettingView?.setOneRow("扣款設定", m_arySettingList[m_iSettingIndex])
                self.changeView(m_arySettingList[m_iSettingIndex])
            default:
                break
            }
        }
    }
}
extension GPRegularChangeViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        guard DetermineUtility.utility.isAllNumber(newString) else {
            return false
        }
        
        let newLength = (textField.text?.count)! - range.length + string.count
        let maxLength = Max_GoldGram_Length
        if newLength <= maxLength {
            m_strBuyAmount = newString
            return true
        }
        else {
            return false
        }
    }
}
