//
//  NickProgressUIView.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/6/18.
//  Copyright © 2017年 Nick. All rights reserved.
//


import Foundation
import UIKit

struct myProgress{
    var progess:Double
    var color:UIColor

}




@IBDesignable class NickProgressUIView: UIView{
    
    
    @IBInspectable var lineWidth:CGFloat = 10
    @IBInspectable var trackColor:UIColor = UIColor(red:(245/255.0),
                                                    green:(245/255.0),
                                                    blue:(245/255.0),
                                                    alpha: 1.0)
    
    @IBInspectable var anim:Bool = false
    @IBInspectable var duration:Double = 0.5
    
    private var trackLayer:CAShapeLayer?
    private let path = UIBezierPath()
    private let titleLabel = UILabel()
    private let subTitleLabel = UILabel()
    var progressArray = [myProgress]()
    var progressLayerArray = [CAShapeLayer]()

    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    
    }
    
     override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    

    override func draw(_ rect: CGRect) {
        
        
        
        if trackLayer == nil{
            trackLayer = CAShapeLayer()
        }else{
            
            return
        }
    
        let startAngle:CGFloat = CGFloat(Double.pi * -1/2)
        let endAngle: CGFloat = CGFloat(Double.pi * 3/2)
        
        path.addArc(withCenter:CGPoint(x:bounds.midX, y: bounds.midY),
                    radius: bounds.size.width/2 - lineWidth,
                    startAngle:startAngle, endAngle:endAngle, clockwise: true)
        
        trackLayer?.frame = bounds
        trackLayer?.fillColor = UIColor.clear.cgColor
        trackLayer?.strokeColor = trackColor.cgColor
        trackLayer?.lineWidth = lineWidth
        trackLayer?.path = path.cgPath
        layer.addSublayer(trackLayer!)
        
        
        addProgressLayerArray()
        
        
        titleLabel.frame.size = CGSize(width:bounds.width,height: 20)
        titleLabel.textAlignment = .center
        titleLabel.center = CGPoint(x: bounds.midX, y: bounds.midY-bounds.height/10)
        addSubview(titleLabel)
        
        subTitleLabel.sizeToFit()
        subTitleLabel.center = CGPoint(x:bounds.midX,y:titleLabel.frame.maxY+(bounds.height/10)*2)
        addSubview(subTitleLabel)
        
        
    }
    
    
    
    
    //根據progressArray 來增加CAShapeLayer
    fileprivate func addProgressLayerArray(){
        
        var start:Double = 0
        
        for i in 0..<progressArray.count{
            
            
            let pr3  = CAShapeLayer()
            pr3.fillColor = UIColor.clear.cgColor
            pr3.strokeColor = progressArray[i].color.cgColor
            pr3.lineWidth = lineWidth
            pr3.shadowColor = UIColor.black.cgColor
            pr3.shadowRadius = 1
            pr3.shadowOpacity = 0.2
            pr3.shadowOffset = CGSize(width: 0, height: 0)
            pr3.path = path.cgPath
            
            
            
            if i != 0{
                start += progressArray[i-1].progess
                
            }
            pr3.strokeStart = CGFloat(0 + start)/100
            pr3.strokeEnd =  CGFloat(start)/100 + CGFloat(Double(progressArray[i].progess))/100.0
            layer.addSublayer(pr3)
            progressLayerArray.append(pr3)
            
            
            
            if anim{
                
                let animation = CABasicAnimation(keyPath: "strokeEnd")
                animation.fromValue =  pr3.strokeStart
                animation.toValue = pr3.strokeEnd
                animation.duration = 1
                pr3.add(animation, forKey: "")
                
            }
        }
    }
    
    
    func setProgress(pro:[myProgress]){
        progressArray = pro
        
    }
    
    func setTitleLabelText(text:String,size:CGFloat){
        
        titleLabel.text = text
        titleLabel.font = UIFont.systemFont(ofSize: size)
        
    }
    
    func setSubTitleLabelText(text:String,size:CGFloat){
        
        subTitleLabel.text = text
        subTitleLabel.sizeToFit()
        subTitleLabel.font = UIFont.systemFont(ofSize: size)
        
    }
    
    
    //    func setProgress(calayer:CAShapeLayer) {
    //
    //
    //            CATransaction.begin()
    //            CATransaction.setDisableActions(!anim)
    //            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name:
    //                kCAMediaTimingFunctionEaseInEaseOut))
    //            CATransaction.setAnimationDuration(duration)
    //            calayer.strokeEnd = CGFloat(1)
    //            CATransaction.commit()
    //            
    //                
    //           
    //           }
}

