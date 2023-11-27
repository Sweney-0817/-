//
//  FastLogInGraphicView.swift
//  AgriBank
//
//  Created by ABOT on 2019/11/12.
//  Copyright © 2019 Systex. All rights reserved.
//

import UIKit
import AudioToolbox


enum GesturePodType: Int {
    case setting1 = 1
    case setting2 = 2
}

class FastLogInGraphicView:  BaseViewController  {
    
    
    var m_nextFeatureID : PlatformFeatureID? = nil
    var m_dicData: [String:Any]? = nil
    var m_dicAcceptData : [String:String]? = nil
    var m_version :String = ""
    
    var barTitle:String = ""
    
    private var currentPoint: CGPoint?
    private var gesturePodType = GesturePodType.setting1
    private var pod = [Int]()// 記錄設定pod
    private var selectedPod = [Int]()// 當前畫出的pod
    // 用來管理畫在 View 上的 Layer
    private var lineLayers = [CAShapeLayer]() {
        didSet {
            //print(lineLayers.count)
       }
}
    private var row = 3
    private let buttonTag = -1
    private let cellID = "cell"
    private var moveLayer: CAShapeLayer?// 跟著手指移動的 Layer
    
    @IBOutlet weak var gestureCollectionView: GestureCollectionView!
    
    @IBOutlet weak var LabelMsg: UILabel!
    
    
    @IBAction func changeType(_ sender: UISegmentedControl) {
        guard let type = GesturePodType(rawValue: sender.selectedSegmentIndex) else { return }
        gesturePodType = type
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //關掉手勢滑動選單
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            (rootViewController as! SideMenuViewController).SetGestureStatus(false)
        }
        gestureCollectionView.dataSource = self
        gestureCollectionView.delegate = self
        gestureCollectionView.gestureDelegate = self
        gestureCollectionView.isUserInteractionEnabled = false //讓觸碰效果更好一些
        
        FastLogIn_Type = "2"  // 0:pod  *1:touchid/faceid 2:picture
        getTransactionID("01014", TransactionID_Description)
        
        // Do any additional setup after loading the view.
       
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if barTitle != "" {
            navigationController?.navigationBar.topItem?.title = barTitle
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        //關掉手勢滑動選單
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            (rootViewController as! SideMenuViewController).SetGestureStatus(true)
        }
    }
    // MARK: - Public
    func setBrTitle( _ barTitle:String? = nil) {
        self.barTitle = barTitle!
        self.needShowBackBarItem = true
    }
    func send_confirm() {
        self.setLoading(true)
        if let info = AuthorizationManage.manage.GetLoginInfo(){
            let  bCode = info.bankCode
              Gpod = pod.description
            postRequest("Comm/COMM0104", "COMM0104", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01014","Operate":"commitTxn","TransactionId":transactionId,"KINBR":bCode,"appId": AgriBank_AppID,"Version": AgriBank_Version,"appUid": AgriBank_AppUid,"uid": AgriBank_DeviceID,"model": AgriBank_DeviceType,"systemVersion": AgriBank_SystemVersion,"codeName": AgriBank_DeviceType,"tradeMark": AgriBank_TradeMark,"GraphPWD":SecurityUtility.utility.AES256Encrypt("AFISCCOMTW" +  pod.description, "\(SEA1)\(SEA2)\(SEA3)")], true), AuthorizationManage.manage.getHttpHead(true))
        }
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                tempTransactionId = tranId
            }
            else {
                super.didResponse(description, response)
            }
            
        case "COMM0104":
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String {
                if returnCode == ReturnCode_Success {
                    
                    //write faster login info
                    if let info = AuthorizationManage.manage.GetLoginInfo(){
                        let  bCode = info.bankCode
                        let  bid   = info.aot
                        //記住密碼
                        //SecurityUtility.utility.writeFileByKey(bid, SetKey: File_Account_Key, setEncryptKey: "\(SEA1)\(SEA2)\(SEA3)")
                        //2020-10 資安檢測修正 by sweney
                        //將Accounte改存到keychain
                        //=====================================
                         KeychainManager.keyChianDelete(identifier: File_Account_Key)
                         //KeychainManager.keyChainSaveData(data:  SecurityUtility.utility.AES256Encrypt(bid, "\(SEA1)\(SEA2)\(SEA3)"), withIdentifier: File_Account_Key)
                        KeychainManager.keyChainSaveData(data:bid, withIdentifier: File_Account_Key)
                       //==========================================
                        //寫入目前快登項目 0:pod 1:touchid/faceid 2:picture(1 byte)
                        SecurityUtility.utility.writeFileByKey(FastLogIn_Type + bid , SetKey: bCode , setEncryptKey: "\(SEA1)\(SEA2)\(SEA3)")
                        //When user login successful app will auto save bankcode, so didn't do this
                        // SecurityUtility.utility.writeFileByKey(bCode, SetKey: File_BankCode_Key, setEncryptKey: SEA)
                        //GoFastLogInResult
                        super.didResponse(description, response)
                        performSegue(withIdentifier:GoFastLogInResult, sender: nil)
                        
                    }
                }
                    
                else{
                    let message = (response.object(forKey: ReturnMessage_Key) as? String) ?? ""
                    let alert = UIAlertController(title: UIAlert_Default_Title, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: Cancel_Title, style: .default) { _ in
                        DispatchQueue.main.async {
                            self.getImageConfirm()
                        }
                    })
                }
                
            }
            else {
                super.didResponse(description, response)
            }
        default:
