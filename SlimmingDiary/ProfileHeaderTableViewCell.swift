//
//  ProfileHeaderTableViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/22.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class ProfileHeaderTableViewCell: UITableViewCell {
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var userPhoto: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        userPhoto.layer.cornerRadius = userPhoto.frame.height / 2
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
