//
//  CustomieCell.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/6/6.
//  Copyright © 2017年 Systex. All rights reserved.
//

import Foundation
import UIKit

class MenuCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var directionImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

class MenuExpandCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

class EditCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var entryImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

protocol OverviewCellDelegate {
    func clickExpandBtn1(_ btn:UIButton, _ value:[String:String])
    func clickExpandBtn2(_ btn:UIButton, _ value:[String:String])
    func endExpanding(_ curRow:IndexPath?)
}

class OverviewCell: UITableViewCell {
    @IBOutlet weak var title1Label: UILabel!
    @IBOutlet weak var title2Label: UILabel!
    @IBOutlet weak var title3Label: UILabel!
    //@IBOutlet weak var title4Label: UILabel! //0810
    @IBOutlet weak var detail1Label: UILabel!
    @IBOutlet weak var detail2Label: UILabel!
    @IBOutlet weak var detail3Label: UILabel!
    //@IBOutlet weak var detail4Label: UILabel! //0810
    @IBOutlet weak var trailingCons: NSLayoutConstraint!
    @IBOutlet weak var leadingCons: NSLayoutConstraint!
    
    private var Button_Width:CGFloat = 0
    private var status:CellStatus = .none
    private var sTrailing:CGFloat = 0
    private var sleading:CGFloat = 0
    private var expandView:ExpandView? = nil
    private var gesture:UIPanGestureRecognizer? = nil
    private var curRow:IndexPath? = nil
    private var delegate:OverviewCellDelegate? = nil
    
