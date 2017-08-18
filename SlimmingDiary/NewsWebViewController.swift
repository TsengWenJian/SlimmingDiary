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
        
        guard let urlString = newsLink else{
            return
        }
        
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)
        webView.loadRequest(request)

    
        
        
        
    

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.dismiss(animated: true , completion:nil)
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
