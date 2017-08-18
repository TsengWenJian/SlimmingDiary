//
//  WeightDiaryBodyTableViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/20.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class WeightDiaryBodyTableViewCell: UITableViewCell {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        shadowView.setShadowView(0, 0.3, CGSize(width: 1, height: 1))
        
     
    }
   
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
