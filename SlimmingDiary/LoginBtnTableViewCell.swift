//
//  LoginBtnTableViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/23.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class LoginBtnTableViewCell: UITableViewCell {

    @IBOutlet weak var loginBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        loginBtn.layer.cornerRadius = 5
        // Configure the view for the selected state
    }

}
