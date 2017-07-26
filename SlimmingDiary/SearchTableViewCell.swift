//
//  SearchTableViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/5/26.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    var id:Int?
    @IBOutlet weak var titleLabel: UILabel!
   
    override func awakeFromNib() {
      
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBOutlet weak var switchButton: UIButton!

    @IBOutlet weak var bodyLabel: UILabel!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
