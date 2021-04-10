//
//  InTableCollectionViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/29.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class InTableCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var deleteBtnAction: UIButton!
    @IBOutlet var shadowView: UIView!

    var isBeginEdit = false {
        didSet {
            deleteBtnAction.isHidden = !isBeginEdit
        }
    }

    override func awakeFromNib() {
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        shadowView.layer.cornerRadius = 5
    }
}
