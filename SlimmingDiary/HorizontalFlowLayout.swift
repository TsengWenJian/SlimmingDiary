//
//  HorizontalFlowLayout.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/19.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class HorizontalFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        self.scrollDirection = .horizontal
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.scrollDirection = .horizontal
    }
    
       
    
    
    
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        
//        
//        let array = super.layoutAttributesForElements(in: rect)
//        
//        
//        let centerX = (self.collectionView?.contentOffset.x)! + (self.collectionView?.frame.size.width)! * 0.5;
//        
//        for attrs in array!{
//            
//            // cell的中心点x 和 collectionView最中心点的x值 的间距
//            let distance = abs(attrs.center.x - centerX);
//            // 设置缩放比例
//            
//            print(distance)
//
//            
//            let normalizedDistance = distance / 80;
//            
//            if (abs(distance) < 100) {
//                let zoom = 1 + 0.5 * (1 - abs(normalizedDistance)); //放大渐变
//                attrs.transform3D = CATransform3DMakeScale(zoom, zoom, 1.0);
//                attrs.zIndex = 1;
//                attrs.alpha = 1.0;
//                
//                
//                
//            }
//            
//        }
//        return array
//    }
    
    
    
    
    
    
}








