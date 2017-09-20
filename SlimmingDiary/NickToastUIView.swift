//
//  NickToastUIView.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/24.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

enum ToastType:String {
    
    case update = "更新中"
    case download = "讀取中"
    case Upload = "上傳中"
    case logIn = "登入中"
}

@IBDesignable class NickToastUIView: UIView {
    
    var active:UIActivityIndicatorView?
    var toastView = UIView()
    
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    
    func showView(supView:UIView,type:ToastType) {
        
        
        self.frame = supView.frame
        supView.addSubview(self)
        
        
        
        self.alpha = 1
        
        self.backgroundColor = UIColor(red:0, green: 0, blue: 0, alpha:0.5)
        
        toastView = UIView(frame: CGRect(x:0, y:0, width:130, height: 130))
        toastView.center = CGPoint(x:supView.bounds.midX, y:supView.bounds.midY-30)
        
        toastView.backgroundColor = UIColor(red:0.9, green: 0.9, blue: 0.9, alpha: 0.9)
        toastView.setShadowView(5, 0.2,CGSize.zero )
        active = UIActivityIndicatorView(frame:CGRect(x: 0,
                                                      y: 0,
                                                      width:toastView.bounds.width,
                                                      height:toastView.bounds.height*0.66))
        active?.tintColor = UIColor.lightGray
        active?.color = UIColor.black
        active?.transform = CGAffineTransform.init(scaleX:1.3, y:1.3)
        addSubview(toastView)
        
        if let myActive = active{
            
            toastView.addSubview(myActive)
            
            active?.startAnimating()
            let ToastLabel = UILabel()
            ToastLabel.frame = CGRect(x: 0,y:myActive.bounds.maxY-10, width:toastView.bounds.width, height:toastView.bounds.height*0.33)
            ToastLabel.text = type.rawValue
            ToastLabel.textColor = UIColor.darkGray
            ToastLabel.textAlignment = .center
            ToastLabel.font = UIFont.systemFont(ofSize:18)
            toastView.addSubview(ToastLabel)
            
        }else{
            
            removefromView()
            
        }
        
        
    }
    
    
    func removefromView(){
        
        
        active = nil
        toastView.removeFromSuperview()
        self.removeFromSuperview()
        
        
        
        
    }
}
