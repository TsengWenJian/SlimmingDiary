//
//  NickArrowUIView.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/17.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

@IBDesignable class NickArrowUIView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    var path2: UIBezierPath?

    override func draw(_: CGRect) {
        if path2 != nil {
            return
        }

        path2 = UIBezierPath()
        path2?.move(to: CGPoint(x: 0, y: 0))
        path2?.addLine(to: CGPoint(x: bounds.minX, y: bounds.height * 3 / 4))
        path2?.addLine(to: CGPoint(x: bounds.midX - bounds.width / 10, y: bounds.height * 3 / 4))
        path2?.addLine(to: CGPoint(x: bounds.midX, y: bounds.maxY))
        path2?.addLine(to: CGPoint(x: bounds.midX + bounds.width / 10, y: bounds.height * 3 / 4))
        path2?.addLine(to: CGPoint(x: bounds.maxX, y: bounds.height * 3 / 4))
        path2?.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
        path2?.close()

        let layer2 = CAShapeLayer()
        layer2.frame = bounds
        layer2.path = path2?.cgPath
        layer2.fillColor = UIColor(red: 245 / 255.0,
                                   green: 245 / 255.0,
                                   blue: 245 / 255.0,
                                   alpha: 1.0).cgColor

        layer2.shadowColor = UIColor.black.cgColor
        layer2.shadowOpacity = 0.3
        layer2.shadowOffset = CGSize(width: 1, height: 2)

        layer.addSublayer(layer2)
    }
}
