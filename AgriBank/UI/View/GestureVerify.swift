//
//  GestureVerify.swift
//  AgriBank
//
//  Created by ABOT on 2022/3/21.
//  Copyright © 2022 Systex. All rights reserved.
//
import UIKit
import AudioToolbox

protocol GestureVerifyDelegate {
    func clickGestureVerCloseBtn(_ ClossStatus:Bool)
    func GestureVerifyBtn(bankCode:String,success:NSInteger)
}


class GestureVerify: UIView  {
    
    var m_BankCode: String = ""
    var m_account:String = ""
    
    var delegate:GestureVerifyDelegate? = nil
    
    private var currentPoint: CGPoint?
    var pod = "" // 記錄設定密碼
    private var selectedPod = [Int]()// 當前畫出的密碼
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
    
    //關閉圖形驗證 Ｘ
    @IBAction func clickClosePBtn(_ sender: Any) {
        delegate?.clickGestureVerCloseBtn(true)
    }
    //關閉圖形驗證 取消
    @IBAction func clickCloseBtn(_ sender: Any) {
        delegate?.clickGestureVerCloseBtn(true)
    }
    @IBOutlet weak var ContentView: UIView!
    @IBOutlet weak var gestureCollectionView: GestureCollectionView!
    
    
    // MARK: - Override
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Do any additional setup after loading the view.
        
        
        //增加cell
        gestureCollectionView.register(GesturePwdCell.self, forCellWithReuseIdentifier:cellID)
        ContentView.layer.cornerRadius = Layer_BorderRadius //圓角
        gestureCollectionView.dataSource = self
        gestureCollectionView.delegate = self
        gestureCollectionView.gestureDelegate = self
        gestureCollectionView.isUserInteractionEnabled = false //讓觸碰效果更好一些
        
        FastLogIn_Type = "2"  // 0:pod  *1:touchid/faceid 2:picture
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
            shapeLayer.lineCap = .round
            ContentView.layer.addSublayer(shapeLayer)
            // 將我們的 layer 加入到 lineLayers
            //之後當我們畫線結束後會刪除裡面所有 layer
            lineLayers.append(shapeLayer)
            //   print("new point:X=" + point.x.description  + "Y=" +  point.y.description)
        }
        // 將當前座標設定為選擇到的座標
        currentPoint = point
        // print("set point:X=" +  point.x.description + "Y=" +  point.y.description)
    }
    //手勢移動時
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        gestureCollectionView.touchesMoved(touches, with: event)
        
    }
    //圖形化完
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        gestureCollectionView.touchesEnded(touches, with: event)
        // print(" touch end ")
    }
    //圖形化完
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)  {
        gestureCollectionView.touchesMoved(touches, with: event)
        //print(" touch touchesBegan ")
    }
    
    func showMessageAlert(message: String) {
        let alert = UIAlertView(title: UIAlert_Default_Title, message: message, delegate: nil, cancelButtonTitle:Determine_Title)
        alert.show()
        self.lineLayers.forEach { (layer) in
            layer.removeFromSuperlayer()
        }
        self.lineLayers.removeAll()
        self.selectedPod.removeAll()
        self.gestureCollectionView.reloadSections(IndexSet(integer: 0))
        self.currentPoint = nil
        self.moveLayer?.removeFromSuperlayer()
        self.moveLayer = nil
    }
}

extension GestureVerify: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return row * row
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
        cell.sizeToFit()
        cell.tag = indexPath.row
        cell.layer.cornerRadius = cell.bounds.height / 2
        cell.layer.borderColor = !selectedPod.contains(indexPath.row) ? UIColor.init(red: 30/255, green: 144/255, blue: 1, alpha: 1).cgColor : UIColor.green.cgColor
        cell.layer.borderWidth = 6
        // print("cell:" + String( indexPath.row ))
        return cell
    }
}

extension GestureVerify: UICollectionViewDelegate {
    
}

extension GestureVerify: UICollectionViewDelegateFlowLayout {
    
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

extension GestureVerify: GestureCollectionViewDelegate {
    // 讓手指碰觸點與前一個點產生連線(與畫線大同小異，只是只會在畫面上加入一次)
    func move(point: CGPoint) {
        // 如果前一個點存在
        if let currentPoint = currentPoint {
            // print("前一個點:X=" +  currentPoint.x.description + "Y=" +  currentPoint.y.description)
            // 判斷目前與手指的連線是否存在
            // 若無則新增一個 CAShapeLayer
            if moveLayer == nil {
                moveLayer = CAShapeLayer()
                ContentView.layer.addSublayer(moveLayer!)
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
            moveLayer?.lineCap = .round
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
        // 新增密碼
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
        let gestureErCntr = SecurityUtility.utility.readFileByKey(SetKey: "GestureEr", setDecryptKey: "\(SEA1)\(SEA2)\(SEA3)") as? String ?? "0"
        
        let wkpod  = pod
        // wkpod = SecurityUtility.utility.readFileByKey(SetKey: Gesture_Key, setDecryptKey: "\(SEA1)\(SEA2)\(SEA3)") as! String
        
        var ckpod = ""
        ckpod = SecurityUtility.utility.AES256Encrypt("AFISCCOMTW" + selectedPod.description, "\(SEA1)\(SEA2)\(SEA3)")
        if ckpod == wkpod  {
            //圖形密碼正確
            SecurityUtility.utility.writeFileByKey("0", SetKey: "GestureEr", setEncryptKey: "\(SEA1)\(SEA2)\(SEA3)")
            self.delegate?.clickGestureVerCloseBtn(true)
            if let info = AuthorizationManage.manage.GetLoginInfo() {
                self.delegate?.GestureVerifyBtn(bankCode:info.bankCode, success: 1)
            }
        } else {
            lineLayers.forEach { (layer) in
                layer.strokeColor = UIColor.red.cgColor
            }
            gestureCollectionView.visibleCells.forEach { (cell) in
                cell.layer.borderColor = UIColor.red.cgColor
            }
            moveLayer?.strokeColor = UIColor.red.cgColor
            showMessageAlert(message: "圖形密碼輸入錯誤！請以使用者密碼驗證交易！")
            if let info = AuthorizationManage.manage.GetLoginInfo() {
            self.delegate?.GestureVerifyBtn(bankCode:info.bankCode, success: 0)
            }
        }
    }
}
