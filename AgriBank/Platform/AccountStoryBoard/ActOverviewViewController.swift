//
//  ActOverviewViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/6/15.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let ActOverviewView_SectionAll_Height = CGFloat(48)
let ActOverviewView_Section_Height = CGFloat(20)

class ActOverviewViewController: BaseViewController, ChooseTypeDelegate, UITableViewDataSource, UITableViewDelegate, OverviewCellDelegate {
    @IBOutlet weak var chooseTypeView: ChooseTypeView!
    @IBOutlet weak var tableView: UITableView!
    private var actList:[String:[String]]? = nil
    private var typeList:[String]? = nil
    private let cellTitleList = ["帳號","幣別","帳戶餘額"]
    private let categoryList:[String:[String]]? = nil
    private var currentType:Int = 0
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        typeList = ["全部","活期存款","支票存款","定期存款","放款存款"]
        chooseTypeView.setTypeList(typeList, setDelegate: self)
        tableView.register(UINib(nibName: UIID.UIID_OverviewCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_OverviewCell.NibName()!)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - ConnectionUtilityDelegate
    override func didRecvdResponse(_ description:String, _ response: [String:Any]) {
        
    }
    
    // MARK: - ChooseTypeDelegate
    func clickChooseTypeBtn(_ name:String) {
        currentType = (typeList?.index(of: name))!
        if currentType == 0 {
            tableView.sectionHeaderHeight = ActOverviewView_SectionAll_Height
        }
        else {
            tableView.sectionHeaderHeight = ActOverviewView_Section_Height
        }
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        if typeList != nil {
            if currentType == 0 {
                return (typeList?.count)!
            }
            else {
                return 1
            }
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = categoryList?[(typeList?[section])!] {
            return list.count
        }
        else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_OverviewCell.NibName()!, for: indexPath) as! OverviewCell
        cell.AddExpnadBtn(self)
        cell.title1Label.text = cellTitleList[0]
        cell.title2Label.text = cellTitleList[1]
        cell.title3Label.text = cellTitleList[2]
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var secView:TypeSection? = nil
        if currentType == 0 {
            secView = getUIByID(.UIID_TypeSection) as? TypeSection
            secView?.titleLabel.text = typeList?[section]
        }
        return secView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ShowDetail_Segue_Identify, sender: nil)
    }
    
    // MARK: - OverviewCellDelegate
    func clickTransBtn() {
        
    }
    
    func clickDetailBtn() {
        enterFeatureByID(.FeatureID_AccountDetailView, false)
    }
}
