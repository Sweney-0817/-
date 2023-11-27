//
//  MobileTransferSetupResultViewController.swift
//  AgriBank
//
//  Created by Jenny on 2021/8/2.
//  Copyright © 2021 Systex. All rights reserved.
//

import Foundation
class MobileTransferSetupResultViewController: BaseViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var labelContent: UILabel!
    @IBOutlet weak var bottomView: UIView!
    private var message = ""
    private var barTitle:String? = nil
    
    // MARK: - Public
    func setBrTitle( _ barTitle:String? = nil) {
        self.barTitle = barTitle
    }
    
    // MARK: - Public
    func setMessage(_ message:String) {
        self.message = message
    }
 
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = nil
        navigationItem.setHidesBackButton(true, animated:true)
        // Do any additional setup after loading the view.
//        setShadowView(bottomView, .Top)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if barTitle != nil {
            navigationController?.navigationBar.topItem?.title = barTitle
        }
        
        if !message.isEmpty {
            labelContent.text = message
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
