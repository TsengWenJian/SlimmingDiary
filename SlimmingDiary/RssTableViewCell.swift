//
//  RssTableViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/9.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class RssTableViewCell: UITableViewCell {
    @IBOutlet weak var advanceImage: AdvanceImageView!
    @IBOutlet weak var pudDate: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var LabelView: UIView!
    @IBOutlet weak var shadowView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        shadowView.setShadowView(1,0.4, CGSize(width: 1, height: 1))
        LabelView.setShadowView(0,0.2, CGSize(width: 1, height: 1))
        
            }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
