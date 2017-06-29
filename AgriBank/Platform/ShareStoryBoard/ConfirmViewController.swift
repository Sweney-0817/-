//
//  ConfirmViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/6/15.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let ConfirmView_ImageConfirm_Cell_Height:CGFloat = 60

class ConfirmViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, ImageConfirmCellDelegate {
    @IBOutlet weak var m_ivTopImage: UIImageView!
    @IBOutlet weak var m_lbTopTitle: UILabel!
    @IBOutlet weak var m_tvData: UITableView!
    @IBOutlet weak var m_vBottomView: UIView!
    @IBOutlet weak var m_btnConfirm: UIButton!
    private var data:ConfirmResultStruct? = nil
    
    func setData(_ data:ConfirmResultStruct) {
        self.data = data
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let resultController = segue.destination as! ResultViewController
        let data = ConfirmResultStruct.init(ImageName.CowCheck.rawValue, "交易成功", self.data?.list, nil, nil, "繼續交易")
        resultController.setData(data)
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        m_ivTopImage.image = UIImage(named: (data?.image)!)
        m_lbTopTitle.text = data?.title
        
        m_tvData.register(UINib(nibName: UIID.UIID_ResultCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultCell.NibName()!)
        m_tvData.register(UINib(nibName: UIID.UIID_ImageConfirmCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ImageConfirmCell.NibName()!)
        m_tvData.allowsSelection = false
        m_tvData.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        m_btnConfirm.setTitle(data?.confirmBtnName, for: .normal)
        setShadowView(m_vBottomView)
        AddObserverToKeyBoard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == data?.list?.count) {
            return ConfirmView_ImageConfirm_Cell_Height
        }
        else {
            let height = ResultCell.GetStringHeightByWidthAndFontSize((data?.list?[indexPath.row]["Value"]!)!, m_tvData.frame.size.width)
            return height
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (data?.memo)!.isEmpty {
            return 0
        }
        else {
            return MemoView.GetStringHeightByWidthAndFontSize((data?.memo)!, m_tvData.frame.width)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if (data?.memo)!.isEmpty {
            return nil
        }
        else {
            let footer = getUIByID(.UIID_MemoView) as! MemoView
            footer.set((data?.memo)!)
            return footer
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (data?.list?.count)!+1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == (data?.list?.count)!) {
            let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ImageConfirmCell.NibName()!, for: indexPath) as! ImageConfirmCell
            cell.delegate = self
//            cell.set(m_arrData[indexPath.row]["Key"]!, m_arrData[indexPath.row]["Value"]!)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell
            cell.set((data?.list?[indexPath.row]["Key"]!)!, (data?.list?[indexPath.row]["Value"]!)!)
            return cell
        }
    }
    
    // MARK: - ImageConfirmCellDelegate
    func clickRefreshBtn() {
    }
    
    func changeInputTextfield(_ input: String) {
    }
}
