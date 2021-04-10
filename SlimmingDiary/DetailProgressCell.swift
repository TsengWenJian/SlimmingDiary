//
//  DetailProgressCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/6/17.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class DetailProgressCell: UITableViewCell {
    @IBOutlet var circleProgressRate: NickProgressUIView!
    @IBOutlet var proteinLabel: UILabel!
    @IBOutlet var fatLabel: UILabel!
    @IBOutlet var carbohydrateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
