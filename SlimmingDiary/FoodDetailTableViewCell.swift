//
//  FoodDetailTableViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/5/28.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class FoodDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var unit: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    override func awakeFromNib() {
       
        super.awakeFromNib()
        
        dataLabel.layer.borderWidth = 1
        dataLabel.layer.borderColor = UIColor.lightGray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