//            if let returnCode = response.object(forKey: ReturnCode_Key) as? String {
//                if returnCode == ReturnCode_Success {
                   super.didResponse(description, response)
//                }
//                else if returnCode == "E_COMM0401_02" {
//                    let message = "此ID已設定f，請確認是否要設定此裝置，停用另二台裝置快速登入？"
//                    //(response.object(forKey: ReturnMessage_Key) as? String) ??""
//                    //show del msg
//                    let confirmHandler : ()->Void = {
//
//                        self.setLoading(true)
//                        if let info = AuthorizationManage.manage.GetLoginInfo(){
//                            let  bCode = info.bankCode
//                            self.postRequest("Comm/COMM0104", "COMM0104", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01014","Operate":"commitTxn","TransactionId":self.transactionId,"KINBR":bCode,"appId": AgriBank_AppID,"Version": AgriBank_Version,"appUid": AgriBank_AppUid,"uid": AgriBank_DeviceID,"model": AgriBank_DeviceType,"systemVersion": AgriBank_SystemVersion,"codeName": AgriBank_DeviceType,"tradeMark": AgriBank_TradeMark,"CreateMode":"2","GraphPWD":SecurityUtility.utility.AES256Encrypt("AFISCCOMTW" +  self.pod.description, "\(SEA1)\(SEA2)\(SEA3)")], true), AuthorizationManage.manage.getHttpHead(true))
//                        }
//
//                    }
//                    let cancelHandler : ()->Void = {()}
//                    showAlert(title: "注意", msg: message , confirmTitle: "確認送出", cancleTitle: "取消", completionHandler: confirmHandler, cancelHandelr: cancelHandler)
//
//                }
//            }
            
            
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == GoFastLogInResult {
            let controller = segue.destination as! FastLogInResultViewController
            var barTitle:String? = nil
            barTitle = "設定快速登入圖形密碼"
            var titlemsg:String? = nil
            titlemsg = "設定成功，下次可使用圖形密碼快速登入!"
            controller.setBrTitle(barTitle,titlemsg)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    //畫面設定區：
    //畫線
    private func drawLine(to point: CGPoint) {
         // 判斷當前是否有前一個座標
        if let currentPoint = currentPoint {
             // 新增 CAShapeLayer
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = gestureCollectionView.bounds
            shapeLayer.position = gestureCollectionView.center
            shapeLayer.fillColor = nil
            shapeLayer.lineWidth = 6
            shapeLayer.strokeColor = UIColor.green.cgColor
            let path = UIBezierPath()
            path.move(to: currentPoint)
            path.addLine(to: point)
            shapeLayer.path = path.cgPath
            shapeLayer.lineCap = "round"
            view.layer.addSublayer(shapeLayer)
            // 將我們的 layer 加入到 lineLayers
            //之後當我們畫線結束後會刪除裡面所有 layer
            lineLayers.append(shapeLayer)
           // print("new point:X=" + point.x.description  + "Y=" +  point.y.description)
        }
         // 將當前座標設定為選擇到的座標
        currentPoint = point
        //  print("set point:X=" +  point.x.description + "Y=" +  point.y.description)
    }
    //手勢移動時
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        gestureCollectionView.touchesMoved(touches, with: event)
           
    }
    //圖形化完
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        gestureCollectionView.touchesEnded(touches, with: event)
         //print(" touch end ")
    }
    //圖形化完
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)  {
        gestureCollectionView.touchesMoved(touches, with: event)
       // print(" touch touchesBegan ")
    }
    
    func showMessageAlert(message: String) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        let alert = UIAlertController(title: "圖形密碼設定", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default) { [weak self](_) in
            self?.lineLayers.forEach { (layer) in
                layer.removeFromSuperlayer()
            }
            self?.lineLayers.removeAll()
            self?.selectedPod.removeAll()
            self?.gestureCollectionView.reloadSections(IndexSet(integer: 0))
            self?.currentPoint = nil
            self?.moveLayer?.removeFromSuperlayer()
            self?.moveLayer = nil
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension FastLogInGraphicView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return row * row
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
        cell.tag = indexPath.row
        cell.layer.cornerRadius = cell.bounds.height / 2
        cell.layer.borderColor = !selectedPod.contains(indexPath.row) ? UIColor.init(red: 30/255, green: 144/255, blue: 1, alpha: 1).cgColor : UIColor.green.cgColor
        cell.layer.borderWidth = 6
       // print("cell:" + String( indexPath.row ))
        return cell
    }
}

