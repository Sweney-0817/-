//
//  GPRegularChangeViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/7/31.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit
import WebKit

let GPRegularChangeTitle = "定期投資變更"
let changeAmount = "修改金額"
let changeQuantity = "修改數量"
let pauseDebit = "暫停扣款設定"
let resumeDebit = "取消暫停扣款"
let stopDebit = "解除約定扣款"
//let dataDateFormat = "yyyyMMdd"
//let showDateFormat = "yyyy/MM/dd"
//let emptyDate: String = "00000000"

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
    @IBOutlet var m_consPauseStartViewHeight: NSLayoutConstraint!
    @IBOutlet var m_vPauseEndView: UIView!
    @IBOutlet var m_vPauseEndBottomLine: UIView!
    @IBOutlet var m_consPauseEndViewHeight: NSLayoutConstraint!
    @IBOutlet var m_wvMemo: WKWebView!
    @IBOutlet var m_consMemoHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        m_lbGPAct.text = m_objPassData?.m_accountStruct.accountNO
        m_lbTransOutAct.text = m_objPassData?.m_strTransOutAct
        m_lbTradeDate.text = (m_objPassData?.m_settingData.m_strDAY)! + "日"
        //起訖日為"00000000"時顯示"請選擇"
        if ((m_objPassData?.m_settingData.m_strSDAY)! != emptyDate) {
            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
        }
        if ((m_objPassData?.m_settingData.m_strEDAY)! != emptyDate) {
            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
        }

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
                m_arySettingList = [changeAmount, pauseDebit, resumeDebit, stopDebit]
                m_iSettingIndex = 2//暫停扣款時，預設扣款設定為"取消暫停扣款"
            }
        }
        else if (m_objPassData?.m_settingData.m_strTYPE == GPRegularType.GPRegularTypeSameQuantity) {//定期定量
            m_lbTradeTitle.text = "投資數量(克)"
            m_tfTradeInput.placeholder = "請輸入投資數量"
            if (m_enumPauseStatus == .GPPauseStatusNone ||
                m_enumPauseStatus == .GPPauseStatusAfter) {
                m_arySettingList = [changeQuantity, pauseDebit, stopDebit]
            }
            else if (m_enumPauseStatus == .GPPauseStatusBefore ||
                m_enumPauseStatus == .GPPauseStatusIng) {
                m_arySettingList = [changeQuantity, pauseDebit, resumeDebit, stopDebit]
                m_iSettingIndex = 2//暫停扣款時，預設扣款設定為"取消暫停扣款"
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
        self.send_queryData()
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
//        m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat))
        m_uiPauseStartView?.m_lbFirstRowTitle.textAlignment = .center
        m_vPauseStartView.addSubview(m_uiPauseStartView!)
    }
    private func initPauseEndView() {
        m_uiPauseEndView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        m_uiPauseEndView?.delegate = self
        m_uiPauseEndView?.frame = m_vPauseEndView.frame
        m_uiPauseEndView?.frame.origin = .zero
//        m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat))
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
            m_consPauseStartViewHeight.constant = 0
            m_consPauseEndViewHeight.constant = 0
            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
            m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
            m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
        }
        else if (m_enumPauseStatus == .GPPauseStatusBefore ||
            m_enumPauseStatus == .GPPauseStatusIng) {
            m_vPauseStartView.isHidden = false
            m_vPauseStartBottomLine.isHidden = false
            m_vPauseEndView.isHidden = false
            m_vPauseEndBottomLine.isHidden = false
            m_consPauseStartViewHeight.constant = 60
            m_consPauseEndViewHeight.constant = 60
            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
            m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat))
            m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat))
        }
