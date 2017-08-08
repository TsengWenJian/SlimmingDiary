//
//  CanlenderCollectionViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/6/5.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var shadowView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shadowView.layer.cornerRadius = UIScreen.main.bounds.width/7*0.9/2
               
        
    }

    
    
}
 
   
