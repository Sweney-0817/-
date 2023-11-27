//
//  ResultViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/6/12.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class ResultViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var m_tvData: UITableView!
    @IBOutlet weak var m_vBottomView: UIView!
    @IBOutlet weak var m_btnBackToFeature: UIButton!
    @IBOutlet weak var m_btnBackToHome: UIButton!
    private var data:ConfirmResultStruct? = nil
    private var barTitle:String? = nil
    private var bIsMobileTransfer: Bool = false
  
    
    // MARK: - Public
    func setData(_ data:ConfirmResultStruct, _ barTitle:String? = nil, isMobileTransfer: Bool = false) {
        self.data = data
        self.barTitle = barTitle
        self.bIsMobileTransfer = isMobileTransfer
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func m_btnBackToFeatureClick(_ sender: Any) {
        enterFeatureByID(getCurrentFeatureID(), false)
    }
    
    @IBAction func m_btnBackToHomeClick(_ sender: Any) {
        enterFeatureByID(.FeatureID_Home, true)
    }
    
    @IBAction func m_btnShareMsg(_ sender: Any) {
                let currnetDate = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = NSTimeZone.init(abbreviation:"UTC")! as TimeZone
                dateFormatter.dateFormat = "yyyy/MM/dd "
                var TrxDateTime = dateFormatter.string(from: currnetDate)//交易日期
        var act5:String = (data?.list?[2][Response_Value] as? String ?? "")!
        act5 = act5.substring(from: 11, length: 5)
        
        var strAmount = (data?.list?[5][Response_Value] as? String ?? "")
        if bIsMobileTransfer {
            /**「手機門號即時轉帳」結果頁特殊處理*/
            strAmount = (data?.list?[7][Response_Value] as? String ?? "")
        }
        var txtMSg = "我已用農漁行動達人轉新台幣＄" + strAmount
        txtMSg = txtMSg + "元給您！\n時間：" + TrxDateTime
        txtMSg = txtMSg + (data?.list?[0][Response_Value] as? String ?? "")!
        txtMSg = txtMSg + "\n銀行代號：" + (data?.list?[1][Response_Value] as? String ?? "")!
        txtMSg = txtMSg + "\n帳號末五碼：" + act5
        
        let activityViewController = UIActivityViewController(activityItems: [txtMSg], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = nil
        navigationItem.setHidesBackButton(true, animated:true)
    
        m_tvData.register(UINib(nibName: UIID.UIID_ResultCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultCell.NibName()!)
        m_tvData.allowsSelection = false
        m_tvData.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        m_btnBackToFeature.setTitle(data?.resultBtnName, for: .normal)
        
        setShadowView(m_vBottomView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /* 「即時轉帳」結果頁，沿用確認頁的Title */
        if barTitle != nil {
            navigationController?.navigationBar.topItem?.title = barTitle
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = ResultCell.GetStringHeightByWidthAndFontSize((data?.list?[indexPath.row][Response_Value] as? String ?? "")!, m_tvData.frame.size.width)
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return tableView.sectionFooterHeight
        }
        else if section == 2 {
            if (data?.memo)!.isEmpty {
                return 0
            }
            else {
                return MemoView.GetStringHeightByWidthAndFontSize((data?.memo)!, m_tvData.frame.width)
            }
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let head = getUIByID(.UIID_ShowMessageHeadView) as! ShowMessageHeadView
            head.imageView.image = UIImage(named: (data?.image)!)
            head.titleLabel.text = data?.title
            return head
        }
//        else {
//            if (data?.memo)!.isEmpty {
//                return nil
//            }
//            else {
//                let footer = getUIByID(.UIID_MemoView) as! MemoView
//                footer.set((data?.memo)!)
//                return footer
//            }
//        }
        else if section == 2 {
            let footer = getUIByID(.UIID_MemoView) as! MemoView
            footer.set((data?.memo)!)
            return footer
        }
        else {
            return nil
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            if data?.list?.count != nil {
                return (data?.list?.count)!
            }
            return 0
        }
        else {
            return 0
        }
//        if section == 0 {
//            return 0
//        }
//        else {
//            if data?.list?.count != nil {
//                return (data?.list?.count)!
//            }
//
//            return 0
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell
        cell.set((data?.list?[indexPath.row][Response_Key] as? String ?? "")!, (data?.list?[indexPath.row][Response_Value] as? String ?? "")!)
       
        return cell
    }
}
