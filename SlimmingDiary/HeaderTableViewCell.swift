//
//  HeaderTableViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/5/26.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class HeaderTableViewCell: UITableViewCell {
   

    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var expendBtn: UIButton!
    @IBOutlet weak var totalCalorieLebel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
       override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.layer.cornerRadius = 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
