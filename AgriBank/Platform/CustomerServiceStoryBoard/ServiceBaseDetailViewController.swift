//
//  ServiceBaseDetailViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/10.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class ServiceBaseDetailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var m_tvData: UITableView!
    private var data:ConfirmResultStruct? = nil
    @IBAction func m_btnShowMapClick(_ sender: Any) {
        NSLog("m_btnShowMapClick")
    }
    
    @IBAction func m_btnCallOutClick(_ sender: Any) {
        NSLog("m_btnCallOutClick")
    }
    func setData(_ data:ConfirmResultStruct) {
        self.data = data
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setAllSubView()
    }
    func setAllSubView() {
        setDataTableView()
    }
    func setDataTableView() {
        m_tvData.register(UINib(nibName: UIID.UIID_ResultCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultCell.NibName()!)
        m_tvData.allowsSelection = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = ResultCell.GetStringHeightByWidthAndFontSize((data?.list?[indexPath.row]["Value"]!)!, m_tvData.frame.size.width)
        return height
    }
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (data?.list?.count)!;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell
        cell.set((data?.list?[indexPath.row]["Key"]!)!, (data?.list?[indexPath.row]["Value"]!)!)
        return cell
    }
}