//        else if (m_enumPauseStatus == .GPPauseStatusIng) {
//            m_vPauseStartView.isHidden = false
//            m_vPauseStartBottomLine.isHidden = false
//            m_vPauseEndView.isHidden = false
//            m_vPauseEndBottomLine.isHidden = false
//            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
//            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
//            m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat))
//            m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat))
//        }
        else if (m_enumPauseStatus == .GPPauseStatusAfter) {
            m_vPauseStartView.isHidden = false
            m_vPauseStartBottomLine.isHidden = false
            m_vPauseEndView.isHidden = false
            m_vPauseEndBottomLine.isHidden = false
            m_consPauseStartViewHeight.constant = 60
            m_consPauseEndViewHeight.constant = 60
            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
            m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
            m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
        }
    }
    private func initView4ChangeQuantity() {
        m_tfTradeInput.text = m_objPassData?.m_settingData.m_strQTY.separatorDecimal()
        m_tfTradeInput.isHidden = false
        m_strBuyAmount = (m_objPassData?.m_settingData.m_strQTY)!.separatorDecimal()
        m_lbTradeAmount.text = m_objPassData?.m_settingData.m_strQTY.separatorThousand()
        m_lbTradeAmount.isHidden = true

        if (m_enumPauseStatus == .GPPauseStatusNone) {
            m_vPauseStartView.isHidden = true
            m_vPauseStartBottomLine.isHidden = true
            m_vPauseEndView.isHidden = true
            m_vPauseEndBottomLine.isHidden = true
            m_consPauseStartViewHeight.constant = 0
            m_consPauseEndViewHeight.constant = 0
            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
            m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
            m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
        }
        else if (m_enumPauseStatus == .GPPauseStatusBefore ||
            m_enumPauseStatus == .GPPauseStatusIng) {
            m_vPauseStartView.isHidden = false
            m_vPauseStartBottomLine.isHidden = false
            m_vPauseEndView.isHidden = false
            m_vPauseEndBottomLine.isHidden = false
            m_consPauseStartViewHeight.constant = 60
            m_consPauseEndViewHeight.constant = 60
            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
            m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat))
            m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat))
        }
//        else if (m_enumPauseStatus == .GPPauseStatusIng) {
//            m_vPauseStartView.isHidden = false
//            m_vPauseStartBottomLine.isHidden = false
//            m_vPauseEndView.isHidden = false
//            m_vPauseEndBottomLine.isHidden = false
//            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
//            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
//            m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat))
//            m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat))
//        }
        else if (m_enumPauseStatus == .GPPauseStatusAfter) {
            m_vPauseStartView.isHidden = false
            m_vPauseStartBottomLine.isHidden = false
            m_vPauseEndView.isHidden = false
            m_vPauseEndBottomLine.isHidden = false
            m_consPauseStartViewHeight.constant = 60
            m_consPauseEndViewHeight.constant = 60
            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
            m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
            m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
        }
    }
    private func initView4PauseDebit() {
        m_tfTradeInput.text = ""
        m_tfTradeInput.isHidden = true
        m_strBuyAmount = m_objPassData?.m_settingData.m_strTYPE == GPRegularType.GPRegularTypeSameAmount ? (m_objPassData?.m_settingData.m_strAMT)!.separatorDecimal() : (m_objPassData?.m_settingData.m_strQTY)!.separatorDecimal()
        m_lbTradeAmount.text = m_objPassData?.m_settingData.m_strTYPE == GPRegularType.GPRegularTypeSameAmount ? (m_objPassData?.m_settingData.m_strAMT)!.separatorDecimal() : (m_objPassData?.m_settingData.m_strQTY)!.separatorDecimal()
        m_lbTradeAmount.isHidden = false

        if (m_enumPauseStatus == .GPPauseStatusNone) {
            m_vPauseStartView.isHidden = false
            m_vPauseStartBottomLine.isHidden = false
            m_vPauseEndView.isHidden = false
            m_vPauseEndBottomLine.isHidden = false
            m_consPauseStartViewHeight.constant = 60
            m_consPauseEndViewHeight.constant = 60
            m_strPauseStart = Choose_Title
            m_strPauseEnd = Choose_Title
            m_uiPauseStartView?.setOneRow("暫停起日", Choose_Title)
            m_uiPauseEndView?.setOneRow("暫停訖日", Choose_Title)
        }
        else if (m_enumPauseStatus == .GPPauseStatusBefore ||
            m_enumPauseStatus == .GPPauseStatusIng) {
            m_vPauseStartView.isHidden = false
            m_vPauseStartBottomLine.isHidden = false
            m_vPauseEndView.isHidden = false
            m_vPauseEndBottomLine.isHidden = false
            m_consPauseStartViewHeight.constant = 60
            m_consPauseEndViewHeight.constant = 60
            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
            m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat))
            m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat))
        }
