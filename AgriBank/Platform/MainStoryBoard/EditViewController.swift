//
//  EditViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/6/7.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let EditView_Title = "首頁功能捷徑新增/編輯"

class EditViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    @IBOutlet weak var tableBottomCons: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    private var showList = [PlatformFeatureID]()
    private var firstPage = false
    private var navigationBarTitle:String? = nil
    var addList = [PlatformFeatureID]()
    
    // MARK: Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: UIID.UIID_EditCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_EditCell.NibName()!)
        tableView.reloadData()
        if !firstPage {
            tableBottomCons.constant = 0
            navigationController?.delegate = self
            let lButton = UIButton(type: .custom)
            lButton.frame = CGRect(x: 0, y: 0, width: BarItem_Height_Weight, height: BarItem_Height_Weight)
            lButton.addTarget(self, action: #selector(clickBackBarItem), for: .touchUpInside)
            lButton.setImage(UIImage(named: ImageName.BackBarItem.rawValue), for: .normal)
            lButton.setImage(UIImage(named: ImageName.BackBarItem.rawValue), for: .highlighted)
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: lButton)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.topItem?.title = firstPage ? EditView_Title : navigationBarTitle
    }
    
    // MARK: - Public
    func setInitial(_ isFirst:Bool, setShowList show:[PlatformFeatureID], setAddList add:[PlatformFeatureID], SetTitle title:String? = nil) {
        firstPage = isFirst
        showList.append(contentsOf: show)
        addList.append(contentsOf: add)
        navigationBarTitle = title
    }
    
    // MARK: - Private
    private func getCountByID(_ ID:PlatformFeatureID) -> Int {
        var count = 0
        if let authList = getAuthFeatureIDContentList(ID) {
            for i in authList {
                if addList.index(of: i) != nil {
                    count += 1
                }
            }
        }
        
        return count
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_EditCell.NibName()!, for: indexPath) as! EditCell
        cell.nameLabel.text = getFeatureName(showList[indexPath.row])
        if let info = getFeatureInfoByID(showList[indexPath.row]) {
            switch info.type {
            case .Head_Next_Type:
                cell.entryImage.image = UIImage(named: ImageName.EntryRight.rawValue)
                cell.countLabel.text = "已選取(\(getCountByID(showList[indexPath.row])))"
                cell.entryImage.layer.cornerRadius = 0
                cell.entryImage.layer.masksToBounds = false
                cell.entryImage.layer.borderColor = nil
                cell.entryImage.layer.borderWidth = 0
                cell.entryImage.backgroundColor = .clear
            case .Select_Type:
                cell.entryImage.image = nil
                cell.countLabel.text = ""
                cell.entryImage.layer.cornerRadius = (cell.entryImage?.frame.width)!/2
                cell.entryImage.layer.masksToBounds = true
                cell.entryImage.layer.borderColor = Green_Color.cgColor
                cell.entryImage.layer.borderWidth = 1
                if let i = addList.index(of: showList[indexPath.row]) {
                    cell.orderLabel.text = String(i+1)
                    cell.entryImage.backgroundColor = Green_Color
                }
                else {
                    cell.orderLabel.text = ""
                    cell.entryImage.backgroundColor = .white
                }
            default:
                break
            }

        }
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let info = getFeatureInfoByID(showList[indexPath.row]) {
            switch info.type {
            case .Head_Next_Type:
                if let list = getAuthFeatureIDContentList(showList[indexPath.row]) {
                    let controller = getControllerByID(.FeatureID_Edit) as! EditViewController
                    controller.setInitial(false, setShowList: list, setAddList: addList, SetTitle: getFeatureName(showList[indexPath.row]))
                    navigationController?.pushViewController(controller, animated: true)
                }
            case .Select_Type:
                if let i = addList.index(of: showList[indexPath.row]) {
                    addList.remove(at: i)
                }
                else {
                    addList.append(showList[indexPath.row])
                }
                tableView.reloadData()
            default:
                break
            }
        }
    }
    
    // MARK: - UINavigationControllerDelegate
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is EditViewController {
            (viewController as! EditViewController).addList = addList
            (viewController as! EditViewController).tableView.reloadData()
        }
    }
    
    // MARK: - StotyBoard Touch Event
    @IBAction func clickConfirmBtn(_ sender: Any) {
        AuthorizationManage.manage.SaveIDListInFile(addList)
        enterFeatureByID(.FeatureID_Home, true)
    }
    
    @IBAction func clickCancelBtn(_ sender: Any) {
        enterFeatureByID(.FeatureID_Home, true)
    }
}