extension FastLogInGraphicView: UICollectionViewDelegate {
    
}

extension FastLogInGraphicView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / CGFloat(row * 2 - 1)
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let width = collectionView.bounds.width / CGFloat(row * 2 - 1)
        return width
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let width = collectionView.bounds.width / CGFloat(row * 2 - 1)
        return width
    }
}

extension FastLogInGraphicView: GestureCollectionViewDelegate {
    // 讓手指碰觸點與前一個點產生連線(與畫線大同小異，只是只會在畫面上加入一次)
    func move(point: CGPoint) {
        // 如果前一個點存在
        if let currentPoint = currentPoint {
          //  print("前一個點:X=" +  currentPoint.x.description + "Y=" +  currentPoint.y.description)
            // 判斷目前與手指的連線是否存在
            // 若無則新增一個 CAShapeLayer
            if moveLayer == nil {
                moveLayer = CAShapeLayer()
                view.layer.addSublayer(moveLayer!)
               //  print("new moveLayer")
            }
            moveLayer?.frame = gestureCollectionView.bounds
            moveLayer?.position = gestureCollectionView.center
            moveLayer?.fillColor = nil
            moveLayer?.lineWidth = 6
            moveLayer?.strokeColor = UIColor.green.cgColor
            let path = UIBezierPath()
            path.move(to: currentPoint)
            path.addLine(to: point)
            moveLayer?.path = path.cgPath
            moveLayer?.lineCap = "round"
        }
    }
     // 判斷是否已經滑到 CollectionViewCell 中
    func selectedItem(indexPath: IndexPath) {
        // 首先判斷是否已經選取過該項目
       // print("in collectionViewCell")
        
        if selectedPod.contains(indexPath.row) {
            return }
        let cell = gestureCollectionView.cellForItem(at: indexPath)
        // 畫線到 Cell 的中心
        drawLine(to: cell!.center)
         // 新增pod
        selectedPod.append(indexPath.row)
          // 刪除當前的滑動觸碰連線
        moveLayer?.removeFromSuperlayer()
        moveLayer = nil
         // 3D Touch 震動效果
        AudioServicesPlaySystemSound(1520)
        
        // 這邊我們會根據 Cell 是否被選取顯示不一樣的顏色
        // 所以我們會更新該 indexPath 的項目
        gestureCollectionView.reloadItems(at: [indexPath])
        //   print("更新該 indexPath 的項目"  +   indexPath.description)
    }
    
    func cancel() {
        // 判斷當前的手勢pod為哪個類型
        switch gesturePodType {
            // 設置pod1
        case .setting1:
            // 如果pod超過6碼，那麼就設定成功
            // 反之則會清除pod，讓使用者在試一次
            if selectedPod.count >= 6 {
                pod = selectedPod
                showMessageAlert(message: "請再次確認圖形密碼！")
                    LabelMsg.text = "請再次確認圖形密碼！"
                gesturePodType = GesturePodType.setting2
            } else {
                lineLayers.forEach { (layer) in
                    layer.strokeColor = UIColor.red.cgColor
                }
                gestureCollectionView.visibleCells.forEach { (cell) in
                    cell.layer.borderColor = UIColor.red.cgColor
                }
                moveLayer?.strokeColor = UIColor.red.cgColor
                showMessageAlert(message: "圖型密碼至少需設定6點!")
                  LabelMsg.text = "圖形密碼可代替登入密碼"
            }
        case .setting2:
            if selectedPod == pod {
               // showMessageAlert(message: "圖形密碼設定完成!")
                //let stringRepresentation = pod.description
               // SecurityUtility.utility.writeFileByKey(SecurityUtility.utility.AES256Encrypt("AFISCCOMTW" + stringRepresentation, "\(SEA1)\(SEA2)\(SEA3)") , SetKey: Gesture_Key, setEncryptKey: "\(SEA1)\(SEA2)\(SEA3)")
                
                // open touchid status
                let wkLogInType = "0"
                //wkLogInType = SecurityUtility.utility.readFileByKey( SetKey: bCode  , setDecryptKey: SEA)  as? String ?? "0"
                //when fast login flg is disable ,send 01014 work
                if( wkLogInType == "0"){
                  
                    self.send_confirm()
                }
            } else {
                lineLayers.forEach { (layer) in
                    layer.strokeColor = UIColor.red.cgColor
                }
                gestureCollectionView.visibleCells.forEach { (cell) in
                    cell.layer.borderColor = UIColor.red.cgColor
                }
                moveLayer?.strokeColor = UIColor.red.cgColor
                showMessageAlert(message: "圖形密碼輸入不一致，請重新設定!")
              LabelMsg.text = "圖形密碼可代替登入密碼"
                gesturePodType = GesturePodType.setting1
            }
        }
    }
     
}
