//
//  NickProgressUIView.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/6/18.
//  Copyright © 2017年 Nick. All rights reserved.
//
import Foundation
import UIKit

@IBDesignable class NickProgress3UIView: UIView{
    
    
    @IBInspectable var lineWidth:CGFloat = 10
    @IBInspectable var trackColor:UIColor = UIColor(red:(245/255.0),
                                                    green:(245/255.0),
                                                    blue:(245/255.0),
                                                    alpha: 0.95)
    
    
    
    
    
    
    @IBInspectable var startColor:UIColor = UIColor.gray
    @IBInspectable var endColor:UIColor = UIColor.gray
    
    @IBInspectable var titleTextSize:CGFloat = 18
    @IBInspectable var subTitleTextSize:CGFloat = 25
    @IBInspectable var detailTextSize:CGFloat = 18
    
    @IBInspectable var titleTextColor:UIColor = UIColor.white
    @IBInspectable var subTitleTextColor:UIColor = UIColor.white
    @IBInspectable var detailTextColor:UIColor = UIColor.white
    
    
    
    private var trackLayer:CAShapeLayer?
    private let progressLayer = CAShapeLayer()
    private var endDotView = UIView()
    private let titleLabel = UILabel()
    private let subTitleLabel = UILabel()
    private let detailLabel = UILabel()
    private var labelMargin:CGFloat = 0
    
    
    
    
    private var progress:Double = 0 {
        didSet{
            if progress > 100{
                progress = 100
            }
            
            
            if progress <= 0{
                progress = 0
            }
        }
    }
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    override func draw(_ rect: CGRect) {
        
        
        let startAngle:CGFloat = CGFloat(Double.pi * -1/2)
        let endAngle: CGFloat = CGFloat(Double.pi * 3/2)
        
        
        
        
        if trackLayer != nil {
            return
        }
        
        
        let trackPath = UIBezierPath()
        trackPath.addArc(withCenter:CGPoint(x:bounds.midX, y: bounds.midY),
                         radius:bounds.size.width/2 - lineWidth,
                         startAngle:startAngle, endAngle:endAngle, clockwise: true)
        
        trackLayer = CAShapeLayer()
        labelMargin = bounds.height/10
        
        
        
        trackLayer?.frame = bounds
        trackLayer?.fillColor = UIColor.clear.cgColor
        trackLayer?.strokeColor = trackColor.cgColor
        trackLayer?.lineWidth = lineWidth
        trackLayer?.path = trackPath.cgPath
        trackLayer?.fillColor = UIColor(red:0,green:0, blue:0,alpha:0.6).cgColor
        layer.addSublayer((trackLayer)!)
        
        
        
        
        
        progressLayer.frame = bounds
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = trackColor.cgColor
        progressLayer.lineWidth = lineWidth
        layer.addSublayer(progressLayer)
        
        
        
        let startDotPath = UIBezierPath()
        startDotPath.addArc(withCenter:CGPoint(x:bounds.midX, y:bounds.minY+lineWidth),
                            radius:(lineWidth/2),
                            startAngle:startAngle, endAngle:endAngle, clockwise: true)
        
        
        let startDotLayer = CAShapeLayer()
        startDotLayer.path = startDotPath.cgPath
        progressLayer.addSublayer(startDotLayer)
        
        
        
        
        endDotView = UIView(frame:CGRect(x: 0,
                                         y: 0,
                                         width:lineWidth,
                                         height:lineWidth))
        endDotView.center = CGPoint(x:bounds.midX,y:bounds.minY+lineWidth)
        endDotView.layer.cornerRadius = lineWidth/2
        endDotView.backgroundColor = UIColor.black
        progressLayer.addSublayer(endDotView.layer)
        
        
        
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [startColor.cgColor,endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y:1)
        layer.addSublayer(gradientLayer)
        gradientLayer.mask = progressLayer
        
        
        // set Progress and endDot path and animation
        setProgressAnim()
        
        
        
        titleLabel.textColor = titleTextColor
        titleLabel.font = UIFont.systemFont(ofSize:titleTextSize)
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x:bounds.midX,
                                    y:bounds.minY + lineWidth + labelMargin*2)
         
        
        
        
        
        
        subTitleLabel.textColor = subTitleTextColor
        subTitleLabel.font = UIFont.systemFont(ofSize:subTitleTextSize)
        subTitleLabel.sizeToFit()
        subTitleLabel.center = CGPoint(x:bounds.midX, y:bounds.midY)
        
        
        
        
        
        
        
        detailLabel.font = UIFont.systemFont(ofSize:detailTextSize)
        detailLabel.textColor = detailTextColor
        detailLabel.sizeToFit()
        detailLabel.center = CGPoint(x:bounds.midX,
                                     y:subTitleLabel.frame.maxY+labelMargin)
        
        
        
        
        
    
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        addSubview(detailLabel)
        
        
    }
    
    
    
    
    
    
    func setTitleText(text:String){
        
        titleLabel.text = text
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x:bounds.midX,
                                    y:bounds.minY + lineWidth + labelMargin*2)
        
        
        
    }
    
    func setSubTitleText(text:String){
        
        subTitleLabel.text = text
        subTitleLabel.sizeToFit()
        subTitleLabel.center = CGPoint(x:bounds.midX,
                                       y:bounds.midY)
        
        
        
    }
    
    func setDetailText(text:String){
        
        detailLabel.text = text
        detailLabel.sizeToFit()
        detailLabel.center = CGPoint(x:bounds.midX,
                                     y:subTitleLabel.frame.maxY+labelMargin)
        
        
        
    }
    
    func  setProgress(_ progess:Double){
        progress = progess
        
    }
    
    
    func setProgressAnim(){
        
        
        if progress <= 0 {
            
            progressLayer.isHidden = true
            return
        }
        
        progressLayer.isHidden = false
        
        let startAngle:CGFloat = CGFloat(Double.pi * -1/2)
        let calAngle = (-1/2)+progress*0.02
        let progressEndAngle:CGFloat = CGFloat(Double.pi * calAngle)
        
        let trackPath = UIBezierPath()
        trackPath.addArc(withCenter:CGPoint(x:bounds.midX, y: bounds.midY),
                         radius:bounds.size.width/2 - lineWidth,
                         startAngle:startAngle, endAngle:progressEndAngle, clockwise: true)
        
        
        
        progressLayer.path = trackPath.cgPath
        
        
        
        let orbit = CAKeyframeAnimation(keyPath:"position")
        orbit.duration = 1
        orbit.path = trackPath.cgPath
        orbit.calculationMode = kCAAnimationPaced
        orbit.isRemovedOnCompletion = false
        orbit.fillMode = kCAFillModeForwards
        endDotView.layer.add(orbit,forKey:"endDote")
        
        

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 1
        progressLayer.add(animation, forKey: "progressMove")
        
        
    }
    
    func getProgress()->Double{
        return progress
    }
    
    
    func resetProgress(_ progress:Double){
        self.progress = progress
        setProgressAnim()
    
    }
}




