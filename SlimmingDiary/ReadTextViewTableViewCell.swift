//
//  ReadTextViewTableViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/8/1.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class ReadTextViewTableViewCell: UITableViewCell {
    @IBOutlet var textView: UITextView!
    @IBOutlet var appearMoreBtn: UIButton!
    var isMore: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func appearMoreAction(_: Any) {}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
