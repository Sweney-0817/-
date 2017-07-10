//
//  LoanPrincipalInterestViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/7.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let PayLoan_Segue = "GoPayLoan"

class LoanPrincipalInterestViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var loanAmountLabel: UILabel!
    @IBOutlet weak var currentAmountLabel: UILabel!
    @IBOutlet weak var needPayAmountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    private var topDropView:OneRowDropDownView? = nil
    
    // MARK: - Public
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != PayLoan_Segue {
            let detail = segue.destination as! LoanPrincipalInterestDetailViewController
            var list = [[String:String]]()
            list.append(["Key": "放款帳號", "Value":"2017/01/03"])
            list.append(["Key": "目前本金餘額", "Value":"12345678900"])
            list.append(["Key": "預訂交易日", "Value":"1000000"])
            list.append(["Key": "應繳本金", "Value":"1"])
            list.append(["Key": "應繳利息", "Value":"1.12345"])
            list.append(["Key": "應繳諭期息", "Value":"2017/12/02"])
            detail.setList(list)
        }
        else {
            
        }
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: UIID.UIID_LoanPrincipalInterestCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_LoanPrincipalInterestCell.NibName()!)
        setShadowView(middleView!)
        
        topDropView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        topDropView?.setOneRow("放款帳號", "")
        topDropView?.frame = topView.frame
        topDropView?.frame.origin = .zero
        topView.addSubview(topDropView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickMoreBtn(_ sender: Any) {
        
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_LoanPrincipalInterestCell.NibName()!, for: indexPath) as! LoanPrincipalInterestCell
        if indexPath.row == 0 {
            cell.payBtn.isHidden = false
        }
        else {
            cell.payBtn.isHidden = true
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0  {
            performSegue(withIdentifier: PayLoan_Segue, sender: nil)
        }
    }
}
