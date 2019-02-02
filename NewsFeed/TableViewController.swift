//
//  TableViewController.swift
//  NewsFeed
//
//  Created by Patriya Piyawiroj on 1/30/2559 BE.
//  Copyright (c) 2559 Patriya. All rights reserved.
//

import UIKit
import Foundation

class TableViewController: UITableViewController, ParserDelegate {

    let parser:Parser = Parser()
    var articles:[Article] = [Article]()
    var selectedArticle:Article?
    
    
    // Refresh Action
    @IBAction func refresh(sender: AnyObject) {
        self.parser.getArticles()
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.layoutMargins = UIEdgeInsetsZero
        
        // Set itself as the delegate for parser
        self.parser.delegate = self
        
        // Request to download articles in background
        self.parser.getArticles()
      
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func articlesReady() {
        // Parser notifies view controller that articles are ready
        self.articles = self.parser.articles
        
        // Display articles in tableView
        self.tableView.reloadData()
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articles.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! 
        
        // Grab elements using the tag
        let label:UILabel? = cell.viewWithTag(1) as! UILabel?
        let label2:UILabel? = cell.viewWithTag(2) as! UILabel?
        let imageView:UIImageView? = cell.viewWithTag(3) as! UIImageView?
        
        // Set properties
        let currentArticle:Article = self.articles[indexPath.row]
        
        if let titleLabel = label{
            titleLabel.text = currentArticle.articleTitle
        }
        
        if let descriptionLabel = label2 {
            descriptionLabel.text = currentArticle.articleDescription
        }

        
        if let articleImage = imageView {
            if currentArticle.articleImageURL != "" {
                
                // Create NSURL object
                let url:NSURL? = NSURL(string: currentArticle.articleImageURL)
                
                // Create an NSURLRequest
                let imageRequest:NSURLRequest = NSURLRequest(URL:url!)
                
                // Create an NSURLSession
                let session:NSURLSession = NSURLSession.sharedSession()
                
                // Create an NSURLSessionDataTask
                let dataTask:NSURLSessionDataTask = session.dataTaskWithRequest(imageRequest, completionHandler: { (data, response, error) -> Void in
                    
                    // Lets code execute on the main thread
                    dispatch_async(dispatch_get_main_queue(), {
                      
                        // When the image has been downloaded, use data to create an UIImage object and assign it into the imageview
                        articleImage.image = UIImage(data:data!)
                        
                    })
                    
                })
                
                dataTask.resume()
            }
            
        }
        
        
        //Set insets to zero
        cell.layoutMargins = UIEdgeInsetsZero
        //cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    override func viewDidAppear(animated: Bool) {
        getImages(self.articles)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Keep track of which article the user selected
        self.selectedArticle = self.articles[indexPath.row]
        
        // Trigger the segue to go to the detail view
        self.performSegueWithIdentifier("toWebSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Get reference to destination view controller
        let webVC = segue.destinationViewController as! WebViewController
        webVC.displayedArticle = self.selectedArticle
        
        // Pass a long the selected article
    }
    
    func getImages(articleArray:[Article]) {
    
        for article in articleArray {

            let myURLString = article.articleLink
            
            if let myURL = NSURL(string: myURLString) {
                var error: NSError?
                let HTMLString: NSString?
                do {
                    HTMLString = try NSString(contentsOfURL: myURL, encoding: NSUTF8StringEncoding)
                } catch let error1 as NSError {
                    error = error1
                    HTMLString = nil
                }
                
                if let error = error {
                    print("Error : \(error)")
                }
                
                else {
                    let startRange = HTMLString!.rangeOfString("class=\"post-thumbnail\"", options: .RegularExpressionSearch)
                    
                    if startRange.length != 0 {
                        
                        let endRange = HTMLString!.rangeOfString("prettyPhoto", options: .RegularExpressionSearch)
                        
                            let actualRange = _NSRange(location: startRange.location + 33, length: endRange.location - startRange.location - 40)
                        
                            article.articleImageURL = HTMLString!.substringWithRange(actualRange)
                        }
                            
                    else {
                        article.articleImageURL = "https://i.vimeocdn.com/portrait/6438515_300x300.jpg"
                    }
                    
                
                }
            }
            else {
                print("Error: \(myURLString) doesn't seem to be a valid URL")
            }
        }
        self.tableView.reloadData()
    }
    

}
