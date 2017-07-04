//
//  DeviceCheckViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/4.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class DeviceCheckViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var m_tvData: UITableView!
    @IBOutlet weak var m_vBottomView: UIView!
    private var data:[[String:String]] = [[String:String]]()
    
    // MARK: - StoryBoard Touch Event
    @IBAction func m_btnDeviceCheck(_ sender: Any) {
        let data = ConfirmResultStruct(ImageName.CowCheck.rawValue, "請確認本次交易資訊", self.data, nil, "確認送出", "繼續交易")
//        data.list!.append(["Key": "交易時間", "Value":"2017/05/05 11:13:53"])
//        data.list!.append(["Key": "掛失日期", "Value":"2017/05/05"])
        enterConfirmResultController(true, data, true)
    }
    
    @IBAction func m_btnCancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func setData(_ data:[[String:String]]) {
        self.data = data
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        m_tvData.register(UINib(nibName: UIID.UIID_ResultCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultCell.NibName()!)
        m_tvData.allowsSelection = false
        m_tvData.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)

        setShadowView(m_vBottomView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = ResultCell.GetStringHeightByWidthAndFontSize((data[indexPath.row]["Value"]!), m_tvData.frame.size.width)
        return height
    }
    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        if (data?.memo)!.isEmpty {
//            return 0
//        }
//        else {
//            return MemoView.GetStringHeightByWidthAndFontSize((data?.memo)!, m_tvData.frame.width)
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        if (data?.memo)!.isEmpty {
//            return nil
//        }
//        else {
//            let footer = getUIByID(.UIID_MemoView) as! MemoView
//            footer.set((data?.memo)!)
//            return footer
//        }
//    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (data.count);
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell
        cell.set((data[indexPath.row]["Key"]!), (data[indexPath.row]["Value"]!))
        return cell
    }

}
