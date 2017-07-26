//
//  RssTableViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/9.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class RssTableViewCell: UITableViewCell {
    @IBOutlet weak var advanceImage: advanceImageView!
    @IBOutlet weak var pudDate: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var LabelView: UIView!
    @IBOutlet weak var shadowView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        LabelView.layer.shadowColor = UIColor.black.cgColor
        LabelView.layer.shadowOpacity = 0.2
        LabelView.layer.shadowOffset = CGSize(width: 1, height: 1)
        LabelView.backgroundColor = UIColor.white
        
      
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
