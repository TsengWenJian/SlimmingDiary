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
    @IBOutlet weak var data: UITextField!

    @IBOutlet weak var dataButton: UIButton!
    @IBOutlet weak var dataLabel: UILabel!
    override func awakeFromNib() {
       
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
