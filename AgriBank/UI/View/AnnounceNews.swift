//
//  AnnounceNews.swift
//  BankBase
//
//  Created by TongYoungRu on 2017/5/15.
//  Copyright © 2017年 TongYoungRu. All rights reserved.
//

import UIKit

let AnnounceNews_Repeat_Time:TimeInterval = 5
let AnnounceNews_Cell_Identify = "newsCell"

protocol AnnounceNewsDelegate {
    func clickNews(_ index:Int)
}

@objcMembers
class AnnounceNews: UIView, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var newsTableView: UITableView!
    private var list:[String]? = nil
    private var delegate:AnnounceNewsDelegate? = nil
    private var curTimer:Timer? = nil
    
    // MARK: - Public
    func setContentList(_ list:[String], _ delegate:AnnounceNewsDelegate? = nil) {
        self.list = list
        newsTableView.reloadData()
        if curTimer == nil {
            curTimer = Timer.scheduledTimer(timeInterval: AnnounceNews_Repeat_Time, target: self, selector: #selector(scrollNewsView(_:)), userInfo: nil, repeats: true)
        }
        self.delegate = delegate
    }
    
    func scrollNewsView(_ theTimer:Timer) {
        if list != nil && (list?.count)! > 1 {
            let lastIndexPath = newsTableView.indexPathsForVisibleRows?.last
            let scrollIndexPath = IndexPath(row:((lastIndexPath?.row)!+1 < (list?.count)! ? (lastIndexPath?.row)!+1 : 0), section: 0)
            newsTableView.scrollToRow(at: scrollIndexPath, at: .top, animated: (scrollIndexPath.row == 0 ? false: true))
        }
        else {
            curTimer?.invalidate()
            curTimer = nil
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.clickNews(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: AnnounceNews_Cell_Identify)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: AnnounceNews_Cell_Identify)
            cell?.backgroundColor = .clear
            cell?.selectionStyle = .none
        }
//        cell?.textLabel?.attributedText = NSAttributedString(string: list?[indexPath.row] ?? "", attributes: [NSFontAttributeName:Default_Font,NSForegroundColorAttributeName:UIColor.white])
        cell?.textLabel?.attributedText = NSAttributedString(string: list?[indexPath.row] ?? "", attributes:[NSAttributedStringKey.font:Default_Font,NSAttributedStringKey.foregroundColor:UIColor.init(red: 156.0/255.0, green: 98.0/255.0, blue: 47.0/255.0, alpha: 1.0)])
        
        return cell!
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        if list != nil {
            return 1
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if list != nil {
            return (list?.count)!
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.frame.height
    }
}
