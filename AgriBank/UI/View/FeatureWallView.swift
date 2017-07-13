//
//  FeatureWallView.swift
//  BankBase
//
//  Created by TongYoungRu on 2017/5/16.
//  Copyright © 2017年 TongYoungRu. All rights reserved.
//

import UIKit

protocol FeatureWallViewDelegate {
    func clickFeatureBtn(_ ID: PlatformFeatureID)
}

class FeatureWallView: UIView {
    let imageView = UIImageView()
    let scrollview = UIScrollView()
    var featureIDList = [PlatformFeatureID]()
    var featureDelegate:FeatureWallViewDelegate? = nil
    var vertical = 0
    var horizontal = 0
    
    override func layoutSubviews() {
        imageView.frame = frame
        imageView.frame.origin = .zero
        scrollview.frame = frame
        scrollview.frame.origin = .zero
        setFeatureWall(vertical, horizontal)
    }
    
    // MARK: - public
    func setInitial(_ list: [PlatformFeatureID], setVertical vertical: Int, setHorizontal horizontal: Int, SetDelegate delegate:FeatureWallViewDelegate) {
        featureIDList = list
        featureDelegate = delegate
        self.vertical = vertical
        self.horizontal = horizontal
        addSubview(imageView)
        scrollview.bounces = false
        scrollview.isPagingEnabled = true
        addSubview(scrollview)
    }
    
    func setBackgroundImage(_ image: UIImage?) {
        imageView.image = image
    }
    
    func setContentList(_ list: [PlatformFeatureID] ) {
        featureIDList = list
        setFeatureWall(vertical, horizontal)
    }

    // MARK: - private
    private func setFeatureWall(_ vertical: Int, _ horizontal: Int)  {
        scrollview.subviews.forEach{ view in if view is FeatureWallCellView {view.removeFromSuperview()} }
        let page = CGFloat( featureIDList.count%(vertical*horizontal) == 0 ? featureIDList.count/(vertical*horizontal) : featureIDList.count/(vertical*horizontal)+1 )
        scrollview.contentSize = CGSize(width: frame.width*page, height: frame.height)
        if vertical != 0 && horizontal != 0 {
            let width = frame.width / CGFloat(vertical)
            let height = frame.height / CGFloat(horizontal)
            for current in 0...featureIDList.count-1 {
                let position = getXYPositionByIndex(current, vertical, horizontal)
                let wallCell = Platform.plat.getUIByID(.UIID_FeatureWallCell, self) as! FeatureWallCellView
                wallCell.frame = CGRect(x: CGFloat(position.x)*width + CGFloat(position.page)*frame.width, y: CGFloat(position.y)*height, width: width, height: height)
                wallCell.imageView.image = UIImage(named: String(featureIDList[current].rawValue))
                wallCell.titleLabel.text = Platform.plat.getFeatureNameByID(featureIDList[current])
                wallCell.button.addTarget(self, action: #selector(clickFeatureBtn(_:)), for: .touchUpInside)
                wallCell.button.tag = featureIDList[current].rawValue
                scrollview.addSubview(wallCell)
            }
        }
    }
    
    private func getXYPositionByIndex(_ index: Int, _ vertical: Int, _ horizontal: Int) -> (x: Int, y: Int, page: Int) {
        let pageCount = vertical * horizontal
        let page = index / pageCount
        let x = index % vertical
        let y = (index % pageCount) / vertical
        return (x, y, page)
    }
    
    // MARK: - selector
    func clickFeatureBtn(_ sender:UIButton)  {
        featureDelegate?.clickFeatureBtn(PlatformFeatureID(rawValue: sender.tag)!)
    }
}

class FeatureWallCellView: UIView {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
}
