//
//  NickToastUIView.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/24.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

enum ToastType:String {
    
    case update = "更新中.."
    case download = "讀取中.."
    case Upload = "上傳中.."
    case logIn = "登入中.."
}

@IBDesignable class NickToastUIView: UIView {
    
    var active:UIActivityIndicatorView?
    var supUIView:UIView?
    
    
   
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    
    init(supView:UIView,type:ToastType) {
        super.init(frame: CGRect(x: 0, y: 0, width: 140, height: 140))
        supView.addSubview(self)
        
        
        self.center = CGPoint(x:supView.bounds.midX, y:supView.bounds.midY-30)
        
        backgroundColor = UIColor(red:0.99, green: 0.99, blue: 0.99, alpha: 0.99)
        layer.cornerRadius = 5
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize.zero
        layer.shadowOpacity = 0.2
        active = UIActivityIndicatorView(frame:CGRect(x: 0,
                                                      y: 0,
                                                      width:bounds.width,
                                                      height:bounds.height*0.66))
        active?.tintColor = UIColor.lightGray
        active?.color = UIColor.black
        active?.transform = CGAffineTransform.init(scaleX:1.5, y:1.5)
        
        if let myActive = active{
             addSubview(myActive)
            
            active?.startAnimating()
            let ToastLabel = UILabel()
            ToastLabel.frame = CGRect(x: 0, y:myActive.bounds.maxY-10, width: bounds.width, height: bounds.height*0.33)
            ToastLabel.text = type.rawValue
            ToastLabel.textColor = UIColor.gray
            ToastLabel.textAlignment = .center
            ToastLabel.font = UIFont.systemFont(ofSize:20)
            self.addSubview(ToastLabel)
            
        }else{
            
            removefromView()
            
        }
    }
    
    
    
    func removefromView(){
       active = nil
       removeFromSuperview()
        
    }
    
    
    
}