//        else if (m_enumPauseStatus == .GPPauseStatusIng) {//理論上不會有
//        }
        else if (m_enumPauseStatus == .GPPauseStatusAfter) {
            m_vPauseStartView.isHidden = false
            m_vPauseStartBottomLine.isHidden = false
            m_vPauseEndView.isHidden = false
            m_vPauseEndBottomLine.isHidden = false
            m_consPauseStartViewHeight.constant = 60
            m_consPauseEndViewHeight.constant = 60
            m_strPauseStart = Choose_Title
            m_strPauseEnd = Choose_Title
            m_uiPauseStartView?.setOneRow("暫停起日", Choose_Title)
            m_uiPauseEndView?.setOneRow("暫停訖日", Choose_Title)
        }
    }
    private func initView4ResumeDebit() {
        m_tfTradeInput.text = ""
        m_tfTradeInput.isHidden = true
        m_strBuyAmount = m_objPassData?.m_settingData.m_strTYPE == GPRegularType.GPRegularTypeSameAmount ? (m_objPassData?.m_settingData.m_strAMT)!.separatorDecimal() : (m_objPassData?.m_settingData.m_strQTY)!.separatorDecimal()
        m_lbTradeAmount.text = m_objPassData?.m_settingData.m_strTYPE == GPRegularType.GPRegularTypeSameAmount ? (m_objPassData?.m_settingData.m_strAMT)!.separatorDecimal() : (m_objPassData?.m_settingData.m_strQTY)!.separatorDecimal()
        m_lbTradeAmount.isHidden = false

        if (m_enumPauseStatus == .GPPauseStatusNone) {//理論上不會有
            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
            m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
            m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
        }
        else if (m_enumPauseStatus == .GPPauseStatusBefore ||
            m_enumPauseStatus == .GPPauseStatusIng) {
            m_vPauseStartView.isHidden = false
            m_vPauseStartBottomLine.isHidden = false
            m_vPauseEndView.isHidden = false
            m_vPauseEndBottomLine.isHidden = false
            m_consPauseStartViewHeight.constant = 60
            m_consPauseEndViewHeight.constant = 60
            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
            m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
            m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
        }
//        else if (m_enumPauseStatus == .GPPauseStatusIng) {
//            m_vPauseStartView.isHidden = false
//            m_vPauseStartBottomLine.isHidden = false
//            m_vPauseEndView.isHidden = false
//            m_vPauseEndBottomLine.isHidden = false
//            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
//            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
//            m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
//            m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
//        }
        else if (m_enumPauseStatus == .GPPauseStatusAfter) {//理論上不會有
            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
            m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
            m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
        }
    }
    private func initView4StopDebit() {
        m_tfTradeInput.text = ""
        m_tfTradeInput.isHidden = true
        m_strBuyAmount = m_objPassData?.m_settingData.m_strTYPE == GPRegularType.GPRegularTypeSameAmount ? (m_objPassData?.m_settingData.m_strAMT)!.separatorDecimal() : (m_objPassData?.m_settingData.m_strQTY)!.separatorDecimal()
        m_lbTradeAmount.text = m_objPassData?.m_settingData.m_strTYPE == GPRegularType.GPRegularTypeSameAmount ? (m_objPassData?.m_settingData.m_strAMT)!.separatorDecimal() : (m_objPassData?.m_settingData.m_strQTY)!.separatorDecimal()
        m_lbTradeAmount.isHidden = false

        if (m_enumPauseStatus == .GPPauseStatusNone) {
            m_vPauseStartView.isHidden = false
            m_vPauseStartBottomLine.isHidden = false
            m_vPauseEndView.isHidden = false
            m_vPauseEndBottomLine.isHidden = false
            m_consPauseStartViewHeight.constant = 60
            m_consPauseEndViewHeight.constant = 60
            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
            m_uiPauseStartView?.setOneRow("暫停起日", "-", false)
            m_uiPauseEndView?.setOneRow("暫停訖日", "-", false)
        }
        else if (m_enumPauseStatus == .GPPauseStatusBefore ||
            m_enumPauseStatus == .GPPauseStatusIng) {
            m_vPauseStartView.isHidden = false
            m_vPauseStartBottomLine.isHidden = false
            m_vPauseEndView.isHidden = false
            m_vPauseEndBottomLine.isHidden = false
            m_consPauseStartViewHeight.constant = 60
            m_consPauseEndViewHeight.constant = 60
            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
            m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
            m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
        }
//        else if (m_enumPauseStatus == .GPPauseStatusIng) {
//            m_vPauseStartView.isHidden = false
//            m_vPauseStartBottomLine.isHidden = false
//            m_vPauseEndView.isHidden = false
//            m_vPauseEndBottomLine.isHidden = false
//            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
//            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
//            m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
//            m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
//        }
        else if (m_enumPauseStatus == .GPPauseStatusAfter) {
            m_vPauseStartView.isHidden = false
            m_vPauseStartBottomLine.isHidden = false
            m_vPauseEndView.isHidden = false
            m_vPauseEndBottomLine.isHidden = false
            m_consPauseStartViewHeight.constant = 60
            m_consPauseEndViewHeight.constant = 60
            m_strPauseStart = (m_objPassData?.m_settingData.m_strSDAY)!
            m_strPauseEnd = (m_objPassData?.m_settingData.m_strEDAY)!
            m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
            m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd.dateFormatter(form: dataDateFormat, to: showDateFormat), false)
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
    private func checkDate(_ start: Date, _ end: Date) -> Bool {
        if (start.compare(end) == ComparisonResult.orderedDescending) {
            return false
        }
        else {
            return true
        }
    }
    private func checkPauseStatus(_ start: String, _ end: String, _ today: String) -> GPPauseStatus {
        //是否申請過暫停扣款
        let dateForm: String = dataDateFormat
        let showDateForm: String = showDateFormat
        if (start == emptyDate && end == emptyDate) {
            return GPPauseStatus.GPPauseStatusNone
        }
        if (start != emptyDate && end == emptyDate) {
            NSLog("===== 起訖日期格式有誤[%@][%@][%@]", start, end, today)
        }
        let startDate: Date? = start.toDate(dateForm)
        let endDate: Date? = end.toDate(dateForm)
        let todayDate: Date? = today.toDate(showDateForm)
        if (startDate == nil || endDate == nil || todayDate == nil) {
            NSLog("===== 日期格式有誤[%@][%@][%@]", start, end, today)
            return GPPauseStatus.GPPauseStatusNone
        }
        if (todayDate?.compare(startDate!) == ComparisonResult.orderedAscending) {//今日在暫停區間前
            return GPPauseStatus.GPPauseStatusBefore
        }
        else if (todayDate?.compare(startDate!) != ComparisonResult.orderedAscending &&
            todayDate?.compare(endDate!) == ComparisonResult.orderedAscending) {//今日在暫停區間中，包含起日
            return GPPauseStatus.GPPauseStatusIng
        }
        else if (todayDate?.compare(endDate!) != ComparisonResult.orderedAscending) {//今日在暫停區間後，包含訖日
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
        switch m_arySettingList[m_iSettingIndex] {
        case changeAmount, changeQuantity:
            data["SETUP"] = "0"
        case pauseDebit:
            data["SETUP"] = "1"
        case resumeDebit:
            data["SETUP"] = "2"
        case stopDebit:
            data["SETUP"] = "3"
        default:
            break
        }
        if (m_uiPauseStartView?.clickBtn.isEnabled == true &&
            m_uiPauseEndView?.clickBtn.isEnabled == true) {
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
        switch m_arySettingList[m_iSettingIndex] {
        case changeAmount, changeQuantity:
            data["SETUP"] = "0"
        case pauseDebit:
            data["SETUP"] = "1"
        case resumeDebit:
            data["SETUP"] = "2"
        case stopDebit:
            data["SETUP"] = "3"
        default:
            break
        }
        if (m_uiPauseStartView?.clickBtn.isEnabled == true &&
            m_uiPauseEndView?.clickBtn.isEnabled == true) {
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
        if (m_uiPauseStartView?.clickBtn.isEnabled == true &&
            m_uiPauseEndView?.clickBtn.isEnabled == true) {
            guard (m_strPauseStart != Choose_Title) else {
                showAlert(title: UIAlert_Default_Title, msg: "請選擇暫停起日", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                return
            }
            guard (m_strPauseEnd != Choose_Title) else {
                showAlert(title: UIAlert_Default_Title, msg: "請選擇暫停訖日", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                return
            }
            guard (self.checkDate(m_strPauseStart.toDate(dataDateFormat)!, m_strPauseEnd.toDate(dataDateFormat)!) == true) else {
                showAlert(title: UIAlert_Default_Title, msg: "暫停起日不得大於暫停訖日", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                return
            }
        }
        if (m_objPassData?.m_settingData.m_strTYPE == GPRegularType.GPRegularTypeSameAmount) {
            let iBuyAmount = Int(m_strBuyAmount)
            guard (iBuyAmount != nil) else {
                showAlert(title: UIAlert_Default_Title, msg: "請輸入投資金額", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                return
            }
            guard (iBuyAmount! > 0) else {
                showAlert(title: UIAlert_Default_Title, msg: "投資金額不得0元", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                return
            }
            guard (iBuyAmount! >= 3000 && iBuyAmount! % 1000 == 0) else {
                showAlert(title: UIAlert_Default_Title, msg: "投資金額最少3000元，每次增加以1000元為倍數", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                return
            }
            enterConfirmView_SameAmount()
        }
        else if (m_objPassData?.m_settingData.m_strTYPE == GPRegularType.GPRegularTypeSameQuantity) {
            let iBuyAmount = Int(m_strBuyAmount)
            guard (iBuyAmount != nil) else {
                showAlert(title: UIAlert_Default_Title, msg: "請輸入投資數量", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                return
            }
            guard (iBuyAmount! > 0) else {
                showAlert(title: UIAlert_Default_Title, msg: "投資數量不得0克", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                return
            }
            guard (iBuyAmount! <= 2999) else {
                showAlert(title: UIAlert_Default_Title, msg: "投資數量最多2999公克，已超過上限", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                return
            }
            enterConfirmView_SameQuantity()
        }
    }

    // MARK:- WebService Methods
    func send_queryData() {
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
                m_wvMemo.loadHTMLString(content, baseURL: nil)
            }
        default: super.didResponse(description, response)
        }
    }

    // MARK:- Handle Actions
    @IBAction func m_btnNextClick(_ sender: Any) {
        let settingType = m_arySettingList[m_iSettingIndex]
        if (m_enumPauseStatus == .GPPauseStatusIng || m_enumPauseStatus == .GPPauseStatusBefore) &&
            (settingType == changeAmount || settingType == changeQuantity || settingType == pauseDebit) {
        self.showAlert(title: UIAlert_Default_Title, msg: "本筆定期投資已設定暫停扣款，請確認是否繼續？", confirmTitle: "是", cancleTitle: "否", completionHandler: { self.enterConfirmView() }, cancelHandelr: {()})
        }
        else {
            self.enterConfirmView()
        }
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
                datePicker.frame = CGRect(origin: .zero, size: view.frame.size)
                let today: Date = (m_objPassData?.m_settingData.m_strDATE.toDate(showDateFormat))!
                var componenetsMin = Calendar.current.dateComponents([.day, .month, .year], from: today)
                componenetsMin.day = componenetsMin.day!+1
                let curDate = InputDatePickerStruct(minDate: Calendar.current.date(from: componenetsMin), maxDate: nil, curDate: Calendar.current.date(from: componenetsMin))
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
                datePicker.frame = CGRect(origin: .zero, size: view.frame.size)
                let today: Date = (m_objPassData?.m_settingData.m_strDATE.toDate(showDateFormat))!
                var componenetsMin = Calendar.current.dateComponents([.day, .month, .year], from: today)
                componenetsMin.day = componenetsMin.day!+1
                let curDate = InputDatePickerStruct(minDate: Calendar.current.date(from: componenetsMin), maxDate: nil, curDate: Calendar.current.date(from: componenetsMin))
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
        let maxLength = m_objPassData?.m_settingData.m_strTYPE == GPRegularType.GPRegularTypeSameAmount ? Max_Amount_Length : Max_GoldGram_Length
        if newLength <= maxLength {
            m_strBuyAmount = newString
            return true
        }
        else {
            return false
        }
    }
}
extension GPRegularChangeViewController : WKNavigationDelegate {
    func webView(_ m_wvMemo: WKWebView, didFinish navigation: WKNavigation!){
        var frame: CGRect = self.m_wvMemo.frame
        frame.size.height = 1
        self.m_wvMemo.frame = frame
        let fittingSize = self.m_wvMemo.sizeThatFits(CGSize(width: 0, height: 0))
        frame.size = fittingSize
        self.m_wvMemo.frame = frame
        m_consMemoHeight.constant = fittingSize.height
    }
}
