//
//  WebViewController.swift
//  NewsFeed
//
//  Created by Patriya Piyawiroj on 1/30/2559 BE.
//  Copyright (c) 2559 Patriya. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    var displayedArticle:Article?

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let actualArticle = self.displayedArticle {
            
            // Create NSURL for the article URL
            let url:NSURL? = NSURL(string: actualArticle.articleLink)
            
            // Create NSURLRequest for the NSURL
            
            //Check if an actual url object was created
            if let actualURL = url {
                let urlRequest:NSURLRequest = NSURLRequest(URL: url!)
                
                self.webView.loadRequest(urlRequest)
            }
            
            // Pass the request in to the webview to load the page
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
