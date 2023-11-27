//
//  PushDetailViewController.swift
//  AgriBank
//
//  Created by 數位資訊部 on 2020/6/3.
//  Copyright © 2020 Systex. All rights reserved.
//

import UIKit

class PushDetailResultViewController: BaseViewController ,UITableViewDataSource{
    

    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var bottomView: UIView!
    
     private var errorMessage = ""
     private var barTitle:String? = nil
     private var list:[[String:String]]? = nil //chiu push test
    // MARK: - Public
    func setErrorMessage(_ errorMessage:String) {
        self.errorMessage = errorMessage
    }
    // MARK: - Public
    func setBrTitle( _ barTitle:String? = nil) {
        self.barTitle = barTitle
    }
    // MARK: - Public
    func setList(_ title:String, _ list:[[String:String]]) {
    //    titleLabel.text = title
        self.list = list
    }
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.setHidesBackButton(true, animated:true)
        // Do any additional setup after loading the view.
        setShadowView(bottomView, .Top)
//        if pushReceiveFlag == "NO"{
//            titleLabel.text = "交易失敗"
//            self.errorMessage = "error"
//        }else{
            titleLabel.text = "交易成功"
            self.errorMessage = ""
//        }
        imageView.image = errorMessage.isEmpty ? UIImage(named: ImageName.CowSuccess.rawValue) : UIImage(named: ImageName.CowFailure.rawValue)
      
         tableView.dataSource = self
         tableView.register(UINib(nibName: UIID.UIID_ResultCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultCell.NibName()!)
        pushReceiveFlag = ""
        pushResultList = nil
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if barTitle != nil {
            navigationController?.navigationBar.topItem?.title = barTitle
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return list?.count ?? 0
       }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell
        cell.set((list?[indexPath.row][Response_Key])!, (list?[indexPath.row][Response_Value])!)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    // MARK: - StoryBoard Touch Event
    //@IBAction func clickConfirmBtn(_ sender: Any) {
    @IBAction func clickConfirmBtn(_ sender: Any) {
    enterFeatureByID(.FeatureID_Home, false)
        
    }
    @IBAction func clickHex1Btn(_ sender: Any) {
    enterFeatureByID(.FeatureID_QRPay, false)
             }
}

