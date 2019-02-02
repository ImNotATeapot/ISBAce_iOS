//
//  ArticleWebViewController.swift
//  ISB Ace
//
//  Created by Patriya Piyawiroj on 3/19/2559 BE.
//  Copyright © 2559 ISB Software Development Club. All rights reserved.
//


import UIKit

class ArticleWebViewController: UIViewController {
    
    var displayedArticleLink:String?
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let link:String = self.displayedArticleLink {
            // Create NSURL for the article URL
            let url:NSURL? = NSURL(string: link)
            //Check if an actual url object was created
            if let actualURL = url {
                let urlRequest:NSURLRequest = NSURLRequest(URL: url!)
                self.webView.loadRequest(urlRequest)
            }
        }
    }
    override func viewWillAppear(animated: Bool) { //nicocode to add and remove ugly nav controller space at the top of the screen
        //self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = "Article Detail"
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(animated: Bool) {
        //self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "navbar_icon"))
        super.viewWillDisappear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

