//
//  BasicInfoResultViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/11.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class BasicInfoResultViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    private var list:[[String:String]]? = nil
    private var isSuccess = false
    private var titleStatus = ""
    private var memo:String? = nil
    
    // MARK: - Public
    func setInitial(_ list:[[String:String]]?, _ isSuccess:Bool, _ title:String, _ memo:String? = nil) {
        self.list = list
        self.isSuccess = isSuccess
        self.titleStatus = title
        self.memo = memo
    }
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = nil
        navigationItem.setHidesBackButton(true, animated:true)
        // Do any additional setup after loading the view.
        setShadowView(bottomView, .Top)
        tableView.register(UINib(nibName: UIID.UIID_ResultCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultCell.NibName()!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - StoryBoard Touch Event
    @IBAction func clickReturnBtn(_ sender: Any) {
        enterFeatureByID(.FeatureID_Home, false)
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = ResultCell.GetStringHeightByWidthAndFontSize(list?[indexPath.row][Response_Value] ?? "", tableView.frame.size.width)
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return tableView.sectionFooterHeight
        }
        else {
            if memo == nil {
                return 0
            }
            else {
                return MemoView.GetStringHeightByWidthAndFontSize(memo!, tableView.frame.width)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let head = getUIByID(.UIID_ShowMessageHeadView) as! ShowMessageHeadView
            head.titleLabel.text = titleStatus
            head.imageView.image = isSuccess ? UIImage(named: ImageName.CowSuccess.rawValue) : UIImage(named: ImageName.CowFailure.rawValue)
            return head
        }
        else {
            if memo == nil {
                return nil
            }
            else {
                let footer = getUIByID(.UIID_MemoView) as! MemoView
                footer.set(memo!)
                return footer
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }
        else {
            return list?.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell
        cell.set(list?[indexPath.row][Response_Key] ?? "", list?[indexPath.row][Response_Value] ?? "")
        return cell
    }
}
