//
//  MOTPSettingResultViewController.swift
//  AgriBank
//
//  Created by ABOT on 2020/10/19.
//  Copyright © 2020 Systex. All rights reserved.
//

import UIKit
class MOTPSettingResultViewController: BaseViewController {
    

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    private var errorMessage = ""
    private var barTitle:String? = nil
    private var titlemsg:String? = nil
    
    // MARK: - Public
    func setBrTitle( _ barTitle:String? = nil , _ TitleMsg:String? = nil) {
        self.barTitle = barTitle
        self.titlemsg = TitleMsg
    }
    
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
        
        imageView.image = errorMessage.isEmpty ? UIImage(named: ImageName.CowSuccess.rawValue) : UIImage(named: ImageName.CowFailure.rawValue)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if barTitle != nil {
            navigationController?.navigationBar.topItem?.title = barTitle
        }
        if titlemsg != nil {
            self.titleLabel.text = titlemsg
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickConfirmBtn(_ sender: Any) {
        enterFeatureByID(.FeatureID_Home, false)
    }
}
