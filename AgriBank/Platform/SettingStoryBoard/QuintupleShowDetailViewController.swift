//
//  QuintupleShowDetailViewController.swift
//  AgriBank
//
//  Created by ABOT on 2021/9/14.
//  Copyright © 2021 Systex. All rights reserved.
//

import UIKit
let showGoToQuintupleView_Segue = "showGoToQuintupleView"
class QuintupleShowDetailViewController: BaseViewController , UITableViewDataSource, UITableViewDelegate  {
    private var barTitle:String? = nil
    private var list:[[String:String]]? = nil
    private var Readstatus = ""
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ButBack: UIButton!
    @IBOutlet weak var BtnShowRefundCode: UIButton!
    
    // MARK: - Public
    func setList(_ title:String, _ list:[[String:String]],_ Reads:String) {
        barTitle = title
        self.list = list
        Readstatus = Reads
    }
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        if Readstatus == "3"
//        {
//            BtnShowRefundCode.isHidden = true
//        }else{
//           // BtnShowRefundCode.isHidden = false
//        }
        navigationItem.leftBarButtonItem = nil
        navigationItem.setHidesBackButton(true, animated:true)
        tableView.dataSource = self; tableView.register(UINib(nibName: UIID.UIID_ResultCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultCell.NibName()!)
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
        //navigationController?.popViewController(animated: true)
        enterFeatureByID(.FeatureID_Home, false)
    }
    @IBAction func BtnShowRefundCode(_ sender: Any) {
        transactionId = tempTransactionId
         performSegue(withIdentifier: showGoToQuintupleView_Segue, sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //重新綁定
      if segue.identifier == showGoToQuintupleView_Segue {

          let controller = segue.destination as! QuintupleViewController
          isBack = "REBIND"
      }
    }
}


