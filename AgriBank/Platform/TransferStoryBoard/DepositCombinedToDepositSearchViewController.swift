//
//  DepositCombinedToDepositSearchViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/6.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let DepositCombinedToDepositSearch_Segue = "GoDepositDetail"

class DepositCombinedToDepositSearchViewController: BaseViewController, ThreeRowDropDownViewDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tableView: UITableView!
    private var topDropView:ThreeRowDropDownView? = nil
    
    // MARK: - Public
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detail = segue.destination as! DepositCombinedDetailViewController
        var list = [[String:String]]()
        list.append(["Key": "起存日", "Value":"2017/01/03"])
        list.append(["Key": "定存帳號", "Value":"12345678900"])
        list.append(["Key": "定存金額", "Value":"1000000"])
        list.append(["Key": "存單期別(月)", "Value":"1"])
        list.append(["Key": "開戶利率", "Value":"1.12345"])
        list.append(["Key": "到期日", "Value":"2017/12/02"])
        detail.setList(list)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        topDropView = getUIByID(.UIID_ThreeRowDropDownView) as? ThreeRowDropDownView
        topDropView?.setThreeRow("活存帳號", "", "存單總額", "", "轉存筆數", "")
        topDropView?.frame = topView.frame
        topDropView?.frame.origin = .zero
        topView.addSubview(topDropView!)
        setShadowView(topView)
        
        tableView.register(UINib(nibName: UIID.UIID_OverviewCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_OverviewCell.NibName()!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ThreeRowDropDownViewDelegate
    func clickThreeRowDropDownView(_ sender: ThreeRowDropDownView) {
        
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: DepositCombinedToDepositSearch_Segue, sender: nil)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_OverviewCell.NibName()!, for: indexPath) as! OverviewCell
        cell.title1Label.text = "定存帳號"
        cell.title2Label.text = "定存金額"
        cell.title3Label.text = "到期日"
        return cell
    }
}
