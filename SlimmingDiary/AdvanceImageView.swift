//
//  advanceImageView.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/9.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit


class AdvanceImageView: UIImageView {
    
    var loadingView:UIActivityIndicatorView?
    var existTask:URLSessionDataTask?
    
    
    
    
    func loadWithURL(urlString:String){
        
        
        
        image = nil
        prepareIndicatorView()
        let url = URL(string:urlString)
        let hashString = "Cache_\(urlString.hash)"
        
        let cachesURL = FileManager.default.urls(for:.cachesDirectory, in: .userDomainMask).first
        guard let fullFileImageName = cachesURL?.appendingPathComponent(hashString) else{
            return
        }
        
        
        
        if let cachImage = UIImage(contentsOfFile:fullFileImageName.path){
            
            self.image = cachImage
            
            return
            
        }
        
        
        if existTask != nil{
            existTask?.cancel()
            existTask = nil
            
        }
        
        loadingView?.startAnimating()
        let config = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: config)
        
        existTask = nil
        
        
        let task = session.dataTask(with:url!) { (data, respone, error) in
            
            self.existTask = nil
            
            DispatchQueue.main.async {
                
                self.loadingView?.stopAnimating()
                self.loadingView = nil
            }
            
            if error != nil{
                SHLog(message:error.debugDescription)
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
            nsData.write(toFile:fullFileImageName.path, atomically: true)
            
        }
        
        
        existTask = task
        task.resume()
        
        
    }
    
    
    func prepareIndicatorView(){
        
        
        if loadingView == nil {
            
            loadingView = UIActivityIndicatorView()
            
            DispatchQueue.main.async {
                self.loadingView?.frame = self.bounds
            }
            loadingView?.color = UIColor.darkGray
            loadingView?.hidesWhenStopped = true
            addSubview(loadingView!)

            
        }
        
        
    }
}
