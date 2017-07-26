//
//  advanceImageView.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/9.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit


class advanceImageView: UIImageView {
    
    var loadingView:UIActivityIndicatorView?
    var existTask:URLSessionDataTask?
    
    
    
    
    func loadWithURL(urlString:String){
        
      self.image = nil
        
        
       let url = URL(string:urlString)
        
        prepareIndicatorView()
        
        let hashString = "Cache_\(urlString.hash)"
        
             let cachesURL = FileManager.default.urls(for:.cachesDirectory, in: .userDomainMask).first
        let fullFileImageName = cachesURL?.appendingPathComponent(hashString)

        
        
        if let cachImage = UIImage.init(contentsOfFile:(fullFileImageName?.path)!){
            
            self.image = cachImage
           
            
            return
            
        }
        
        if existTask != nil{
            existTask?.cancel()
            existTask = nil
            
        }
        
        loadingView?.startAnimating()
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        existTask = nil
        
        
        let task = session.dataTask(with:url!) { (data, respone, error) in
            
            self.existTask = nil
            
            DispatchQueue.main.async {
                
                self.loadingView?.stopAnimating()
            }
            
            if error != nil{
                print(error.debugDescription)
                return
            }
            
            guard let myData = data else{
                return
                
            }
            
            
            let image = UIImage(data: myData)
            
            DispatchQueue.main.async {
                self.image = image
                
            }
            
            
            let nsData:NSData = myData as NSData
            nsData.write(toFile:(fullFileImageName?.path)!, atomically: true)
           
        }
        
        
        existTask = task
        task.resume()
        
        
    }
    
    
    func prepareIndicatorView(){
        
        if (loadingView == nil){
            loadingView = UIActivityIndicatorView()
            
        }else{
            
            return
        }
        
        loadingView?.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        loadingView?.color = UIColor.darkGray
        loadingView?.hidesWhenStopped = true
        addSubview(loadingView!)
        
    }
}
