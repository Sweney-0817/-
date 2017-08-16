//
//  ReservationTransferSearchCancelViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/3.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let ReservationTransferSearchCancel_Segue = "GoReservationDetail"

class ReservationTransferSearchCancelViewController: BaseViewController, OneRowDropDownViewDelegate, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var specificDateBtn: UIButton!
    @IBOutlet weak var fixedDateBtn: UIButton!
    @IBOutlet weak var chooseAccountView: UIView!
    @IBOutlet weak var loginIntervalView: UIView!
    @IBOutlet weak var tableView: UITableView!
    private var chooseAccountDorpView:OneRowDropDownView? = nil
    private var loginIntervalDropView:OneRowDropDownView? = nil
    
    // MARK: - Public
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detail = segue.destination as! ReservationTransferDetailViewController
        var list = [[String:String]]()
        list.append(["Key": "登入日期", "Value":"2017/01/03"])
        list.append(["Key": "預約轉帳日", "Value":"2017/02/01"])
        list.append(["Key": "銀行代碼", "Value":"008"])
        list.append(["Key": "轉入帳號", "Value":"1234567890"])
        list.append(["Key": "金額", "Value":"9999999999"])
        list.append(["Key": "交易備記", "Value":"-"])
        list.append(["Key": "處理結果", "Value":"-"])
        detail.setList(list)
    }
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        chooseAccountDorpView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        chooseAccountDorpView?.setOneRow("轉出帳號", "")
        chooseAccountDorpView?.frame = chooseAccountView.frame
        chooseAccountDorpView?.frame.origin = .zero
        chooseAccountView.addSubview(chooseAccountDorpView!)
        
        loginIntervalDropView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        loginIntervalDropView?.setOneRow("登入區間", "")
        loginIntervalDropView?.frame = loginIntervalView.frame
        loginIntervalDropView?.frame.origin = .zero
        loginIntervalView.addSubview(loginIntervalDropView!)
        setShadowView(loginIntervalView)
        
        tableView.register(UINib(nibName: UIID.UIID_OverviewCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_OverviewCell.NibName()!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickSpecificDateBtn(_ sender: Any) {
        specificDateBtn.setTitleColor(.white, for: .normal)
        specificDateBtn.backgroundColor = Green_Color
        fixedDateBtn.setTitleColor(.black, for: .normal)
        fixedDateBtn.backgroundColor = .white
    }
    
    @IBAction func ClickFixedDateBtn(_ sender: Any) {
        fixedDateBtn.setTitleColor(.white, for: .normal)
        fixedDateBtn.backgroundColor = Green_Color
        specificDateBtn.setTitleColor(.black, for: .normal)
        specificDateBtn.backgroundColor = .white
    }
    
    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_OverviewCell.NibName()!, for: indexPath) as! OverviewCell
        cell.title1Label.text = "登入日期"
        cell.title2Label.text = "轉入帳號"
        cell.title3Label.text = "金額"
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ReservationTransferSearchCancel_Segue, sender: nil)
    }
}
