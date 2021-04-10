//
//  NickProgressUIView.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/6/18.
//  Copyright © 2017年 Nick. All rights reserved.
//
import Foundation
import UIKit

@IBDesignable class NickProgress2UIView: UIView {
    @IBInspectable var lineWidth: CGFloat = 10
    @IBInspectable var anim: Bool = false
    @IBInspectable var duration: Double = 0.5

    @IBInspectable var titleTextSize: CGFloat = 18 {
        didSet { titleLabel.font = UIFont.systemFont(ofSize: titleTextSize) }
    }

    @IBInspectable var subTitleTextSize: CGFloat = 20 {
        didSet { subTitleLabel.font = UIFont.systemFont(ofSize: subTitleTextSize) }
    }

    @IBInspectable var detailTextSize: CGFloat = 14 {
        didSet { detailLabel.font = UIFont.systemFont(ofSize: detailTextSize) }
    }

    private let titleLabel = UILabel()
    private let subTitleLabel = UILabel()
    private let detailLabel = UILabel()

    private var pointerProgress: Double = 0.1 {
        didSet {
            if pointerProgress > 40 {
                pointerProgress = 40
            }

            if pointerProgress <= 0 {
                pointerProgress = 0
            }
        }
    }

    private var outsideLayer: CAShapeLayer?
    private let pointerView = UIView()
    private let insiderLayer = CAShapeLayer()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initialSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        initialSetup()
    }

    func initialSetup() {
        titleLabel.font = UIFont.systemFont(ofSize: titleTextSize)
        subTitleLabel.font = UIFont.systemFont(ofSize: subTitleTextSize)
        detailLabel.font = UIFont.systemFont(ofSize: detailTextSize)
        detailLabel.textColor = UIColor.gray

        addSubview(titleLabel)
        addSubview(subTitleLabel)
        addSubview(detailLabel)
    }

    override func draw(_: CGRect) {
        // check is exist
        if outsideLayer != nil {
            return
        }

        outsideLayer = CAShapeLayer()
        let startAngle = CGFloat(Double.pi)
        let endAngle = CGFloat(Double.pi * 2)

        let path = UIBezierPath()

        // MARK: outside layer

        path.addArc(withCenter: CGPoint(x: bounds.midX, y: bounds.maxY),
                    radius: bounds.size.width / 2 - lineWidth,
                    startAngle: startAngle, endAngle: endAngle, clockwise: true)

        outsideLayer?.frame = bounds
        outsideLayer?.fillColor = UIColor.clear.cgColor
        outsideLayer?.strokeColor = UIColor.gray.cgColor
        outsideLayer?.lineWidth = lineWidth
        outsideLayer?.path = path.cgPath
        layer.addSublayer(outsideLayer!)

        // MARK: start and end  dots

        let startDotsPath = UIBezierPath()
        startDotsPath.addArc(withCenter: CGPoint(x: bounds.minX + lineWidth, y: bounds.maxY),
                             radius: lineWidth / 2,
                             startAngle: startAngle, endAngle: endAngle * 2, clockwise: true)

        let endDotsPath = UIBezierPath()
        endDotsPath.addArc(withCenter: CGPoint(x: bounds.maxX - lineWidth, y: bounds.maxY),
                           radius: lineWidth / 2,
                           startAngle: startAngle, endAngle: endAngle * 2, clockwise: true)

        let startDotsLayer = CAShapeLayer()
        let endDotsLayer = CAShapeLayer()

        startDotsLayer.path = startDotsPath.cgPath
        outsideLayer?.addSublayer(startDotsLayer)

        endDotsLayer.path = endDotsPath.cgPath
        outsideLayer?.addSublayer(endDotsLayer)

        let gold = UIColor(red: 1, green: 215 / 255, blue: 0, alpha: 1)
        let orangered = UIColor(red: 1, green: 69 / 255, blue: 0 / 255, alpha: 1)
        let mediumseagreen = UIColor(red: 60 / 255, green: 179 / 255, blue: 113 / 255, alpha: 1)
        let crimson = UIColor(red: 220 / 255, green: 20 / 255, blue: 60 / 255, alpha: 1)

        // MARK: gradient layer mask

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: bounds.width + lineWidth / 2)
        gradientLayer.colors = [mediumseagreen.cgColor, gold.cgColor, orangered.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.locations = [0.0, 0.7, 1]
        layer.addSublayer(gradientLayer)

        gradientLayer.mask = outsideLayer

        // MARK: inside circle

        let insidePath = UIBezierPath()

        insiderLayer.frame.size = CGSize(width: bounds.size.width / 3 * 2, height: bounds.size.width / 3)
        insiderLayer.frame.origin = CGPoint(x: bounds.size.width / 6, y: bounds.height - bounds.size.width / 3)

        insidePath.addArc(withCenter: CGPoint(x: insiderLayer.bounds.midX,
                                              y: insiderLayer.bounds.maxY),
                          radius: bounds.size.width / 3,
                          startAngle: startAngle,
                          endAngle: endAngle,
                          clockwise: true)

        insiderLayer.backgroundColor = UIColor.clear.cgColor
        insiderLayer.fillColor = UIColor.clear.cgColor
        insiderLayer.strokeColor = UIColor.white.cgColor
        insiderLayer.shadowColor = UIColor.black.cgColor
        insiderLayer.shadowOpacity = 0.3
        insiderLayer.shadowOffset = CGSize(width: 0, height: -3)
        insiderLayer.path = insidePath.cgPath
        layer.addSublayer(insiderLayer)

        pointerView.frame.size = CGSize(width: insiderLayer.frame.width / 10,
                                        height: insiderLayer.frame.width / 10)

        // MARK: pointer triangle

        let trianglePath = UIBezierPath()
        trianglePath.move(to: CGPoint(x: pointerView.bounds.maxX, y: pointerView.bounds.maxY))
        trianglePath.addLine(to: CGPoint(x: pointerView.bounds.midX, y: pointerView.bounds.maxY))
        trianglePath.addLine(to: CGPoint(x: pointerView.bounds.midX, y: 0))
        trianglePath.close()

        let trianglePath2 = UIBezierPath()
        trianglePath2.move(to: CGPoint(x: 0, y: pointerView.bounds.maxY))
        trianglePath2.addLine(to: CGPoint(x: pointerView.bounds.midX, y: 0))
        trianglePath2.addLine(to: CGPoint(x: pointerView.bounds.midX, y: pointerView.bounds.maxY))
        trianglePath2.close()

        let triangleLayer = CAShapeLayer()
        triangleLayer.path = trianglePath.cgPath
        triangleLayer.fillColor = UIColor.red.cgColor

        let triangleLayer2 = CAShapeLayer()
        triangleLayer2.path = trianglePath2.cgPath
        triangleLayer2.fillColor = crimson.cgColor

        pointerView.frame.origin = CGPoint.zero
        pointerView.layer.addSublayer(triangleLayer)
        pointerView.layer.addSublayer(triangleLayer2)

        setProgressAnim()

        insiderLayer.addSublayer(pointerView.layer)

        let center = insiderLayer.position

        titleLabel.center = CGPoint(x: center.x, y: insiderLayer.frame.minY + titleLabel.bounds.height / 2 + 5)
        bringSubview(toFront: titleLabel)

        subTitleLabel.center = center

        detailLabel.center = CGPoint(x: center.x, y: bounds.height - detailLabel.frame.height / 2)
        bringSubview(toFront: detailLabel)

        print("----------------")
    }

    func setTitleColor(_ color: UIColor) {
        titleLabel.textColor = color
    }

    func setTitleText(text: String) {
        titleLabel.text = text
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: bounds.width / 2, y: insiderLayer.frame.minY + titleLabel.bounds.height / 2 + 5)
        bringSubview(toFront: titleLabel)
    }

    func setSubTitleText(text: String) {
        subTitleLabel.text = text
        subTitleLabel.sizeToFit()
        subTitleLabel.center = insiderLayer.position
        bringSubview(toFront: subTitleLabel)
    }

    func setDetailText(text: String) {
        detailLabel.text = text

        detailLabel.sizeToFit()
        detailLabel.center = CGPoint(x: bounds.width / 2, y: bounds.height - detailLabel.frame.height / 2)
        bringSubview(toFront: detailLabel)
    }

    func setProgress(_ progress: Double) {
        pointerProgress = progress
    }

    private func setProgressAnim() {
        let pointerPath = UIBezierPath()
        let startAngle = CGFloat(Double.pi)

        let angle = pointerProgress / 40
        let pointerEndAngle = CGFloat(Double.pi * (angle + 1))

        pointerPath.addArc(withCenter: CGPoint(x: insiderLayer.bounds.midX,
                                               y: insiderLayer.bounds.maxY),
                           radius: (bounds.size.width / 3) + pointerView.frame.height / 2 + 3,
                           startAngle: startAngle, endAngle: pointerEndAngle, clockwise: true)

        let orbit = CAKeyframeAnimation(keyPath: "position")
        orbit.duration = 1
        orbit.path = pointerPath.cgPath
        orbit.calculationMode = kCAAnimationPaced
        orbit.rotationMode = kCAAnimationRotateAuto
        orbit.isRemovedOnCompletion = false
        orbit.fillMode = kCAFillModeForwards
        pointerView.layer.add(orbit, forKey: "pointer")
    }

    func getProgress() -> Double {
        return pointerProgress
    }

    func resetProgress(progress: Double) {
        pointerProgress = progress
        setProgressAnim()
    }
}
