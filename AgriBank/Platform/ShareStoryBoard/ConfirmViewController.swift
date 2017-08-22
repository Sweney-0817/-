//
//  ConfirmViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/6/15.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let ConfirmView_ImageConfirm_Cell_Height:CGFloat = 60
let Confirm_Segue = "GoResult"

class ConfirmViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, ImageConfirmViewDelegate {
    @IBOutlet weak var m_ivTopImage: UIImageView!
    @IBOutlet weak var m_lbTopTitle: UILabel!
    @IBOutlet weak var m_tvData: UITableView!
    @IBOutlet weak var m_vBottomView: UIView!
    @IBOutlet weak var m_btnConfirm: UIButton!
    private var data:ConfirmResultStruct? = nil
    private var password = ""
    private var imageConfirmView:ImageConfirmView? = nil
    private var checkRequest:RequestStruct? = nil
    
    // MARK: - Public
    func setData(_ data:ConfirmResultStruct) {
        self.data = data
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let controller = segue.destination as! ResultViewController
        controller.setData(data!)
    }
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        m_ivTopImage.image = UIImage(named: (data?.image)!)
        m_lbTopTitle.text = data?.title
        
        imageConfirmView = getUIByID(.UIID_ImageConfirmView) as? ImageConfirmView
        imageConfirmView?.delegate = self
        imageConfirmView?.m_vSeparator.isHidden = false
        
        m_tvData.register(UINib(nibName: UIID.UIID_ResultCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultCell.NibName()!)
        m_tvData.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: SystemCell_Identify)
        m_tvData.allowsSelection = false
        m_tvData.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        m_btnConfirm.setTitle(data?.confirmBtnName, for: .normal)
        setShadowView(m_vBottomView)
        AddObserverToKeyBoard()
        
        getImageConfirm(transactionId)
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
            let height = ResultCell.GetStringHeightByWidthAndFontSize((data?.list?[indexPath.row][Response_Value]!)!, m_tvData.frame.size.width)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: SystemCell_Identify, for: indexPath)
            imageConfirmView?.frame = CGRect(x:0, y:0, width:cell.contentView.frame.width, height:cell.contentView.frame.height)
            cell.contentView.addSubview(imageConfirmView!)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell
            cell.set((data?.list?[indexPath.row][Response_Key]!)!, (data?.list?[indexPath.row][Response_Value]!)!)
            return cell
        }
    }
    
    // MARK: - ImageConfirmCellDelegate
    func clickRefreshBtn() {
        getImageConfirm(transactionId)
    }
    
    func changeInputTextfield(_ input: String) {
        password = input
    }
    
    func ImageConfirmTextfieldBeginEditing(_ textfield:UITextField) {}
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickCheckBtn(_ sender: Any) {
        checkImageConfirm(password, transactionId)
    }
    
    // MARK: - ConnectionUtilityDelegate
    override func didRecvdResponse(_ description:String, _ response: NSDictionary) {
        setLoading(false)
        switch description {
        case "COMM0501":
            if let responseImage = response[RESPONSE_IMAGE_KEY] as? UIImage {
                imageConfirmView?.m_ivShow.image = responseImage
            }
            
        case "COMM0502":
            if let flag = response[RESPONSE_IMAGE_CONFIRM_RESULT_KEY] as? String, flag == ImageConfirm_Success {
                if data?.checkRequest != nil {
                    setLoading(true)
                    postRequest((data?.checkRequest?.strMethod)!, (data?.checkRequest?.strSessionDescription)!, data?.checkRequest?.httpBody, data?.checkRequest?.loginHttpHead, data?.checkRequest?.strURL, (data?.checkRequest?.needCertificate)!, (data?.checkRequest?.isImage)!)
                }
            }
            else {
                showErrorMessage(ErrorMsg_Image_ConfirmFaild, nil)
            }

        default:
            if data?.checkRequest != nil && description == (data?.checkRequest?.strSessionDescription)! {
                if let responseData = response.object(forKey: "Data") as? [[String:String]] {
                    data?.list = responseData
                }
                else {
                    data?.list?.removeAll()
                }
                if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode == ReturnCode_Success {
                    data?.title = Transaction_Successful_Title
                    data?.image = ImageName.CowSuccess.rawValue
                }
                else {
                    data?.title = Transaction_Faild_Title
                    data?.image = ImageName.CowFailure.rawValue
                }
                performSegue(withIdentifier: Confirm_Segue, sender: nil)
            }
        }
    }
}
