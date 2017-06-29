//
//  ResultViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/6/12.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class ResultViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    private var m_arrData = [[String:String]]()
    private var m_strTitle = ""
    private var m_strImage = ""
    private var m_strMemo = ""
    @IBOutlet weak var m_ivTopImage: UIImageView!
    @IBOutlet weak var m_lbTopTitle: UILabel!
    @IBOutlet weak var m_tvData: UITableView!
    @IBOutlet weak var m_vBottomView: UIView!
    @IBOutlet weak var m_btnBackToFeature: UIButton!
    @IBOutlet weak var m_btnBackToHome: UIButton!
    
    func setData(_ data:ConfirmResultStruct) {
        m_strTitle = data.title
        m_strImage = data.image
        m_strMemo = data.memo
        if data.list != nil {
            m_arrData = data.list!
        }
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func m_btnBackToFeatureClick(_ sender: Any) {
        enterFeatureByID(getCurrentFeatureID(), false)
    }
    
    @IBAction func m_btnBackToHomeClick(_ sender: Any) {
        enterFeatureByID(.FeatureID_Home, true)
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = nil
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        m_ivTopImage.image = UIImage(named: m_strImage)
        m_lbTopTitle.text = m_strTitle

        m_tvData.register(UINib(nibName: UIID.UIID_ResultCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultCell.NibName()!)
        m_tvData.allowsSelection = false
        m_tvData.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        setShadowView(m_vBottomView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = ResultCell.GetStringHeightByWidthAndFontSize(m_arrData[indexPath.row]["Value"]!, m_tvData.frame.size.width)
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if m_strMemo.isEmpty {
            return 0
        }
        else {
            return MemoView.GetStringHeightByWidthAndFontSize(m_strMemo, m_tvData.frame.width)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if m_strMemo.isEmpty {
            return nil
        }
        else {
            let footer = getUIByID(.UIID_MemoView) as! MemoView
            footer.set(m_strMemo)
            return footer
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_arrData.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell
        cell.set(m_arrData[indexPath.row]["Key"]!, m_arrData[indexPath.row]["Value"]!)
        return cell
    }
}
