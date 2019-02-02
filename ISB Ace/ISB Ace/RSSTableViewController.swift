//
//  RSSTableViewController.swift
//  ISB Ace
//
//  Created by Patriya Piyawiroj on 3/19/2559 BE.
//  Copyright © 2559 ISB Software Development Club. All rights reserved.
//


import UIKit
import CoreData
import SystemConfiguration

// Stuff to save images to file system
func getDocumentsURL() -> NSURL {
    let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
    return documentsURL
}

func fileInDocumentsDirectory(filename: String) -> String {
    let fileURL = getDocumentsURL().URLByAppendingPathComponent(filename)
    return fileURL.path!
}

class RSSTableViewController: UITableViewController, ParserDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let parser:ArticleParser = ArticleParser()
    var articleObjects = [NSManagedObject]()
    var selectedArticleLink:String?
    var tutorial: Tutorial?
    var testing:String = " "
    
    @IBAction func logout(sender: AnyObject) {
        (self.tabBarController as! TabBarViewController).logout()
    }
    @IBAction func tutorial(sender: AnyObject) {
        tutorial?.enabled = !(tutorial?.enabled)!
    }
    @IBAction func refresh(sender: AnyObject) {
        
        // Get articles
        if isConnectedToNetwork() == true {
            self.parser.delegate = self
            self.parser.articles.removeAll()
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)) {[unowned self] in self.parser.getArticles()}
        } else {
            print("no internet")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tutorial = Tutorial(viewController: self, meme: "tutorial_rss")
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "navbar_icon"))
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.layoutMargins = UIEdgeInsetsZero
        
        if entityIsEmpty("ArticleModel") {
            self.parser.delegate = self
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)) {[unowned self] in self.parser.getArticles()}
            //Will it crash with no internet?
        } else {
            let managedContext = appDelegate.managedObjectContext
            let fetchRequest = NSFetchRequest(entityName: "ArticleModel")
            do {
                let results = try managedContext.executeFetchRequest(fetchRequest)
                articleObjects = results as! [NSManagedObject]
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
        }
        
        //Nicocode to do some basic UI stuff like pull to refresh and adding gold background to pull-to-refresh
        self.refreshControl?.backgroundColor = UIColor(red: 255/255.0, green: 227/255.0, blue: 0/255.0, alpha: 1.0)
        self.refreshControl?.tintColor = UIColor.whiteColor()
        //self.navigationController?.setNavigationBarHidden(true, animated: false)
        //end of nicode
    }
    
    
    func articlesReady() {
        
        // Create managedObjectContext
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext:NSManagedObjectContext = appDelegate.managedObjectContext
        
        // If core data is empty
        if articleObjects.count == 0 {
            
            for currentArticle in self.parser.articles {
                
                // Create new object and insert in to managedObjectContext
                let entity =  NSEntityDescription.entityForName("ArticleModel", inManagedObjectContext:managedContext)
                let ArticleModel = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
                
                // Set NSManaged Object Properties
                ArticleModel.setValue(currentArticle.articleTitle, forKey: "title")
                ArticleModel.setValue(currentArticle.articleDescription, forKey: "subtitle")
                ArticleModel.setValue(currentArticle.articleLink, forKey: "link")
                
                do {
                    try managedContext.save()
                    articleObjects.append(ArticleModel)
                    
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }
            }
            getImages(self.parser.articles)
        } else {
            // There are new updated articles
            if articleObjects[0].valueForKey("title")?.isEqualToString(self.parser.articles[0].articleTitle) == false {
                // Update records
                var position:Int = 0;
                for currentArticle in self.parser.articles {
                    self.articleObjects[position].setValue(currentArticle.articleTitle, forKey: "title")
                    self.articleObjects[position].setValue(currentArticle.articleDescription, forKey: "subtitle")
                    self.articleObjects[position].setValue(currentArticle.articleLink, forKey: "link")
                    position += 1
                }; do {
                    try managedContext.save()
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }
                getImages(self.parser.articles)
            }
        }
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    
    
    func getImages(articleArray:[Article]) {
        
        // Create managedObjectContext
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext:NSManagedObjectContext = appDelegate.managedObjectContext
        var position = 0
        
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
                } else {
                    let startRange = HTMLString!.rangeOfString("class=\"post-thumbnail\"", options: .RegularExpressionSearch)
                    if startRange.length != 0 {
                        let endRange = HTMLString!.rangeOfString("prettyPhoto", options: .RegularExpressionSearch)
                        let actualRange = _NSRange(location: startRange.location + 33, length: endRange.location - startRange.location - 40)
                        let actualImageURL = HTMLString!.substringWithRange(actualRange)
                        self.articleObjects[position].setValue(actualImageURL, forKey: "image")
                    } else {
                        self.articleObjects[position].setValue("https://i.vimeocdn.com/portrait/6438515_300x300.jpg", forKey: "image")
                    }
                    do {
                        try managedContext.save()
                    } catch let error as NSError  {
                        print("Could not save \(error), \(error.userInfo)")
                    }
                    position += 1
                }
            } else {
                print("Error: \(myURLString) doesn't seem to be a valid URL")
            }
        }
        
        self.saveImages()
    }
    
    func saveImages() {
        
        var index = 0
        for article in self.articleObjects {
            let url:NSURL = NSURL(string: (article.valueForKey("image") as? String)!)!
            let data = NSData(contentsOfURL:url)
            let articleImageName = "image\(index).jpg"
            let imagePath = fileInDocumentsDirectory(articleImageName)
            self.saveImage(UIImage(data: data!)!, path: imagePath)
            
            index+=1
        }
    }
    
    func saveImage (image: UIImage, path: String ) -> Bool{
        let jpgImageData = UIImageJPEGRepresentation(image, 1.0)
        let result = jpgImageData!.writeToFile(path, atomically: true)
        return result
    }
    
    func loadImageFromPath(path: String) -> UIImage? {
        let image = UIImage(contentsOfFile: path)
        
        if image == nil {
            print("missing image at: \(path)")
        }
        return image
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articleObjects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")!
        
        let label:UILabel? = cell.viewWithTag(1) as! UILabel?
        let label2:UILabel? = cell.viewWithTag(2) as! UILabel?
        let imageView:UIImageView? = cell.viewWithTag(3) as! UIImageView?
        
        let ArticleModel = articleObjects[indexPath.row]
        
        if let titleLabel = label{
            titleLabel.text = (ArticleModel.valueForKey("title") as? String)!
        }
        
        if let descriptionLabel = label2 {
            descriptionLabel.text = ArticleModel.valueForKey("subtitle") as? String
        }
        
        if let articleImage = imageView {
            articleImage.image = self.loadImageFromPath(fileInDocumentsDirectory("image\(indexPath.row).jpg"))
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let ArticleModel = articleObjects[indexPath.row]
        self.selectedArticleLink = ArticleModel.valueForKey("link") as? String
        self.performSegueWithIdentifier("toWebSegue", sender: self)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let webVC = segue.destinationViewController as! ArticleWebViewController
        webVC.displayedArticleLink = self.selectedArticleLink
    }
    
    func entityIsEmpty(entity:String) -> Bool {
        let managedContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName:entity)
        var results:NSArray?
        
        do{
            results = try managedContext.executeFetchRequest(request) as! [NSManagedObject]
            return results!.count == 0
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            return true
        }
    }
    
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
}