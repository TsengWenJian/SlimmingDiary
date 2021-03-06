//
//  NewsWebViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/9.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class NewsWebViewController: UIViewController, UIWebViewDelegate {
    var newsLink: String?
    @IBOutlet var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let urlString = newsLink,
              let reach = Reachability(hostName: urlString)
        else {
            return
        }
        webView.loadHTMLString("style type = \text/css\">* {margin:0;padding:0;padding-bottom:10;padding-top:10;text-align:center;}img{width:90%}</style>", baseURL: nil)

        if !reach.checkInternetFunction() {
            DispatchQueue.main.async {
                let alert = UIAlertController(error: notConnectInterent)
                self.present(alert, animated: true, completion: nil)
            }

            return
        }

        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }
    }

    @IBAction func backBtnAction(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
