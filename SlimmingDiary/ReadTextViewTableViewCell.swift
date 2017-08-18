//
//  ReadTextViewTableViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/8/1.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class ReadTextViewTableViewCell: UITableViewCell {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var appearMoreBtn: UIButton!
    var isMore:Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func appearMoreAction(_ sender: Any) {
        
        
              
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
