//
//  ShowRecordsTableViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/31.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class ShowRecordsTableViewCell: UITableViewCell {
    @IBOutlet var titleImageView: AdvanceImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var userPhotoImageView: AdvanceImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var shadowView: UIView!
    @IBOutlet var detailLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        userPhotoImageView.layer.borderColor = UIColor.white.cgColor
        titleImageView.layer.cornerRadius = 5
        shadowView.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
