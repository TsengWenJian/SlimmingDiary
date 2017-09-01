//
//  NewsWebViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/9.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class NewsWebViewController: UIViewController,UIWebViewDelegate{
    
    
    var newsLink:String? = nil
    @IBOutlet weak var webView: UIWebView!
    
    
    
    override func viewDidLoad() {
      
        super.viewDidLoad()
        
        guard let urlString = newsLink,
              let reach = Reachability(hostName: urlString)else{
            return
        }
        
       
        
        if !reach.checkInternetFunction(){
            
            DispatchQueue.main.async {
                
                let alert = UIAlertController(error:notConnectInterent)
                self.present(alert, animated: true, completion: nil)
                
            }
            
            return
            
        }
        
        if let url = URL(string:urlString){
            let request = URLRequest(url:url)
            webView.loadRequest(request)
        }
       
        
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.dismiss(animated: true , completion:nil)
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
