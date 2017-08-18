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
        super.init(frame: supView.frame)
        
        supView.addSubview(self)
        
        
        //        UIApplication.shared.beginIgnoringInteractionEvents()
        
        
        self.backgroundColor = UIColor(red:0, green: 0, blue: 0, alpha:0.5)
        
        let toastView = UIView(frame: CGRect(x:0, y:0, width:140, height: 140))
        toastView.center = CGPoint(x:supView.bounds.midX, y:supView.bounds.midY-30)
        
        toastView.backgroundColor = UIColor(red:0.99, green: 0.99, blue: 0.99, alpha: 0.99)
        toastView.setShadowView(5, 0.2,CGSize.zero )
        active = UIActivityIndicatorView(frame:CGRect(x: 0,
                                                      y: 0,
                                                      width:toastView.bounds.width,
                                                      height:toastView.bounds.height*0.66))
        active?.tintColor = UIColor.lightGray
        active?.color = UIColor.black
        active?.transform = CGAffineTransform.init(scaleX:1.5, y:1.5)
        addSubview(toastView)
        
        if let myActive = active{
            
            toastView.addSubview(myActive)
            
            active?.startAnimating()
            let ToastLabel = UILabel()
            ToastLabel.frame = CGRect(x: 0,y:myActive.bounds.maxY-10, width:toastView.bounds.width, height:toastView.bounds.height*0.33)
            ToastLabel.text = type.rawValue
            ToastLabel.textColor = UIColor.gray
            ToastLabel.textAlignment = .center
            ToastLabel.font = UIFont.systemFont(ofSize:20)
            toastView.addSubview(ToastLabel)
            
        }else{
            
            removefromView()
            
        }
    }
    
    
    func removefromView(){
        
        //UIApplication.shared.endIgnoringInteractionEvents()
        
        active = nil
        
        UIView.animate(withDuration:0.3,delay:0, options: [.curveEaseInOut], animations: {
            
            self.alpha = 0
            self.backgroundColor = UIColor.white
            
        }) { (done) in
            if done{
                
                self.removeFromSuperview()
            }
        }
        
        
    }
    
    
    
}
