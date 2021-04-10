//
//  DetailImageTableViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/8/6.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class DetailImageTableViewCell: UITableViewCell {
    @IBOutlet var selectImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
