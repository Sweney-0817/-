//
//  MenuViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/6/2.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let Menu_Cell_Identify = "MenuCellIdentify"

class MenuViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, SideMenuViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var versionLabel: UILabel!
    private var featureList = [PlatformFeatureID]()
    private var expandList = Set<Int>()
    private var currentID:PlatformFeatureID? = nil

    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: UIID.UIID_MenuCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_MenuCell.NibName()!)
        tableView.register(UINib(nibName: UIID.UIID_MenuExpandCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_MenuExpandCell.NibName()!)
        setShadowView(topView)
        versionLabel.text = AgriBank_Version
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let list = AuthorizationManage.manage.GetPlatformList(.Menu_Type) {
            featureList = list
        }
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 1
        if expandList.contains(section) {
            if let list = getAuthFeatureIDContentList(featureList[section]) {
                count += list.count
            }
        }
        
        return count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return featureList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = nil
        let list = getAuthFeatureIDContentList(featureList[indexPath.section])
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_MenuCell.NibName()!, for: indexPath)
            (cell as! MenuCell).nameLabel.text = getFeatureName(featureList[indexPath.section])
            if expandList.contains(indexPath.section) {
                (cell as! MenuCell).directionImage.image = UIImage(named: ImageName.DropUp.rawValue)
            }
            else {
                if list != nil && (list?.count)! > 0 {
                    (cell as! MenuCell).directionImage.image = UIImage(named: ImageName.DropDown.rawValue)
                }
                else {
                    (cell as! MenuCell).directionImage.image = nil
                }
            }
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_MenuExpandCell.NibName()!, for: indexPath)
            (cell as! MenuExpandCell).nameLabel.text = getFeatureName((list?[indexPath.row-1])!)
            (cell as! MenuExpandCell).separatorView.isHidden = (list?.count == indexPath.row)
        }
        
        return cell!
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let info = getFeatureInfoByID(featureList[indexPath.section])
        if info?.contentList != nil {
            if indexPath.row == 0 {
                if expandList.contains(indexPath.section) {
                    expandList.remove(indexPath.section)
                }
                else {
                    expandList.insert(indexPath.section)
                }
                tableView.reloadData()
            }
            else {
                currentID = info?.contentList?[indexPath.row-1]
                if parent is SideMenuViewController {
                    (parent as! SideMenuViewController).ShowSideMenu(true)
                }
            }
        }
        else {
            currentID = featureList[indexPath.section]
            if parent is SideMenuViewController {
                (parent as! SideMenuViewController).ShowSideMenu(true)
            }
        }
    }
    
    // MARK: - SideMenuViewDelegate
    func willShowViewController(center: UIViewController?) {
        if center is BaseViewController {
            if currentID != nil {
                (center as! BaseViewController).enterFeatureByID(currentID!, false)
                currentID = nil
            }
        }
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickHomeBtn(_ sender: Any) {
        if parent is SideMenuViewController {
            currentID = .FeatureID_Home
            (parent as! SideMenuViewController).ShowSideMenu(true)
        }
    }
}
