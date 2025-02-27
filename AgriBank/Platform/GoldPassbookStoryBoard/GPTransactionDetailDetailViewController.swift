//
//  GPTransactionDetailDetailViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/8/16.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit

let TransactionDetailDetail_CellTitle = ["交易時間", "交易序號", "更正記號", "借貸", "交易量", "單價", "餘額(克)","損益率","平均牌告單價"]

class GPTransactionDetailDetailViewController: BaseViewController {
    @IBOutlet var m_tvContentView: UITableView!
    var m_objDetailData: GPTransactionDetailData? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initTableView()
        m_tvContentView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    private func initTableView() {
        m_tvContentView.delegate = self
        m_tvContentView.dataSource = self
        m_tvContentView.allowsSelection = false
        m_tvContentView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        m_tvContentView.register(UINib(nibName: UIID.UIID_ResultCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultCell.NibName()!)
    }
    func setData(_ data: GPTransactionDetailData) {
        m_objDetailData = data
    }
}
extension GPTransactionDetailDetailViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TransactionDetailDetail_CellTitle.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell

        var strTitle: String = TransactionDetailDetail_CellTitle[indexPath.row]
        var strValue: String = ""
        switch indexPath.row {
        case 0:
            let strTime: String = (m_objDetailData?.TXTIME)!.dateFormatter(form: "HHmm", to: "HH:mm")
            strValue = String(format: "%@ %@", (m_objDetailData?.TXDAY)!, strTime)
        case 1:
            strValue = (m_objDetailData?.SEQ)!
        case 2:
            strValue = m_objDetailData?.HCODE == "0" ? "-" : "更"
        case 3:
            strValue = m_objDetailData?.CRDB == "1" ? "賣出" : "買進"
        case 4:
            strTitle = m_objDetailData?.CRDB == "1" ? "賣出量(克)" : "買進量(克)"
            strValue = (m_objDetailData?.TXQTY)!.separatorThousandDecimal()
        case 5:
            strValue = (m_objDetailData?.VALUE)!.separatorThousand()
        case 6:
            strValue = (m_objDetailData?.AVBAL)!.separatorThousandDecimal()
        case 7:
            strValue = (m_objDetailData?.PFRATIO)! + "%"
        case 8:
            strValue = (m_objDetailData?.DAVGCOST)!.separatorThousandDecimal()
        default:
            strValue = ""
        }
        cell.set(strTitle, strValue)
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
