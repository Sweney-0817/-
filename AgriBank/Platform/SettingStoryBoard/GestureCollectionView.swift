//
//  GestureCollectionView.swift
//  GesturePod
//
//  Created by JeremyXue on 2019/4/12.
//  Copyright © 2019 JeremyXue. All rights reserved.
//

import UIKit

protocol GestureCollectionViewDelegate: AnyObject {
    func move(point: CGPoint)
    func selectedItem(indexPath: IndexPath)
    func cancel()
}

class GestureCollectionView: UICollectionView {
    
    weak var gestureDelegate: GestureCollectionViewDelegate?
    
 
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self) {
            if let indexPath = self.indexPathForItem(at: point) {
                gestureDelegate?.selectedItem(indexPath: indexPath)
            } else {
                gestureDelegate?.move(point: point)
                // print("gestureDelegate move :" +  point.x.description  +   point.y.description)
            }
        }
    }
    
 open   override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        gestureDelegate?.cancel()
         // print("gestureDelegate cancel")
    }
    
    open   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      
        gestureDelegate?.cancel()
      //  print("gestureDelegate touchesBegan")
    }
}
