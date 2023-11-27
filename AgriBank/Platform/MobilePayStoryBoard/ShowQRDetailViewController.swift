//
//  ShowQRDetailViewController.swift
//  AgriBank
//
//  Created by ABOT on 2020/1/6.
//  Copyright © 2020 Systex. All rights reserved.
//

import UIKit
let QRDetailView_ShowRefund_Segue = "GoRefund"
class ShowQRDetailViewController: BaseViewController, UITableViewDataSource {
    private var barTitle:String? = nil
    private var list:[[String:String]]? = nil
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ButBack: UIButton!
    @IBOutlet weak var BtnShowRefundCode: UIButton!
    
    // MARK: - Public
    func setList(_ title:String, _ list:[[String:String]]) {
        barTitle = title
        self.list = list
    }
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if RC2flag == "OK"{
            BtnShowRefundCode.isHidden = false
        }else
        {
            BtnShowRefundCode.isHidden = true
        }
        tableView.register(UINib(nibName: UIID.UIID_ResultCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultCell.NibName()!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.topItem?.title = barTitle
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
    @IBAction func BtnBack(_ sender: Any) {
        //  enterFeatureByID(.FeatureID_QRPayDetailView, false)
        navigationController?.popViewController(animated: true)
    }
    @IBAction func BtnShowRefundCode(_ sender: Any) {
         performSegue(withIdentifier: QRDetailView_ShowRefund_Segue, sender: nil)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          super.prepare(for: segue, sender: sender)
          let controller = segue.destination as! QRPayRefundViewController
        controller.wk_seq = list![0][Response_Value]!
        controller.wk_ActNo = list![1][Response_Value]!
      }
      
}
