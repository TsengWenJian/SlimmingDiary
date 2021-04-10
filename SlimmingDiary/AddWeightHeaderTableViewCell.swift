//
//  AddWeightHeaderTableViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/18.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class AddWeightHeaderTableViewCell: UITableViewCell {
    @IBOutlet var confirmBtn: UIButton!
    @IBOutlet var TitleLabel: UILabel!
    @IBOutlet var cancelBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
