//
//  ShowRecordsTableViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/31.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class ShowRecordsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleImageView:AdvanceImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userPhotoImageView:AdvanceImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var detailLabel: UILabel!

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
