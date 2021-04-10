//
//  bodyTableViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/6/16.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class BodyTableViewCell: UITableViewCell {
    @IBOutlet var shadowView: UIView!
    @IBOutlet var rightLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var leftImageView: UIImageView!
    @IBOutlet var bodyLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        shadowView.backgroundColor = UIColor.white
        shadowView.setShadowView(0, 0.3, CGSize(width: 1, height: 1))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
