//
//  NickProgressUIView.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/6/18.
//  Copyright © 2017年 Nick. All rights reserved.
//
import Foundation
import UIKit

@IBDesignable class NickProgress3UIView: UIView {
    @IBInspectable var lineWidth: CGFloat = 10
    @IBInspectable var trackColor = UIColor(red: 245 / 255.0,
                                            green: 245 / 255.0,
                                            blue: 245 / 255.0,
                                            alpha: 0.95)

    @IBInspectable var startColor = UIColor.gray
    @IBInspectable var endColor = UIColor.gray

    @IBInspectable var titleTextSize: CGFloat = 18 {
        didSet { titleLabel.font = UIFont.systemFont(ofSize: titleTextSize) }
    }

    @IBInspectable var subTitleTextSize: CGFloat = 22 {
        didSet { subTitleLabel.font = UIFont.systemFont(ofSize: subTitleTextSize) }
    }

    @IBInspectable var detailTextSize: CGFloat = 18 {
        didSet { detailLabel.font = UIFont.systemFont(ofSize: detailTextSize) }
    }

    @IBInspectable var titleTextColor = UIColor.white {
        didSet { titleLabel.textColor = titleTextColor }
    }

    @IBInspectable var subTitleTextColor = UIColor.white {
        didSet { subTitleLabel.textColor = subTitleTextColor }
    }

    @IBInspectable var detailTextColor = UIColor.white {
        didSet { detailLabel.textColor = detailTextColor }
    }

    private var trackLayer: CAShapeLayer?
    private let progressLayer = CAShapeLayer()
    private var endDotView = UIView()
    private let titleLabel = UILabel()
    private let subTitleLabel = UILabel()
    private let detailLabel = UILabel()
    private var labelMargin: CGFloat = 0

    func initialSetup() {
        titleLabel.font = UIFont.systemFont(ofSize: titleTextSize)
        subTitleLabel.font = UIFont.systemFont(ofSize: subTitleTextSize)
        detailLabel.font = UIFont.systemFont(ofSize: detailTextSize)
        titleLabel.textColor = titleTextColor
        subTitleLabel.textColor = subTitleTextColor
        detailLabel.textColor = detailTextColor

        addSubview(titleLabel)
        addSubview(subTitleLabel)
        addSubview(detailLabel)
    }

    private var progress: Double = 0 {
        didSet {
            if progress > 100 {
                progress = 100
            }

            if progress <= 0 {
                progress = 0
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }

    override func draw(_: CGRect) {
        let startAngle = CGFloat(Double.pi * -1 / 2)
        let endAngle = CGFloat(Double.pi * 3 / 2)

        if trackLayer != nil {
            return
        }

        let trackPath = UIBezierPath()
        trackPath.addArc(withCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                         radius: bounds.size.width / 2 - lineWidth,
                         startAngle: startAngle, endAngle: endAngle, clockwise: true)

        trackLayer = CAShapeLayer()
        labelMargin = bounds.height / 10

        trackLayer?.frame = bounds
        trackLayer?.fillColor = UIColor.clear.cgColor
        trackLayer?.strokeColor = trackColor.cgColor
        trackLayer?.lineWidth = lineWidth
        trackLayer?.path = trackPath.cgPath
        trackLayer?.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor
        layer.addSublayer((trackLayer)!)

        progressLayer.frame = bounds
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = trackColor.cgColor
        progressLayer.lineWidth = lineWidth
        layer.addSublayer(progressLayer)

        let startDotPath = UIBezierPath()
        startDotPath.addArc(withCenter: CGPoint(x: bounds.midX, y: bounds.minY + lineWidth),
                            radius: lineWidth / 2,
                            startAngle: startAngle, endAngle: endAngle, clockwise: true)

        let startDotLayer = CAShapeLayer()
        startDotLayer.path = startDotPath.cgPath
        progressLayer.addSublayer(startDotLayer)

        endDotView = UIView(frame: CGRect(x: 0,
                                          y: 0,
                                          width: lineWidth,
                                          height: lineWidth))
        endDotView.center = CGPoint(x: bounds.midX, y: bounds.minY + lineWidth)
        endDotView.layer.cornerRadius = lineWidth / 2
        endDotView.backgroundColor = UIColor.black
        progressLayer.addSublayer(endDotView.layer)

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.addSublayer(gradientLayer)
        gradientLayer.mask = progressLayer

        // set Progress and endDot path and animation
        setProgressAnim()
    }

    func setTitleText(text: String) {
        titleLabel.text = text
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: bounds.midX,
                                    y: bounds.minY + lineWidth + labelMargin * 2)

        bringSubview(toFront: titleLabel)
    }

    func setSubTitleText(text: String) {
        subTitleLabel.text = text
        subTitleLabel.sizeToFit()
        subTitleLabel.center = CGPoint(x: bounds.midX,
                                       y: bounds.midY)

        bringSubview(toFront: subTitleLabel)
    }

    func setDetailText(text: String) {
        detailLabel.text = text
        detailLabel.sizeToFit()
        detailLabel.center = CGPoint(x: bounds.midX,
                                     y: subTitleLabel.frame.maxY + labelMargin * 1.5)

        bringSubview(toFront: detailLabel)
    }

    func setProgress(_ progess: Double) {
        progress = progess
    }

    func setProgressAnim() {
        if progress <= 0 {
            progressLayer.isHidden = true
            return
        }

        progressLayer.isHidden = false

        let startAngle = CGFloat(Double.pi * -1 / 2)
        let calAngle = (-1 / 2) + progress * 0.02
        let progressEndAngle = CGFloat(Double.pi * calAngle)

        let trackPath = UIBezierPath()
        trackPath.addArc(withCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                         radius: bounds.size.width / 2 - lineWidth,
                         startAngle: startAngle, endAngle: progressEndAngle, clockwise: true)

        progressLayer.path = trackPath.cgPath

        let orbit = CAKeyframeAnimation(keyPath: "position")
        orbit.duration = 1
        orbit.path = trackPath.cgPath
        orbit.calculationMode = kCAAnimationPaced
        orbit.isRemovedOnCompletion = false
        orbit.fillMode = kCAFillModeForwards

        endDotView.layer.add(orbit, forKey: "endDote")

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 1
        progressLayer.add(animation, forKey: "progressMove")
    }

    func getProgress() -> Double {
        return progress
    }

    func resetProgress(_ progress: Double) {
        self.progress = progress
        setProgressAnim()
    }
}
