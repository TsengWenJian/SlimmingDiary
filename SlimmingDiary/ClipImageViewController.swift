//
//  ClipImageViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/8/2.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

protocol clipImageVCDelegate {
    func clipImageDone(image:UIImage)
}

class ClipImageViewController: UIViewController,UIScrollViewDelegate{
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var lightView: UIView!
    @IBOutlet weak var upShadowView: UIView!
    var delegate:clipImageVCDelegate?
    var selectImage = UIImage()
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {        
        super.viewDidLoad()
        
        
        
        scrollView.delegate = self
        
        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale = 1.0
        imageView.image = selectImage
        scrollView.contentInset = UIEdgeInsets(top:upShadowView.bounds.height,
                                               left:0,
                                               bottom:upShadowView.bounds.height,
                                               right:0)
        
        scrollView.contentOffset.y = 0
        
        
    }
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    
    @IBAction func clipImageBtnAction(_ sender: Any) {
        
        
        UIGraphicsBeginImageContext(CGSize(width:lightView.frame.width*2, height: lightView.frame.height*2))
        let selectFrame = CGRect(x: 0,
                                 y:-upShadowView.frame.maxY*2,
                                 width:view.frame.width*2,
                                 height:view.frame.height*2)
        
        self.view.drawHierarchy(in:selectFrame, afterScreenUpdates: false)
        
        let  finalImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        imageView.image = finalImage
        delegate?.clipImageDone(image:finalImage)
        self.dismiss(animated: false, completion: nil)
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}
