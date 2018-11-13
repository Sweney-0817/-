//
//  ConfirmViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/6/15.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit
import CoreLocation

let Confirm_ImageConfirm_Cell_Height:CGFloat = 60
let Confirm_Segue = "GoResult"
/* 「即時轉帳」確認頁特殊處理 */
let Predesignated_Title = "約定轉帳"
let NonPredesignated_Title = "非約定轉帳"

class ConfirmViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, ImageConfirmViewDelegate, CLLocationManagerDelegate {
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
    private var locationManager:CLLocationManager? = nil   // OTP需要開啟定位點
    var m_strTitle: String? = nil
    
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
            if CLLocationManager.authorizationStatus() == .notDetermined || CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                m_btnConfirm.setTitle(dataOTP?.confirmBtnName, for: .normal)
                // 開啟定位
                locationManager = CLLocationManager()
                locationManager?.delegate = self
                locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager?.requestWhenInUseAuthorization()
            }
            else {
                let alert = UIAlertController(title: UIAlert_Default_Title, message: ErrorMsg_NoPositioning, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: Determine_Title, style: .default) { _ in
                    self.navigationController?.popViewController(animated: true)
                })
                present(alert, animated: true, completion: nil)
            }
        }
        else {
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
                        postRequest((data?.checkRequest?.strMethod)!, (data?.checkRequest?.strSessionDescription)!, data?.checkRequest?.httpBody, data?.checkRequest?.loginHttpHead, data?.checkRequest?.strURL, (data?.checkRequest?.needCertificate)!, (data?.checkRequest?.isImage)!, (data?.checkRequest?.timeOut)!)
                    }
                }
                else {
                    setLoading(true)
                    VaktenManager.sharedInstance().signTaskOperation(with: dataOTP?.task) { resultCode in
                        if VIsSuccessful(resultCode) {
                            let otp = VaktenManager.sharedInstance().generateGeoOTPCode()
                            if VIsSuccessful((otp?.resultCode)!) {
                                self.dataOTP?.httpBodyList?["otp"] = otp?.otp
                                self.dataOTP?.checkRequest?.httpBody = AuthorizationManage.manage.converInputToHttpBody((self.dataOTP?.httpBodyList!)!, true)
                                self.postRequest((self.dataOTP?.checkRequest?.strMethod)!, (self.dataOTP?.checkRequest?.strSessionDescription)!, self.dataOTP?.checkRequest?.httpBody, self.dataOTP?.checkRequest?.loginHttpHead, self.dataOTP?.checkRequest?.strURL, (self.dataOTP?.checkRequest?.needCertificate)!, (self.dataOTP?.checkRequest?.isImage)!, (self.dataOTP?.checkRequest?.timeOut)!)
                            }
                            else {
                                let alert = UIAlertController(title: UIAlert_Default_Title, message: "\(ErrorMsg_GenerateOTP_Faild) \((otp?.resultCode)!.rawValue)", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: Determine_Title, style: .default) { _ in
                                    DispatchQueue.main.async {
                                        self.enterFeatureByID(.FeatureID_Home, true)
                                    }
                                })
                                self.present(alert, animated: false, completion: nil)
                                self.setLoading(false)
                            }
                        }
                        else {
                            let alert = UIAlertController(title: UIAlert_Default_Title, message: "\(ErrorMsg_SignTask_Faild) \(resultCode.rawValue)", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: Determine_Title, style: .default) { _ in
                                DispatchQueue.main.async {
                                    self.enterFeatureByID(.FeatureID_Home, true)
                                }
                            })
                            self.present(alert, animated: false, completion: nil)
                            self.setLoading(false)
                        }
                    }
                }
            }
            else {
                imageConfirmView?.m_tfInput.text = ""
                password = ""
                getImageConfirm(transactionId)
                showErrorMessage(nil, ErrorMsg_Image_ConfirmFaild)
            }
        case BaseTransactionID_Description, "BaseCOMM0802", "QR0101", "Gold0101"://在Base發的 丟回Base處理
            super.didResponse(description, response)
        default:
            if isNeedOTP {
                data = ConfirmResultStruct(image: "", title: "", list: nil, memo: "", confirmBtnName: dataOTP?.confirmBtnName ?? "", resultBtnName: dataOTP?.resultBtnName ?? "", checkRequest: nil)
            }
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode == ReturnCode_Success {
                if  (description == "QR0302") ||
                    (description == "Gold0301") ||
                    (description == "Gold0302") ||
                    (description == "Gold0402") ||
                    (description == "Gold0404")
                {
                    if let responseData = response.object(forKey: ReturnData_Key) as? [String:Any] {
                        if let responseResult = responseData["Result"] as? [[String:String]] {
                            data?.list = responseResult
                        }
                        if let memo = responseData["Memo"] as? String {
                            data?.memo = memo
                        }
                    }
                }
                else if let responseData = response.object(forKey: ReturnData_Key) as? [[String:String]] {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let controller = segue.destination as! ResultViewController
        controller.setData(data!)
         /* 「即時轉帳」結果頁特殊處理 */
        if getCurrentFeatureID() == .FeatureID_NTTransfer {
            controller.setData(data!, isNeedOTP ? NonPredesignated_Title : Predesignated_Title)
        }
        else {
            controller.setData(data!)
        }
    }
    
    override func clickBackBarItem() {
        if !isNeedOTP {
            navigationController?.popViewController(animated: true)
        }
        else {
            VaktenManager.sharedInstance().cancelTaskOperation(with: dataOTP?.task) { resultCode in
                if !VIsSuccessful(resultCode) {
                    self.showErrorMessage(nil, "\(ErrorMsg_CancelTask_Faild) \(resultCode.rawValue)")
                }
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager?.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager?.stopUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /* 「即時轉帳」確認頁特殊處理 */
        if getCurrentFeatureID() == .FeatureID_NTTransfer {
            navigationController?.navigationBar.topItem?.title = isNeedOTP ? NonPredesignated_Title : Predesignated_Title
        }
        if (m_strTitle != nil) {
            navigationController?.navigationBar.topItem?.title = m_strTitle
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
        if section == 0 {
            return tableView.sectionFooterHeight
        }
        else {
            let memo = isNeedOTP ? dataOTP?.memo : data?.memo
            if (memo?.isEmpty)! {
                return 0
            }
            else {
                return MemoView.GetStringHeightByWidthAndFontSize(memo!, m_tvData.frame.width)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let head = getUIByID(.UIID_ShowMessageHeadView) as! ShowMessageHeadView
            if isNeedOTP {
                head.imageView.image = UIImage(named: dataOTP?.image ?? "")
                head.titleLabel.text = dataOTP?.title
            }
            else {
                head.imageView.image = UIImage(named: data?.image ?? "")
                head.titleLabel.text = data?.title
            }
            return head
        }
        else {
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
            let list = isNeedOTP ? dataOTP?.list : data?.list
            return (list?.count)!+1
        }
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
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .notDetermined && status != .authorizedAlways && status != .authorizedWhenInUse {
            let alert = UIAlertController(title: UIAlert_Default_Title, message: ErrorMsg_NoPositioning, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Determine_Title, style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
            })
            present(alert, animated: true, completion: nil)
        }
    }
}
