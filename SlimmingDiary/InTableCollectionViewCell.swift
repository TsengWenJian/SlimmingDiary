//
//  InTableCollectionViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/29.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class InTableCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    override func awakeFromNib() {
        
        
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        shadowView.layer.cornerRadius = 5
        
        
    }
    
}