    // MARK: - Override
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        sTrailing = trailingCons.constant
        sleading = leadingCons.constant
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == gesture {
            let point = (gestureRecognizer as! UIPanGestureRecognizer).translation(in: contentView)
            let verticalness = abs(point.y)
            if verticalness > 0 {
                return false
            }
        }
        return true
    }
    
    // MARK: - Public
    func AddExpnadBtn(_ delegate:OverviewCellDelegate?, _ type:ActOverviewType, _ isEnable:(Bool,Bool), _ curRow:IndexPath) {
        status = .Hide
        trailingCons.constant = sTrailing
        leadingCons.constant = sleading
        self.curRow = curRow
        self.delegate = delegate
        if gesture == nil {
            gesture = UIPanGestureRecognizer(target: self, action: #selector(HandlePanGesture))
            gesture?.delegate = self
            contentView.addGestureRecognizer(gesture!)
        }
        if expandView == nil {
            expandView = Platform.plat.getUIByID(.UIID_ExpandView, self) as? ExpandView
            expandView?.button1.addTarget(self, action: #selector(clickButton1(_:)), for: .touchUpInside)
            expandView?.button2.addTarget(self, action: #selector(clickButton2(_:)), for: .touchUpInside)
            contentView.addSubview(expandView!)
        }
        
        expandView?.SetStatus(isEnable.0, isEnable.1)
        Button_Width = (type != .Type3 && type != .Type2) ? (expandView?.frame.size.width)! : (expandView?.frame.size.width)!/2
        switch type {
        case .Type2,.Type3: expandView?.SetLabelTitle("往來\n明細", "")
        case .Type4: expandView?.SetLabelTitle("還本\n繳息", "往來\n明細")
        default: expandView?.SetLabelTitle("即時\n轉帳", "往來\n明細")
        }
        expandView?.button1.tag = type.rawValue
        expandView?.button2.tag = type.rawValue
        expandView?.frame = CGRect(x: contentView.frame.maxX, y: 0, width: (expandView?.frame.size.width)!, height: contentView.frame.height-1)
    }
    
    func AddExpnadBtn(_ delegate:OverviewCellDelegate?, _ curRow:IndexPath) {
        status = .Hide
        trailingCons.constant = sTrailing
        leadingCons.constant = sleading
        self.curRow = curRow
        self.delegate = delegate
        if gesture == nil {
            gesture = UIPanGestureRecognizer(target: self, action: #selector(HandlePanGesture))
            gesture?.delegate = self
            contentView.addGestureRecognizer(gesture!)
        }
        if expandView == nil {
            expandView = Platform.plat.getUIByID(.UIID_ExpandView, self) as? ExpandView
            expandView?.button1.addTarget(self, action: #selector(clickButton1(_:)), for: .touchUpInside)
            expandView?.button2.addTarget(self, action: #selector(clickButton2(_:)), for: .touchUpInside)
            contentView.addSubview(expandView!)
        }
        expandView?.SetStatus(true, true)
        Button_Width = (expandView?.frame.size.width)!
        expandView?.SetLabelTitle("定期\n投資", "往來\n明細")
//        expandView?.button1.tag = type.rawValue
//        expandView?.button2.tag = type.rawValue
        expandView?.frame = CGRect(x: contentView.frame.maxX, y: 0, width: (expandView?.frame.size.width)!, height: contentView.frame.height-1)
    }
    
    func showExpandView() {
        if expandView != nil {
            expandView?.frame = CGRect(x: contentView.frame.maxX-Button_Width, y: 0, width: (expandView?.frame.size.width)!, height: contentView.frame.height-1)
            status = .Expand
            trailingCons.constant = sTrailing + Button_Width
            leadingCons.constant = sleading - Button_Width
        }
    }
    
    // MARK: - selector
    @objc func HandlePanGesture(_ sender: UIPanGestureRecognizer)  {
        switch sender.state {
        case .began:
            let poiont = sender.velocity(in: self)
            if status == .Hide && poiont.x < 0  {
               status = .Expanding
            }
            else if status == .Expand && poiont.x > 0 {
                status = .Expanding
            }
            break
        case .changed:
            if status == .Expanding {
                let moveX = sender.translation(in:contentView).x
                if  (expandView?.frame.origin.x)!+moveX >= contentView.frame.maxX-Button_Width && (expandView?.frame.origin.x)!+moveX <= contentView.frame.maxX {
                    expandView?.frame.origin.x += moveX
                    trailingCons.constant -= moveX
                    leadingCons.constant += moveX
                }
                sender.setTranslation(.zero, in: contentView)
            }
            break
        case .ended:
            if status == .Expanding {
                if (expandView?.frame.origin.x)! <= contentView.frame.maxX-Button_Width/2 {
                    expandView?.frame = CGRect(x: contentView.frame.maxX-Button_Width, y: 0, width: (expandView?.frame.size.width)!, height: contentView.frame.height-1)
                    status = .Expand
                    trailingCons.constant = sTrailing + Button_Width
                    leadingCons.constant = sleading - Button_Width
                    delegate?.endExpanding(curRow)
                }
                else {
                    expandView?.frame = CGRect(x: contentView.frame.maxX, y: 0, width: (expandView?.frame.size.width)!, height: contentView.frame.height-1)
                    status = .Hide
                    trailingCons.constant = sTrailing
                    leadingCons.constant = sleading
                    delegate?.endExpanding(nil)
                }
            }
            break
        default:
            break
        }
    }
    
    @objc func clickButton1(_ sender:Any) {
        let btn = sender as! UIButton
        if btn.backgroundColor != Disable_Color {
            delegate?.clickExpandBtn1(sender as! UIButton, [title1Label.text!:detail1Label.text!,title2Label.text!:detail2Label.text!,title3Label.text!:detail3Label.text!])
        }
    }
    
    @objc func clickButton2(_ sender:Any) {
        let btn = sender as! UIButton
        if btn.backgroundColor != Disable_Color {
            delegate?.clickExpandBtn2(sender as! UIButton, [title1Label.text!:detail1Label.text!,title2Label.text!:detail2Label.text!,title3Label.text!:detail3Label.text!])
        }
    }
}

class ResultCell: UITableViewCell {
    @IBOutlet weak var m_lbTitle: UILabel!
    @IBOutlet weak var m_lbData: UILabel!
    @IBOutlet weak var titleWeight: NSLayoutConstraint! // 特殊:為了「農漁會據點」拉的，其餘應該不會變
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func set(_ title:String, _ data:String) {
        m_lbTitle.text = title
        m_lbData.text = data
    }
    
    static func GetStringHeightByWidthAndFontSize(_ content:String, _ width:CGFloat) -> CGFloat {
        //.xib拉的 60:Cell高 171:m_lbTitle的固定寬 剩下數字參考Xib
        let dataWidth = width-171-(15*3)
//        let plusHeight:CGFloat = 17+18
        
        let boundingBox = content.boundingRect(with: CGSize(width: dataWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: Default_Font], context: nil)
        return (boundingBox.height < CGFloat(60) ? CGFloat(60) : boundingBox.height)
    }
}
class ResultCheckCell: UITableViewCell {
    private var isCheckon = true
    @IBOutlet weak var checkoff: UIImageView!
    @IBOutlet weak var m_lbTitle: UILabel!
    @IBOutlet weak var m_lbData: UIButton!
    @IBOutlet weak var titleWeight: NSLayoutConstraint! //
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func set(_ sindex:String ,_ labtxt:String ) {
        m_lbData.tag =  Int(sindex)! + 1
        m_lbTitle.text = labtxt
    }
    @IBAction func clickCheckBtn(_ sender: Any) {
        isCheckon = !isCheckon
        let stag = m_lbData.tag
        if isCheckon {
            checkoff.image = UIImage(named: ImageName.Checkon.rawValue)
            m_lbData.tag = stag + 1
        }
        else {
            checkoff.image = UIImage(named: ImageName.Checkoff.rawValue)
            m_lbData.tag = stag - 1
        }
    }
    
    static func GetStringHeightByWidthAndFontSize(_ content:String, _ width:CGFloat) -> CGFloat {
        //.xib拉的 60:Cell高 171:m_lbTitle的固定寬 剩下數字參考Xib
        let dataWidth = width-171-(15*3)
//        let plusHeight:CGFloat = 17+18
        
        let boundingBox = content.boundingRect(with: CGSize(width: dataWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: Default_Font], context: nil)
        return (boundingBox.height < CGFloat(60) ? CGFloat(60) : boundingBox.height)
    }
}

class ResultEditCell: UITableViewCell {
    @IBOutlet var m_tfEditData: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func set(_ data:String, placeholder:String = "請輸入金額") {
        m_tfEditData.text = data
        m_tfEditData.placeholder = placeholder
    }

}

class NTRationCell: UITableViewCell {
    @IBOutlet weak var m_lbTitle: UILabel!
    @IBOutlet weak var m_lbData1: UILabel!
    @IBOutlet weak var m_lbData2: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setData(_ title:String, _ data1:String, _ data2:String) {
        m_lbTitle.text = title
        m_lbData1.text = data1
        m_lbData2.text = data2
    }
}

class LoanPrincipalInterestCell: UITableViewCell {
//    let patBtn_Color = UIColor(red: 130/255, green: 179/255, blue: 66/255, alpha: 1)
    let patBtn_Color = Green_Color
    @IBOutlet weak var calculatePeriodLabel: UILabel!
    @IBOutlet weak var principalInterestLabel: UILabel!
    @IBOutlet weak var breachContractLabel: UILabel!
    @IBOutlet weak var delayInterestLabel: UILabel!
    @IBOutlet weak var payBtn: UIButton!
    @IBOutlet weak var entryRightImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        payBtn.layer.cornerRadius = Layer_BorderRadius
        payBtn.layer.borderWidth = Layer_BorderWidth
        payBtn.layer.borderColor = patBtn_Color.cgColor
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
//2019-10-4 add by sweney 常用轉入帳號
protocol USAccountCellDelegate {
    func clickDelBtn(_ sender:USAccountViewCell)
    
}
class USAccountViewCell: UITableViewCell {
    //    let patBtn_Color = UIColor(red: 130/255, green: 179/255, blue: 66/255, alpha: 1)
    let patBtn_Color = Green_Color
    @IBOutlet weak var bankcodeLabel: UILabel!
    @IBOutlet weak var bankNameLabel: UILabel!
    @IBOutlet weak var AccountLabel: UILabel!
    @IBOutlet weak var RemarkLabel: UILabel!
    @IBOutlet weak var btnDel: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnEdit.layer.cornerRadius = Layer_BorderRadius
        btnEdit.layer.borderWidth = Layer_BorderWidth
        btnEdit.layer.borderColor = patBtn_Color.cgColor
     
        btnDel.layer.cornerRadius = Layer_BorderRadius
        btnDel.layer.borderWidth = Layer_BorderWidth
        btnDel.layer.borderColor = patBtn_Color.cgColor
        
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
  
    
}
//2019-10-4 end
class TodayBillQryCell:UITableViewCell {
    
    @IBOutlet weak var CKNOLabel: UILabel!
    @IBOutlet weak var ERRCODECLabel: UILabel!
    @IBOutlet weak var TXAMTLabel: UILabel!
    @IBOutlet weak var STATUSTLabel: UILabel!
}

protocol CardlessDisableCellDelegate {
    func clickDelBtn(_ sender:CardlessDisableCell)
    
}
class CardlessDisableCell:UITableViewCell{
    let patBtn_Color = Orange_Color
   
    
    @IBOutlet weak var CardlessAct: UILabel!
    @IBOutlet weak var CardlessDisableBtn: UIButton!
    @IBOutlet weak var CardlessStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        CardlessDisableBtn.setBackgroundImage(UIImage(named: "ButtonSmall"), for: .normal)
        CardlessDisableBtn.setTitleColor(UIColor.white, for: .normal)
        CardlessDisableBtn.layer.borderWidth = 0
        CardlessDisableBtn.layer.borderColor = patBtn_Color.cgColor
         
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

class CardlessQryCell:UITableViewCell {
    
    @IBOutlet weak var CDATELabel: UILabel!
    @IBOutlet weak var CLTXAMTLabel: UILabel!
    @IBOutlet weak var CLSTATUSTLabel: UILabel!
    
    @IBOutlet weak var EntryRight: UIImageView!
}
class PromotionCell: UITableViewCell {
    @IBOutlet weak var m_lbTitle: UILabel!
    @IBOutlet weak var m_lbDate: UILabel!
    @IBOutlet weak var m_lbPlace: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    func setData(_ title:String, _ date:String, _ place:String) {
        m_lbTitle.text = title
        m_lbDate.text = date
        m_lbPlace.text = place
    }
}

class NewsCell: UITableViewCell {
    @IBOutlet weak var m_lbTitle: UILabel!
    @IBOutlet weak var m_lbDateTitle: UILabel!
    @IBOutlet weak var m_lbDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    func setData(_ title:String, _ dateTitle:String, _ date:String) {
        m_lbTitle.text = title
        m_lbDateTitle.text = dateTitle
        m_lbDate.text = date
    }
}

class ServiceBaseCell: UITableViewCell {
    @IBOutlet weak var m_lbTitle: UILabel!
    @IBOutlet weak var m_lbAddress: UILabel!
    @IBOutlet weak var m_lbDistance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    func setData(_ title:String, _ address:String, _ distance:String) {
        m_lbTitle.text = title
        m_lbAddress.text = address
        m_lbDistance.text = distance
    }
}

class ExchangeRateCell: UITableViewCell {
    @IBOutlet weak var m_lbTitle: UILabel!
    @IBOutlet weak var m_lbData1: UILabel!
    @IBOutlet weak var m_lbData2: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setData(_ title:String, _ data1:String, _ data2:String) {
        m_lbTitle.text = title
        m_lbData1.text = data1
        m_lbData2.text = data2
    }
}

class GPTransactionDetailCell: UITableViewCell {
//    var m_dicData: [String:String] = [String:String]()
    var m_objDetailData: GPTransactionDetailData? = nil
    var getDetail: ((Int)->())? = nil
    @IBOutlet var m_lbAmountTitle: UILabel!
    @IBOutlet var m_lbTradeDate: UILabel!
    @IBOutlet var m_lbCheckMark: UILabel!
    @IBOutlet var m_lbAmount: UILabel!
    @IBOutlet var m_lbBalance: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func set(_ data: GPTransactionDetailData, _ getDetail: ((Int)->())?, _ tag: Int) {
        m_objDetailData = data
        self.getDetail = getDetail
        m_lbAmountTitle.text = m_objDetailData?.CRDB == "1" ? "賣出量(克)" : "買進量(克)"
        m_lbTradeDate.text = m_objDetailData?.TXDAY
        m_lbCheckMark.text = m_objDetailData?.HCODE == "0" ? "-" : "更"
        m_lbAmount.text = m_objDetailData?.TXQTY.separatorThousandDecimal()
        m_lbBalance.text = m_objDetailData?.AVBAL.separatorThousandDecimal()
        self.tag = tag
    }
    @IBAction func m_btnDetailClick(_ sender: Any) {
        guard self.getDetail != nil else {
            NSLog("GPTransactionDetailCell[%d]", self.tag)
            return
        }
        self.getDetail!(self.tag)
    }
}

class GPGoldPriceCell: UITableViewCell {
    @IBOutlet var m_lbDate: UILabel!
    @IBOutlet var m_lbTime: UILabel!
    @IBOutlet var m_lbBuy: UILabel!
    @IBOutlet var m_lbSell: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func set(_ date: String, _ time: String, _ buy: String, _ sell: String) {
        m_lbDate.text = date
        m_lbTime.text = time
        m_lbBuy.text = buy
        m_lbSell.text = sell
    }
    
}
class GesturePwdCell: UICollectionViewCell {
    
} 
class InitTransToCell: UITableViewCell {

    @IBOutlet weak var LabelBank: UILabel!
    @IBOutlet weak var LabelActNo: UILabel!
    @IBOutlet weak var LabelRemark: UILabel!
    @IBOutlet weak var LabelSort: UILabel!
    @IBOutlet weak var btnDel: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
 
    }
    

}
class OtpDeviceToCell: UITableViewCell {
    
    let patBtn_Color = Green_Color
    @IBOutlet weak var labelMobileType: UILabel!
    @IBOutlet weak var labelDeviceRemark: UILabel!
    @IBOutlet weak var labelCreateDate: UILabel!
    @IBOutlet weak var btnDel: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnEdit.layer.cornerRadius = Layer_BorderRadius
               btnEdit.layer.borderWidth = Layer_BorderWidth
               btnEdit.layer.borderColor = patBtn_Color.cgColor
            
               btnDel.layer.cornerRadius = Layer_BorderRadius
               btnDel.layer.borderWidth = Layer_BorderWidth
               btnDel.layer.borderColor = patBtn_Color.cgColor
               
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
//chris
class TXMEMOCell: UITableViewCell {
    @IBOutlet weak var ScanTXMEMO: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func set(_ data:String, placeholder:String = "請輸入備註") {
        let newdata =  data.replacingOccurrences(of: "\n", with: " ")
        ScanTXMEMO.text = newdata
        ScanTXMEMO.placeholder = placeholder
    }
}
//sweney
class TXMEMOCell2: UITableViewCell {
    @IBOutlet weak var ScanTXMEMO2: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func set(_ data:String, placeholder:String = "請輸入轉入備註") {
        let newdata =  data.replacingOccurrences(of: "\n", with: " ")
        ScanTXMEMO2.text = newdata
        ScanTXMEMO2.placeholder = placeholder
    }
}
class TXMEMOCell1: UITableViewCell {
    @IBOutlet weak var ScanTXMEMO1: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func set(_ data:String, placeholder:String = "請輸入轉出備註") {
        let newdata =  data.replacingOccurrences(of: "\n", with: " ")
        ScanTXMEMO1.text = newdata
        ScanTXMEMO1.placeholder = placeholder
    }
}
class TXMobileCell: UITableViewCell {
    @IBOutlet weak var ScanTXMobile: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func set(_ data:String, placeholder:String = "請輸入手機門號") {
        ScanTXMobile.text = data
        ScanTXMobile.placeholder = placeholder
    }
}
class TXMBarcodeCell: UITableViewCell {
    
    @IBOutlet weak var ScanTXMBarcode: TextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func set(_ data:String, placeholder:String = "請輸入發票載具條碼") {
        ScanTXMBarcode.text = data
        ScanTXMBarcode.placeholder = placeholder
    }
}

class GPRiskChekCell:UITableViewCell  {
    @IBOutlet var genderRadioButtons: [SKRadioButton]!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var Radio1: SKRadioButton!
    @IBOutlet weak var Radio2: SKRadioButton!
    @IBOutlet weak var Radio3: SKRadioButton!
    @IBOutlet weak var Radio4: SKRadioButton!
    @IBOutlet weak var Radio5: SKRadioButton!
    
    @IBAction func genderRadioButtondAction(_ sender: SKRadioButton) {
        genderRadioButtons.forEach { (button) in
            button.isSelected = false
        }
        sender.isSelected = true
      
    }
    @IBAction  func textchange (_ sender: SKRadioButton, text:String){
        sender.titleText = text
    }
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        // Configure the view for the selected state
//    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        Radio1.isHidden = true
        Radio2.isHidden = true
        Radio3.isHidden = true
        Radio4.isHidden = true
        Radio5.isHidden = true
       
    }
    
}


class GPRiskMulitChekCell:UITableViewCell  {
    
    @IBOutlet var genderRadioButtonsC:[SKcheckButton]!
    @IBOutlet weak var Titlelable: UILabel!
    @IBOutlet weak var checkbox1: SKcheckButton!

    @IBOutlet weak var checkbox2: SKcheckButton!
    @IBOutlet weak var checkbox3: SKcheckButton!
    @IBOutlet weak var checkbox4: SKcheckButton!
    @IBOutlet weak var checkbox5: SKcheckButton!
    @IBOutlet weak var checkbox6: SKcheckButton!
    @IBOutlet weak var checkbox7: SKcheckButton!
    @IBOutlet weak var checkbox8: SKcheckButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
            checkbox1.isHidden = true
            checkbox2.isHidden = true
            checkbox3.isHidden = true
            checkbox4.isHidden = true
            checkbox5.isHidden = true
            checkbox6.isHidden = true
            checkbox7.isHidden = true
            checkbox8.isHidden = true
}
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        // Configure the view for the selected state
//    }
 
    
    @IBAction func genderRadioButtondActionC(_ sender: SKcheckButton) {
        if sender.isSelected == false{
        sender.isSelected = true
        }else{
            sender.isSelected = false
        }
        genderRadioButtonsC.forEach { (button) in
            
            if (button.isSelected == true)
            {
               
            }

        }
     
      
}
 
}
