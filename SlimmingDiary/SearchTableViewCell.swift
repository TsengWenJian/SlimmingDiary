//
//  SearchTableViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/5/26.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    var id: Int?
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var switchButton: UIButton!
    @IBOutlet var bodyLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
