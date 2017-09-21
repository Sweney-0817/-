//
//  PromotionViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/10.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

struct PromotionStruct {
    var title:String? = nil
    var date:String? = nil
    var place:String? = nil
    var url:String? = nil
    var ID:String? = nil
    init (_ title:String, _ date:String, _ place:String, _ url:String, _ ID:String) {
        self.title = title
        self.date = date
        self.place = place
        self.url = url
        self.ID = ID
    }
}

let Promotion_Seivice_Title = "提供單位"
let Promotion_Segue = "goDetail"

class PromotionViewController: BaseViewController, OneRowDropDownViewDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var m_vPlace: UIView!
    @IBOutlet weak var m_tvData: UITableView!
    private var m_iSelectedIndex = -1
    private var m_DDPlace: OneRowDropDownView? = nil
    private var promotionList = [String:[PromotionStruct]]()
    private var cityList = [String]()
    private var chooseCity = ""
    private var webContent:Data? = nil
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()

        setAllSubView()
        setShadowView(m_vPlace)
        setLoading(true)
        postRequest("Info/INFO0101", "INFO0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07031","Operate":"getListInfo"], false), AuthorizationManage.manage.getHttpHead(false))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case "INFO0101":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let list = data["AllPromo"] as? [[String:Any]] {
                for index in 0..<list.count {
                    let dic = list[index]
                    if let city = dic["CC_CityName"] as? String, let promotion = dic["LocalPromo"] as? [[String:String]] {
                        var pList = [PromotionStruct]()
                        for info in promotion {
                            pList.append( PromotionStruct.init( info["CMI_Title"] ?? "", info["CMI_AddedDT"] ?? "", info["CUM_BankChineseName"] ?? "", info["URL"] ?? "", info["CMI_ID"] ?? "" ) )
                        }
                        promotionList[city] = pList
                        cityList.append(city)
                    }
                }
            }
            
//        case "INFO0102":
//            if let data = response.object(forKey: RESPONSE_Data_KEY) as? Data {
//                webContent = data
//                performSegue(withIdentifier: Promotion_Segue, sender: nil)
//            }
            
        default: super.didResponse(description, response)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let webContentViewController = segue.destination as! WebContentViewController
        if let list = promotionList[chooseCity] {
            webContentViewController.setData(list[m_iSelectedIndex], webContent)
        }
    }
    
    // MARK: - Private
    private func setAllSubView() {
        setDDPlace()
        setDataTableView()
    }

    private func setDDPlace() {
        if m_DDPlace == nil {
            m_DDPlace = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
            m_DDPlace?.delegate = self
            m_DDPlace?.setOneRow(Promotion_Seivice_Title, Choose_Title)
            m_DDPlace?.frame = CGRect(x:0, y:0, width:m_vPlace.frame.width, height:(m_DDPlace?.getHeight())!)
            m_vPlace.addSubview(m_DDPlace!)
        }
    }

    private func setDataTableView() {
        m_tvData.register(UINib(nibName: UIID.UIID_PromotionCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_PromotionCell.NibName()!)
    }

    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        let action = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
        cityList.forEach{city in action.addButton(withTitle: city)}
        action.show(in: self.view)
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet.cancelButtonIndex != buttonIndex {
            m_DDPlace?.setOneRow((m_DDPlace?.m_lbFirstRowTitle.text)!, actionSheet.buttonTitle(at: buttonIndex)!)
            chooseCity = actionSheet.buttonTitle(at: buttonIndex) ?? ""
            m_tvData.reloadData()
        }
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 129
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        m_iSelectedIndex = indexPath.row
//        if let list = promotionList[chooseCity], let ID = list[m_iSelectedIndex].ID {
//            setLoading(true)
//            getRequest("Info/INFO0102?CMIID=\(ID)", "INFO0102", nil, AuthorizationManage.manage.getHttpHead(false), nil, false, .Data)
//        }
        performSegue(withIdentifier: Promotion_Segue, sender: nil)
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = promotionList[chooseCity] {
            return list.count
        }
        return 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_PromotionCell.NibName()!, for: indexPath) as! PromotionCell
        if let list = promotionList[chooseCity], let title = list[indexPath.row].title, let date = list[indexPath.row].date, let place = list[indexPath.row].place  {
            cell.setData(title, date, place)
        }
        cell.selectionStyle = .none
        return cell
    }
}
