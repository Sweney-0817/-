//
//  ReservationTransferDetailViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/4.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let ReservationTransferDetailTitle = "預約轉帳明細"

class ReservationTransferDetailViewController: BaseViewController, UITableViewDataSource {
    private var list:[[String:String]]? = nil
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Public
    func setList(_ list:[[String:String]]) {
        self.list = list
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: UIID.UIID_ResultCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultCell.NibName()!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.topItem?.title = ReservationTransferDetailTitle
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell
        cell.set((list?[indexPath.row]["Key"])!, (list?[indexPath.row]["Value"])!)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickCancelBtn(_ sender: Any) {
        var data = ConfirmResultStruct(ImageName.CowCheck.rawValue, "請確認本次交易資訊", [[String:String]](), nil, "確認取消", "繼續交易")
        data.list!.append(["Key": "轉出帳號", "Value":"12345678901234"])
        data.list!.append(["Key": "預約轉帳日", "Value":"固定每月30日"])
        data.list!.append(["Key": "銀行代碼", "Value":"008"])
        data.list!.append(["Key": "轉入帳號", "Value":"12345678901235"])
        data.list!.append(["Key": "轉帳金額", "Value":"9,999,999.00"])
        data.list!.append(["Key": "備註/交易備註", "Value":"備註"])
        enterConfirmResultController(true, data, true)
    }
}
