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

let FeatureWall_PageControl_BottomDistance:CGFloat = 30
let FeatureWall_PageControl_currentPageColor = UIColor(red: 69/255, green: 166/255, blue: 108/255, alpha:1)
let FeatureWall_PageControl_PageColor = UIColor(red: 69/255, green: 166/255, blue: 108/255, alpha:0.2)

class FeatureWallView: UIView, UIScrollViewDelegate {
    let scrollview = UIScrollView()
    var pageCon = UIPageControl()
    var featureIDList = [PlatformFeatureID]()
    var featureDelegate:FeatureWallViewDelegate? = nil
    var vertical = 0
    var horizontal = 0
    
    override func layoutSubviews() {
        scrollview.frame = frame
        scrollview.frame.size.height = frame.size.height - FeatureWall_PageControl_BottomDistance/2
        scrollview.frame.origin = .zero
        addSubview(scrollview)
        pageCon.frame.origin.y = frame.size.height - FeatureWall_PageControl_BottomDistance
        pageCon.frame.origin.x = frame.size.width/2 - pageCon.frame.size.width/2
        setFeatureWall(vertical, horizontal)
        addSubview(pageCon)
    }
    
    // MARK: - public
    func setInitial(_ list: [PlatformFeatureID], setVertical vertical: Int, setHorizontal horizontal: Int, SetDelegate delegate:FeatureWallViewDelegate) {
        featureIDList = list
        featureDelegate = delegate
        self.vertical = vertical
        self.horizontal = horizontal
        scrollview.bounces = false
        scrollview.isPagingEnabled = true
        scrollview.delegate = self
        scrollview.showsHorizontalScrollIndicator = false
        
        pageCon.numberOfPages = list.count%(vertical*horizontal) == 0 ? list.count/(vertical*horizontal) : list.count/(vertical*horizontal)+1
        pageCon.frame.size = pageCon.size(forNumberOfPages: pageCon.numberOfPages)
        pageCon.currentPageIndicatorTintColor = FeatureWall_PageControl_currentPageColor
        pageCon.pageIndicatorTintColor = FeatureWall_PageControl_PageColor
        pageCon.hidesForSinglePage = true
    }
    
    func setContentList(_ list: [PlatformFeatureID] ) {
        featureIDList = list
        setFeatureWall(vertical, horizontal)
        pageCon.numberOfPages = list.count%(vertical*horizontal) == 0 ? list.count/(vertical*horizontal) : list.count/(vertical*horizontal)+1
    }

    // MARK: - private
    private func setFeatureWall(_ vertical: Int, _ horizontal: Int)  {
        scrollview.subviews.forEach{ view in if view is FeatureWallCellView {view.removeFromSuperview()} }
        let page = CGFloat( featureIDList.count%(vertical*horizontal) == 0 ? featureIDList.count/(vertical*horizontal) : featureIDList.count/(vertical*horizontal)+1 )
        scrollview.contentSize = CGSize(width: scrollview.frame.size.width*page, height: scrollview.frame.size.height)
        if vertical != 0 && horizontal != 0 {
            let width = scrollview.frame.size.width / CGFloat(vertical)
            let height = scrollview.frame.size.height / CGFloat(horizontal)
            for current in 0...featureIDList.count-1 {
                let position = getXYPositionByIndex(current, vertical, horizontal)
                let wallCell = Platform.plat.getUIByID(.UIID_FeatureWallCell, self) as! FeatureWallCellView
                wallCell.frame = CGRect(x: CGFloat(position.x)*width + CGFloat(position.page)*scrollview.frame.size.width, y: CGFloat(position.y)*height, width: width, height: height)
                if let info = Platform.plat.getFeatureInfoByID(featureIDList[current]) {
                    wallCell.imageView.image = UIImage(named: String(featureIDList[current].rawValue))
                    wallCell.titleLabel.text = info.name
                    wallCell.button.addTarget(self, action: #selector(clickFeatureBtn(_:)), for: .touchUpInside)
                    wallCell.button.tag = featureIDList[current].rawValue
                }
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
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageCon.currentPage = Int(scrollview.contentOffset.x / UIScreen.main.bounds.size.width)
    }
}

class FeatureWallCellView: UIView {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
}
