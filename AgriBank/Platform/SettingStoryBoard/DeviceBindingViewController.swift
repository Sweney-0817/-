//
//  DeviceBindingViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/11.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let DeviceBindingResult_Segue = "GoDeviceBindingResult"

class DeviceBindingViewController: BaseViewController, UITextFieldDelegate, OneRowDropDownViewDelegate {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var identifyTextfield: TextField!
    @IBOutlet weak var userCodeTextfield: TextField!
    @IBOutlet weak var passwordTextfield: TextField!
    @IBOutlet weak var checkCodeTextfield: TextField!
    @IBOutlet weak var bottomVIew: UIView!
    private var topDropView:OneRowDropDownView? = nil
    
    // MARK: - Public
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! BasicInfoResultViewController
        var list = [[String:String]]()
        list.append(["Key": "錯誤訊息", "Value":"錯誤訊息"])
        controller.SetList(list)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        topDropView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        topDropView?.frame = topView.frame
        topDropView?.frame.origin = .zero
        topView.addSubview(topDropView!)
        setShadowView(bottomVIew)
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
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickBindingBtn(_ sender: Any) {
        performSegue(withIdentifier: DeviceBindingResult_Segue, sender: self)
    }
}
