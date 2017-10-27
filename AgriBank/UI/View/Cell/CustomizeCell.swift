//
//  CustomieCell.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/6/6.
//  Copyright © 2017年 Systex. All rights reserved.
//

import Foundation

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
    @IBOutlet weak var detail1Label: UILabel!
    @IBOutlet weak var detail2Label: UILabel!
    @IBOutlet weak var detail3Label: UILabel!
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
    
    func showExpandView() {
        if expandView != nil {
            expandView?.frame = CGRect(x: contentView.frame.maxX-Button_Width, y: 0, width: (expandView?.frame.size.width)!, height: contentView.frame.height-1)
            status = .Expand
            trailingCons.constant = sTrailing + Button_Width
            leadingCons.constant = sleading - Button_Width
        }
    }
    
    // MARK: - selector
    func HandlePanGesture(_ sender: UIPanGestureRecognizer)  {
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
    
    func clickButton1(_ sender:Any) {
        let btn = sender as! UIButton
        if btn.backgroundColor != Disable_Color {
            delegate?.clickExpandBtn1(sender as! UIButton, [title1Label.text!:detail1Label.text!,title2Label.text!:detail2Label.text!,title3Label.text!:detail3Label.text!])
        }
    }
    
    func clickButton2(_ sender:Any) {
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
        
        let boundingBox = content.boundingRect(with: CGSize(width: dataWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSFontAttributeName: Default_Font], context: nil)
        return (boundingBox.height < CGFloat(60) ? CGFloat(60) : boundingBox.height)
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
        m_lbTitle.font = Scale_Default_Font
        m_lbData1.font = Scale_Default_Font
        m_lbData2.font = Scale_Default_Font
    }
}

class LoanPrincipalInterestCell: UITableViewCell {
    let patBtn_Color = UIColor(red: 130/255, green: 179/255, blue: 66/255, alpha: 1)
    @IBOutlet weak var calculatePeriodLabel: UILabel!
    @IBOutlet weak var principalInterestLabel: UILabel!
    @IBOutlet weak var breachContractLabel: UILabel!
    @IBOutlet weak var delayInterestLabel: UILabel!
    @IBOutlet weak var payBtn: UIButton!
    
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
