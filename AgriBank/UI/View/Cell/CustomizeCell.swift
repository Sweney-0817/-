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
    func clickTransBtn()
    func clickDetailBtn()
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
    private var transBtn:UIButton? = nil
    private var detailBtn:UIButton? = nil
    private var Button_Width:CGFloat = 0
    private var status:CellStatus = .none
    private var sTrailing:CGFloat = 0
    private var sleading:CGFloat = 0
    private var expandView:ExpandView? = nil
    private var gesture:UIPanGestureRecognizer? = nil
    var delegate:OverviewCellDelegate? = nil
    
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
    
    func AddExpnadBtn(_ delegate:OverviewCellDelegate?) {
        status = .Hide
        trailingCons.constant = sTrailing
        leadingCons.constant = sleading
        self.delegate = delegate
        if gesture == nil {
            gesture = UIPanGestureRecognizer(target: self, action: #selector(HandlePanGesture))
            gesture?.delegate = self
            contentView.addGestureRecognizer(gesture!)
        }
        if expandView == nil {
            expandView = Platform.plat.getUIByID(.UIID_ExpandView, self) as? ExpandView
            Button_Width = (expandView?.frame.width)!
            expandView?.transBtn.addTarget(self, action: #selector(clickTransBtn(_:)), for: .touchUpInside)
            expandView?.detailBtn.addTarget(self, action: #selector(clickDetailBtn(_:)), for: .touchUpInside)
            contentView.addSubview(expandView!)
        }
        expandView?.frame = CGRect(x: contentView.frame.maxX, y: 0, width: Button_Width, height: contentView.frame.height-1)
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
                    expandView?.frame = CGRect(x: contentView.frame.maxX-Button_Width, y: 0, width: Button_Width, height: contentView.frame.height-1)
                    status = .Expand
                    trailingCons.constant = sTrailing + Button_Width
                    leadingCons.constant = sleading - Button_Width
                }
                else {
                    expandView?.frame = CGRect(x: contentView.frame.maxX, y: 0, width: Button_Width, height: contentView.frame.height-1)
                    status = .Hide
                    trailingCons.constant = sTrailing
                    leadingCons.constant = sleading
                }
            }
            break
        default:
            break
        }
    }
    
    func clickTransBtn(_ sender:Any) {
        delegate?.clickTransBtn()
    }
    
    func clickDetailBtn(_ sender:Any) {
        delegate?.clickDetailBtn()
    }
}

class ResultCell: UITableViewCell {
    @IBOutlet weak var m_lbTitle: UILabel!
    @IBOutlet weak var m_lbData: UILabel!
    
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
        //.xib拉的
        let dataWidth = width-117-(15*3)
        let plusHeight:CGFloat = 17+18
        
//        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: dataWidth, height: CGFloat.greatestFiniteMagnitude))
//        label.numberOfLines = 0
//        label.lineBreakMode = NSLineBreakMode.byWordWrapping//        label.font = UIFont.systemFont(ofSize: 18.0)
//        label.text = content
//        label.sizeToFit()
//        return label.frame.height+plusHeight
        
        let boundingBox = content.boundingRect(with: CGSize(width: dataWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 19.0)], context: nil)
        return boundingBox.height+plusHeight
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
