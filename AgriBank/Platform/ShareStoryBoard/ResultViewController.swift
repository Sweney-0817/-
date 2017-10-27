//
//  ResultViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/6/12.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class ResultViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var m_tvData: UITableView!
    @IBOutlet weak var m_vBottomView: UIView!
    @IBOutlet weak var m_btnBackToFeature: UIButton!
    @IBOutlet weak var m_btnBackToHome: UIButton!
    private var data:ConfirmResultStruct? = nil
    
    // MARK: - Public
    func setData(_ data:ConfirmResultStruct) {
        self.data = data
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func m_btnBackToFeatureClick(_ sender: Any) {
        enterFeatureByID(getCurrentFeatureID(), false)
    }
    
    @IBAction func m_btnBackToHomeClick(_ sender: Any) {
        enterFeatureByID(.FeatureID_Home, true)
    }
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = nil
        navigationItem.setHidesBackButton(true, animated:true)
    
        m_tvData.register(UINib(nibName: UIID.UIID_ResultCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultCell.NibName()!)
        m_tvData.allowsSelection = false
        m_tvData.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        m_btnBackToFeature.setTitle(data?.resultBtnName, for: .normal)
        
        setShadowView(m_vBottomView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = ResultCell.GetStringHeightByWidthAndFontSize((data?.list?[indexPath.row][Response_Value]!)!, m_tvData.frame.size.width)
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return tableView.sectionFooterHeight
        }
        else {
            if (data?.memo)!.isEmpty {
                return 0
            }
            else {
                return MemoView.GetStringHeightByWidthAndFontSize((data?.memo)!, m_tvData.frame.width)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let head = getUIByID(.UIID_ShowMessageHeadView) as! ShowMessageHeadView
            head.imageView.image = UIImage(named: (data?.image)!)
            head.titleLabel.text = data?.title
            return head
        }
        else {
            if (data?.memo)!.isEmpty {
                return nil
            }
            else {
                let footer = getUIByID(.UIID_MemoView) as! MemoView
                footer.set((data?.memo)!)
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
            if data?.list?.count != nil {
                return (data?.list?.count)!
            }
            
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell
        cell.set((data?.list?[indexPath.row][Response_Key]!)!, (data?.list?[indexPath.row][Response_Value]!)!)
        return cell
    }
}
