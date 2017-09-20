//
//  ServiceBaseViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/10.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit
import CoreLocation

struct ServiceBaseStruct {
    var name:String? = nil
    var address:String? = nil
    var phone:String? = nil
    var fax:String? = nil
    var distance:String? = nil
    var type:String? = nil
    var location:CLLocationCoordinate2D? = nil
    init (_ name:String, _ address:String, _ phone:String, _ fax:String, _ distance:String, _ type:String, _ location:CLLocationCoordinate2D) {
        self.name = name
        self.address = address
        self.phone = phone
        self.fax = fax
        self.distance = distance
        self.type = type
        self.location = location
    }
}

let ServiceBase_TypeList = ["全部","農漁會","ATM"]
let ServiceBase_Default_SearchRange = "我的週遭"
let ServiceBase_CellHeight = CGFloat(100)
let ServiceBase_Segue = "goDetail"
let ServiceBase_Unit_Type = "1"
let ServiceBase_ATM_Type = "2"
let ServiceBase_OneDrop_Title = "查詢範圍"

class ServiceBaseViewController: BaseViewController, OneRowDropDownViewDelegate, UIActionSheetDelegate, ChooseTypeDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    @IBOutlet weak var m_vPlace: UIView!
    @IBOutlet weak var m_vChooseTypeView: ChooseTypeView!
    @IBOutlet weak var m_tvData: UITableView!

    private var m_DDPlace: OneRowDropDownView? = nil
    private var m_strSearchRange = ServiceBase_Default_SearchRange
    private var currentType = ServiceBase_TypeList.first!
    private var aroundMeList = [ServiceBaseStruct]()
    private var unitInfoList = [String:[ServiceBaseStruct]]() // 據點
    private var unitList = [String]()                         // 據點 - city
    private var ATMInfoList = [String:[ServiceBaseStruct]]()  // ATM
    private var ATMList = [String]()                          // ATM - city
    private var curData = [ServiceBaseStruct]()
    private var m_iSelectedIndex:Int? = nil
    private var locationManager:CLLocationManager? = nil
    private var curLocation = CLLocationCoordinate2D()

    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()

        setAllSubView()
        setShadowView(m_vChooseTypeView)
        
        // 開啟定位
        if CLLocationManager.authorizationStatus() == .notDetermined || CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager = CLLocationManager()
            locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager?.delegate = self
            if CLLocationManager.authorizationStatus() == .notDetermined  {
                locationManager?.requestWhenInUseAuthorization()
            }
        }
        else {
            locationManager?.requestWhenInUseAuthorization()
        }
        
        setLoading(true)
        postRequest("Info/INFO0302", "INFO0302", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07053","Operate":"getListInfo"], false), AuthorizationManage.manage.getHttpHead(false))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager?.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager?.stopUpdatingLocation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = segue.destination as? ServiceBaseDetailViewController {
            var list = [[String:String]]()
            list.append([Response_Key:"名稱",Response_Value:curData[m_iSelectedIndex!].name ?? ""])
            list.append([Response_Key:"地址",Response_Value:curData[m_iSelectedIndex!].address ?? ""])
            list.append([Response_Key:"電話",Response_Value:curData[m_iSelectedIndex!].phone ?? ""])
            list.append([Response_Key:"傳真",Response_Value:curData[m_iSelectedIndex!].fax ?? ""])
            controller.setData(list, curData[m_iSelectedIndex!].phone ?? "", curLocation)
        }
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case "INFO0301":
            if let data = response.object(forKey: "Data") as? [String:Any], let array = data["No"] as? [[String:String]] {
                aroundMeList.removeAll()
                for info in array {
                    if let name = info["Name"], let address = info["Address"], let tel = info["Tel"], let fax = info["Fax"], let distance = info["Distance"], let type = info["Type"], let longitude = info["Longitude"], let latitude = info["Latitude"] {
                        aroundMeList.append(ServiceBaseStruct(name, address, tel, fax, distance, type, CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude) ?? 0, longitude: CLLocationDegrees(longitude) ?? 0)))
                    }
                }
                initDataTitleForType()
            }
            
        case "INFO0302":
            if let data = response.object(forKey: "Data") as? [String:Any] {
                unitList.removeAll()
                unitInfoList.removeAll()
                if let unit = data["Unit"] as? [[String:String]] {
                    for info in unit {
                        if let city = info["CC_CityName"] {
                            if unitList.index(of: city) == nil {
                                unitList.append(city)
                            }
                            if let name = info["CUM_FullBankChineseName"], let address = info["CUM_Address"], let tel = info["CUM_Telephone"], let fax = info["CUM_Fax"], let longitude = info["CUM_Longitude"], let latitude = info["CUM_Latitude"] {
                                if var array = unitInfoList[city] {
                                    array.append(ServiceBaseStruct(name, address, tel, fax, "", "", CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude) ?? 0, longitude: CLLocationDegrees(longitude) ?? 0)))
                                }
                                else {
                                    unitInfoList[city] = [ServiceBaseStruct(name, address, tel, fax, "", "", CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude) ?? 0, longitude: CLLocationDegrees(longitude) ?? 0))]
                                }
                            }
                        }
                    }
                }
                if let ATM = data["ATM"] as? [[String:String]]  {
                    ATMList.removeAll()
                    ATMInfoList.removeAll()
                    for info in ATM {
                        if let city = info["CC_CityName"] {
                            if ATMList.index(of: city) == nil {
                                ATMList.append(city)
                            }
                            if let name = info["CAM_ATMName"], let address = info["CAM_Address"],let longitude = info["CAM_Longitude"], let latitude = info["CAM_Latitude"] {
                                if var array = ATMInfoList[city] {
                                    array.append(ServiceBaseStruct(name, address, "", "", "", "", CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude) ?? 0, longitude: CLLocationDegrees(longitude) ?? 0)))
                                }
                                else {
                                    ATMInfoList[city] = [ServiceBaseStruct(name, address, "", "", "", "", CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude) ?? 0, longitude: CLLocationDegrees(longitude) ?? 0))]
                                }
                            }
                        }
                    }
                }
            }
            
        default: super.didResponse(description, response)
        }
    }
    
    // MARK: - Private
    private func setAllSubView() {
        setDDPlace()
        setChooseTypeView()
        setDataTableView()
    }
    
    private func setDDPlace() {
        if m_DDPlace == nil {
            m_DDPlace = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
            m_DDPlace?.delegate = self
            m_DDPlace?.setOneRow(ServiceBase_OneDrop_Title, ServiceBase_Default_SearchRange)
            m_DDPlace?.frame = CGRect(x:0, y:0, width:m_vPlace.frame.width, height:(m_DDPlace?.getHeight())!)
            m_vPlace.addSubview(m_DDPlace!)
        }
    }
    
    private func setChooseTypeView() {
        let width = view.frame.width / CGFloat(ServiceBase_TypeList.count)
        m_vChooseTypeView.setTypeList(ServiceBase_TypeList, setDelegate: self, nil, width)
    }
    
    private func setDataTableView() {
        m_tvData.register(UINib(nibName: UIID.UIID_ServiceBaseCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ServiceBaseCell.NibName()!)
    }
    
    private func initDataTitleForType() {
        curData.removeAll()
        switch m_strSearchRange {
        case ServiceBase_Default_SearchRange:
            if let index = ServiceBase_TypeList.index(of: currentType) {
                switch index {
                case 0:
                    curData.append(contentsOf: aroundMeList)
                    
                case 1:
                    for info in aroundMeList {
                        if info.type == ServiceBase_Unit_Type {
                            curData.append(info)
                        }
                    }
                    
                case 2:
                    for info in aroundMeList {
                        if info.type == ServiceBase_ATM_Type {
                            curData.append(info)
                        }
                    }
                    
                default: break
                }
            }
        default:
            if let index = ServiceBase_TypeList.index(of: currentType) {
                switch index {
                case 0:
                    if unitInfoList[m_strSearchRange] != nil {
                        curData.append(contentsOf: unitInfoList[m_strSearchRange]!)
                    }
                    if ATMInfoList[m_strSearchRange] != nil {
                        curData.append(contentsOf: ATMInfoList[m_strSearchRange]!)
                    }
                case 1:
                    if unitInfoList[m_strSearchRange] != nil {
                        curData.append(contentsOf: unitInfoList[m_strSearchRange]!)
                    }
                case 2:
                    if ATMInfoList[m_strSearchRange] != nil {
                        curData.append(contentsOf: ATMInfoList[m_strSearchRange]!)
                    }
                default: break
                }
            }
        }
        m_tvData.reloadData()
    }

    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        var cityList = [ServiceBase_Default_SearchRange]
        if let index = ServiceBase_TypeList.index(of: currentType) {
            switch index {
            case 0:
                cityList.append(contentsOf: unitList)
            case 1:
                cityList.append(contentsOf: unitList)
            case 2:
                cityList.append(contentsOf: ATMList)
            default: break
            }
        }
        
        if cityList.count != 0 {
            let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: UIActionSheet_Cancel_Title, destructiveButtonTitle: nil)
            cityList.forEach{city in actSheet.addButton(withTitle: city)}
            actSheet.show(in: view)
        }
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet.cancelButtonIndex != buttonIndex {
            m_strSearchRange = actionSheet.buttonTitle(at: buttonIndex)!
            initDataTitleForType()
            m_DDPlace?.setOneRow((m_DDPlace?.m_lbFirstRowTitle.text)!, actionSheet.buttonTitle(at: buttonIndex)!)
            m_tvData.reloadData()
        }
    }
    
    // MARK: - ChooseTypeDelegate
    func clickChooseTypeBtn(_ name:String) {
        if currentType != name {
            currentType = name
            initDataTitleForType()
        }
        m_tvData.reloadData()
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ServiceBase_CellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        m_iSelectedIndex = indexPath.row
        performSegue(withIdentifier: ServiceBase_Segue, sender: nil)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return curData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ServiceBaseCell.NibName()!, for: indexPath) as! ServiceBaseCell
        if indexPath.row < curData.count {
            cell.setData(curData[indexPath.row].name ?? "", curData[indexPath.row].address ?? "", m_strSearchRange == ServiceBase_Default_SearchRange ? (curData[indexPath.row].distance ?? "") : "")
        }
        cell.selectionStyle = .none
        return cell
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.first?.coordinate {
            if curLocation.latitude != coordinate.latitude || curLocation.longitude != coordinate.longitude {
                curLocation = coordinate
                postRequest("Info/INFO0301", "INFO0301", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07052","Operate":"getListInfo","Longitude":curLocation.longitude,"Latitude":curLocation.latitude], false), AuthorizationManage.manage.getHttpHead(false))
            }
        }
    }
}
