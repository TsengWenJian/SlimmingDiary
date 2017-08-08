//
//  Extension.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/23.
//  Copyright © 2017年 Nick. All rights reserved.
//

import Foundation
import UIKit

let imageCach = NSCache<AnyObject, AnyObject>()


// MARK:- UIView
extension UIView{
    
    func setShadowView(_ corner:CGFloat,_ opacity:Float,_ offset:CGSize){
        layer.cornerRadius = corner
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        
    }
}

extension Double{
    
    func toString()->String{
        
        return String(format: "%.1f",self)
    }
    
    
}

// MARK:- UIAlertController
extension UIAlertController{
    
    convenience init(error:String?){
        self.init(title: "", message: error, preferredStyle: .alert)
        let ok = UIAlertAction(title: "ok", style: .cancel, handler: nil)
        self.addAction(ok)
        
    }
    
}
// MARK:- UIImage
extension UIImage{
    
    
    func checkUserPhoto()->UIImage?{
        
        let manager = ProfileManager.standard
        
        var image:UIImage?
        
        if manager.userPhotoName == nil{
            
            if manager.userGender == 0{
                
                image = UIImage(named:"woman")
                
            }else{
                image = UIImage(named:"man")
                
            }
            
        }else{
            image = UIImage(imageName: manager.userPhotoName, search:.cachesDirectory)
            
            
        }
        
        return image
        
    }
    
    
    func resizeImage(maxLength:CGFloat)->UIImage{
        
        var finalImage = UIImage()
        var targetSize = size;
        
        
        if size.width <= maxLength
            && size.height <= maxLength{
            finalImage = self;
            targetSize = size;
            
        } else {
            // Will do resize here,and decide final size first.
            if size.width >= size.height {
                // Width >= Height
                let ratio = size.width / maxLength;
                targetSize = CGSize(width:maxLength,height:size.height/ratio);
            } else {
                // Height > Width
                let ratio = size.height / maxLength;
                targetSize = CGSize(width:size.width/ratio,height:maxLength);
            }
            // Do resize job here.
            UIGraphicsBeginImageContext(targetSize);
            draw(in: CGRect(x: 0, y: 0,width:targetSize.width,height: targetSize.height))
            
            finalImage = UIGraphicsGetImageFromCurrentImageContext()!;
            UIGraphicsEndImageContext();    // Important!!!
        }
        
        
        return  finalImage
        
    }
    
    
    
    
    convenience init?(imageName:String?,search:FileManager.SearchPathDirectory){
        
        
        guard let cachesURL = FileManager.default.urls(for:search,in:.userDomainMask).first,
        let name = imageName else{
                return nil
        }
        
        
        
        let fullFileImageName = cachesURL.appendingPathComponent(name)
        self.init(contentsOfFile:fullFileImageName.path)
        
    }
    
    func writeToFile(imageName:String,search:FileManager.SearchPathDirectory){
        
        let cachesURL = FileManager.default.urls(for:search,in:.userDomainMask).first
        let fullFileImageName = cachesURL?.appendingPathComponent(imageName)
        let imageData = UIImageJPEGRepresentation(self,1)
        
        guard let _ = try? imageData?.write(to:fullFileImageName!,options: [.atomic]) else{
            print("寫入照片失敗")
            return
        }

    }
}
extension Double{
    
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        
        return (self * divisor).rounded() / divisor
    }
}


extension UIImageView{
    
    
    func loadImageCacheWithURL(urlString:String){
        
        guard let url = URL(string:urlString)else{
            
           return
        }
        self.image = nil
        
        if let cachImage = imageCach.object(forKey: url as AnyObject){
            self.image = cachImage as? UIImage
            
            return
        }
    
        
        var loadingView:UIActivityIndicatorView?
        
        if loadingView == nil{
            
    
            
            loadingView = UIActivityIndicatorView()

            DispatchQueue.main.async {
             loadingView?.frame = self.bounds
            }
        
            loadingView?.color = UIColor.gray
            loadingView?.hidesWhenStopped = true
            addSubview(loadingView!)


        }
        
        
        loadingView?.startAnimating()
        
        
        
        let config:URLSessionConfiguration = .default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with:url) { (data, response, error) in
            
            if let err = error{
                print(err)
                
                DispatchQueue.main.async {
                    loadingView?.stopAnimating()
                    self.image = nil
                    
                }
                return
            }
            
            DispatchQueue.main.async {
                if let  downloadImage  = UIImage(data: data!){
                     loadingView?.stopAnimating()
                    imageCach.setObject(downloadImage,forKey: url as AnyObject)
                    self.image = downloadImage
                }
        
                
            }
            
        }
        task.resume()
        
    }
}
