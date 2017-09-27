//
//  ConfirmViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/6/15.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let Confirm_ImageConfirm_Cell_Height:CGFloat = 60
let Confirm_Segue = "GoResult"

class ConfirmViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, ImageConfirmViewDelegate {
    @IBOutlet weak var m_ivTopImage: UIImageView!
    @IBOutlet weak var m_lbTopTitle: UILabel!
    @IBOutlet weak var m_tvData: UITableView!
    @IBOutlet weak var m_vBottomView: UIView!
    @IBOutlet weak var m_btnConfirm: UIButton!
    private var data:ConfirmResultStruct? = nil
    private var dataOTP:ConfirmOTPStruct? = nil
    private var password = ""
    private var imageConfirmView:ImageConfirmView? = nil
    private var checkRequest:RequestStruct? = nil
    private var curTextfield:UITextField? = nil
    private var isNeedOTP = false
    
    // MARK: - Public
    func setData(_ data:ConfirmResultStruct) {
        self.data = data
    }
    
    func setDataNeedOTP(_ dataOTP:ConfirmOTPStruct) {
        self.dataOTP = dataOTP
        isNeedOTP = true
    }
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isNeedOTP {
            m_ivTopImage.image = UIImage(named: dataOTP?.image ?? "")
            m_lbTopTitle.text = dataOTP?.title
            m_btnConfirm.setTitle(dataOTP?.confirmBtnName, for: .normal)
        }
        else {
            m_ivTopImage.image = UIImage(named: data?.image ?? "")
            m_lbTopTitle.text = data?.title
            m_btnConfirm.setTitle(data?.confirmBtnName, for: .normal)
        }
        
        imageConfirmView = getUIByID(.UIID_ImageConfirmView) as? ImageConfirmView
        imageConfirmView?.delegate = self
        imageConfirmView?.m_vSeparator.isHidden = false
        
        m_tvData.register(UINib(nibName: UIID.UIID_ResultCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultCell.NibName()!)
        m_tvData.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: SystemCell_Identify)
        m_tvData.allowsSelection = false
        m_tvData.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        setShadowView(m_vBottomView)
        addObserverToKeyBoard()
        addGestureForKeyBoard()
        
        getImageConfirm(transactionId)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case "COMM0501":
            if let responseImage = response[RESPONSE_IMAGE_KEY] as? UIImage {
                imageConfirmView?.m_ivShow.image = responseImage
            }
            
        case "COMM0502":
            if let flag = response[RESPONSE_IMAGE_CONFIRM_RESULT_KEY] as? String, flag == ImageConfirm_Success {
                if !isNeedOTP {
                    if data?.checkRequest != nil {
                        setLoading(true)
                        postRequest((data?.checkRequest?.strMethod)!, (data?.checkRequest?.strSessionDescription)!, data?.checkRequest?.httpBody, data?.checkRequest?.loginHttpHead, data?.checkRequest?.strURL, (data?.checkRequest?.needCertificate)!, (data?.checkRequest?.isImage)!)
                    }
                }
                else {
                    VaktenManager.sharedInstance().signTaskOperation(with: dataOTP?.task) { resultCode in
                        if VIsSuccessful(resultCode) {
                            let otp = VaktenManager.sharedInstance().generateGeoOTPCode()
                            if VIsSuccessful((otp?.resultCode)!) {
                                self.dataOTP?.httpBodyList?["otp"] = otp?.otp
                                self.dataOTP?.checkRequest?.httpBody = AuthorizationManage.manage.converInputToHttpBody((self.dataOTP?.httpBodyList!)!, true)
                                self.setLoading(true)
                                self.postRequest((self.dataOTP?.checkRequest?.strMethod)!, (self.dataOTP?.checkRequest?.strSessionDescription)!, self.dataOTP?.checkRequest?.httpBody, self.dataOTP?.checkRequest?.loginHttpHead, self.dataOTP?.checkRequest?.strURL, (self.data?.checkRequest?.needCertificate)!, (self.dataOTP?.checkRequest?.isImage)!)
                            }
                            else {
                                self.showErrorMessage(nil, "\(ErrorMsg_GenerateOTP_Faild) \((otp?.resultCode)!)")
                            }
                        }
                        else {
                            self.showErrorMessage(nil, "\(ErrorMsg_SignTask_Faild) \(resultCode)")
                        }
                    }
                }
            }
            else {
                showErrorMessage(nil, ErrorMsg_Image_ConfirmFaild)
                getImageConfirm(transactionId)
            }
            
