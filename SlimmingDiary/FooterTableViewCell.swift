//
//  FooterTableViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/5/26.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class FooterTableViewCell: UITableViewCell {
    @IBOutlet var footerButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var shadowView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()

        shadowView.setShadowView(1, 0.3, CGSize(width: 1, height: 1))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
