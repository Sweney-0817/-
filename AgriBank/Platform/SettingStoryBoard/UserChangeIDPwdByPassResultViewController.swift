//
//  UserChangeIDPwByPassResultViewController.swift
//  AgriBank
//
//  Created by Sweney on 2019/8/28.
//  Copyright © 2019 Systex. All rights reserved.
//
//108-8-28 Add by Sweney - 密碼沿用增加


import UIKit

class UserChangeIDPwdByPassResultViewController: BaseViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
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
       // titleLabel.text = errorMessage.isEmpty ? Change_Successful_Title : Change_Faild_Title
        imageView.image = errorMessage.isEmpty ? UIImage(named: ImageName.CowSuccess.rawValue) : UIImage(named: ImageName.CowFailure.rawValue)

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