        default:
            let checkRequest = isNeedOTP ? dataOTP?.checkRequest : data?.checkRequest
            if checkRequest != nil && description == checkRequest?.strSessionDescription {
                if isNeedOTP {
                    data = ConfirmResultStruct(image: "", title: "", list: nil, memo: "", confirmBtnName: dataOTP?.confirmBtnName ?? "", resultBtnName: dataOTP?.resultBtnName ?? "", checkRequest: nil)
                }
                if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode == ReturnCode_Success {
                    if let responseData = response.object(forKey: ReturnData_Key) as? [[String:String]] {
                        data?.list = responseData
                    }
                    data?.title = Transaction_Successful_Title
                    data?.image = ImageName.CowSuccess.rawValue
                }
                else {
                    data?.title = Transaction_Faild_Title
                    data?.image = ImageName.CowFailure.rawValue
                    if let message = response.object(forKey:ReturnMessage_Key) as? String {
                        data?.list = [[String:String]]()
                        data?.list?.append([Response_Key:Error_Title,Response_Value:message])
                    }
                }
                performSegue(withIdentifier: Confirm_Segue, sender: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let controller = segue.destination as! ResultViewController
        controller.setData(data!)
    }
    
    override func clickBackBarItem() {
        if !isNeedOTP {
            navigationController?.popViewController(animated: true)
        }
        else {
            VaktenManager.sharedInstance().cancelTaskOperation(with: dataOTP?.task) { resultCode in
                if VIsSuccessful(resultCode) {
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    self.showErrorMessage(nil, "\(ErrorMsg_CancelTask_Faild) \(resultCode)")
                }
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let list = isNeedOTP ? dataOTP?.list : data?.list
        if indexPath.row == list?.count {
            return Confirm_ImageConfirm_Cell_Height
        }
        else {
            let height = ResultCell.GetStringHeightByWidthAndFontSize((list?[indexPath.row][Response_Value])!, m_tvData.frame.size.width)
            return height
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let memo = isNeedOTP ? dataOTP?.memo : data?.memo
        if (memo?.isEmpty)! {
            return 0
        }
        else {
            return MemoView.GetStringHeightByWidthAndFontSize(memo!, m_tvData.frame.width)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let memo = isNeedOTP ? dataOTP?.memo : data?.memo
        if (memo?.isEmpty)! {
            return nil
        }
        else {
            let footer = getUIByID(.UIID_MemoView) as! MemoView
            footer.set(memo!)
            return footer
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let list = isNeedOTP ? dataOTP?.list : data?.list
        return (list?.count)!+1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let list = isNeedOTP ? dataOTP?.list : data?.list
        if indexPath.row == (list?.count)! {
            let cell = tableView.dequeueReusableCell(withIdentifier: SystemCell_Identify, for: indexPath)
            imageConfirmView?.frame = CGRect(x:0, y:0, width:cell.contentView.frame.width, height:cell.contentView.frame.height)
            cell.contentView.addSubview(imageConfirmView!)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell
            cell.set((list?[indexPath.row][Response_Key])!, (list?[indexPath.row][Response_Value])!)
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
    
    func ImageConfirmTextfieldBeginEditing(_ textfield:UITextField) {
        curTextfield = textfield
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickCheckBtn(_ sender: Any) {
        curTextfield?.resignFirstResponder()
        checkImageConfirm(password, transactionId)
    }
}
