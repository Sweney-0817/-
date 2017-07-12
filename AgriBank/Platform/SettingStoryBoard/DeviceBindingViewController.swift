//
//  DeviceBindingViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/11.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class DeviceBindingViewController: BaseViewController, UITextFieldDelegate, OneRowDropDownViewDelegate {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var identifyTextfield: TextField!
    @IBOutlet weak var userCodeTextfield: TextField!
    @IBOutlet weak var passwordTextfield: TextField!
    @IBOutlet weak var checkCodeTextfield: TextField!
    private var topDropView:OneRowDropDownView? = nil
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        topDropView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        topDropView?.frame = topView.frame
        topDropView?.frame.origin = .zero
        topView.addSubview(topDropView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        
    }
}
