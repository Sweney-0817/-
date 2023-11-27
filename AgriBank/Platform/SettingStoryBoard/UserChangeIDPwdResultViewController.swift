//
//  UserChangeIDPwdResultViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/11.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class UserChangeIDPwdResultViewController: BaseViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var ReturnMsgLable: UILabel!
    private var errorMessage = ""
    
    // MARK: - Public
    func setErrorMessage(_ errorMessage:String) {
        self.errorMessage = errorMessage
    }
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = nil
        navigationItem.setHidesBackButton(true, animated:true)
        // Do any additional setup after loading the view.
        setShadowView(bottomView, .Top)
        titleLabel.text = errorMessage.isEmpty ? Change_Successful_Title : Change_Faild_Title
        imageView.image = errorMessage.isEmpty ? UIImage(named: ImageName.CowSuccess.rawValue) : UIImage(named: ImageName.CowFailure.rawValue)
        ReturnMsgLable.text = errorMessage.isEmpty ? "" :errorMessage
        if errorMessage.isEmpty {
            postLogout()
        }
        else {
            /* 帳戶狀態在「已過期，需要強制變更」「首登」，不管是否成功都需要登出(前後台資訊要清除) */
            if let info = AuthorizationManage.manage.getResponseLoginInfo(), let STATUS = info.STATUS, STATUS == Account_Status_ForcedChange_Pod, STATUS == Account_Status_FirstLogin {
                postLogout()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickConfirmBtn(_ sender: Any) {
        enterFeatureByID(.FeatureID_Home, true)
    }
}
