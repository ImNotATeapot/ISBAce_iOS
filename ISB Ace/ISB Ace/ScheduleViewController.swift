//
//  ViewController.swift
//  CopyBirdCode
//
//  Created by e2014785 on 1/14/16.
//  Copyright © 2559 ISB Software Development Club. All rights reserved.
//

/*Hi keene, there's really no need to write the string that you "compact" (concatenate really) into another file, this is inneficient since writing to disk takes up considerable processing.  You should just store the concatenated string in a variable.
 */

import UIKit
import SystemConfiguration

class ScheduleViewController: UIViewController, UIWebViewDelegate, UIScrollViewDelegate{
    
    @IBOutlet weak var nonPullLoadingAn: UIActivityIndicatorView!
    @IBOutlet weak var loadingAnimation: UIActivityIndicatorView!
    @IBOutlet weak var webView: UIWebView!
    let bundle = NSBundle.mainBundle()
    var fileContent:String?
    var tutorial: Tutorial?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tutorial = Tutorial(viewController: self, meme: "tutorial_schedule")
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "navbar_icon"))
        webView.delegate = self
        webView.scrollView.delegate = self
        webView.scrollView.showsHorizontalScrollIndicator = false;
        webView.backgroundColor = UIColor.clearColor()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let defaults =  NSUserDefaults.standardUserDefaults()
        if let sched = defaults.objectForKey("schedule"){
            //this complex looking code just checks if there has been a Sunday between last update and the current time.  If there has, update (since schedules are updated every sunday)
            var lastDate = defaults.objectForKey("schedule_updated") as! NSDate
            var update = false
            while NSDate().timeIntervalSinceDate(lastDate) > 86400{
                let dayComponenet = NSDateComponents()
                dayComponenet.day = 1
                let theCalendar = NSCalendar.currentCalendar()
                lastDate = theCalendar.dateByAddingComponents(dayComponenet, toDate: lastDate, options: NSCalendarOptions())!
                
                let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
                let components = calendar.components(.Weekday, fromDate: lastDate)
                let weekDay = components.weekday
                if weekDay == 2{ //if a monday is passed while traversing from then till now
                    update = true
                    print("will attempt to update schedule")
                }
            }
            if update{ //check whether time to update
                getScheduleFromNetwork()
            }else{ //otherwise use cached sched
                loadBlank = false
                self.webView.loadHTMLString(self.compact(sched as! NSString), baseURL: nil)
                nonPullLoadingAn.stopAnimating()
            }
        }else{
            //if sched not saved in defaults
            //self.webView.scrollView.contentOffset.y = -101 //force reload through GUI
            loadBlank = true
            webView.loadRequest(NSURLRequest(URL: NSURL(string: "about:blank")!)) //load blank webview while loading real schedule
            getScheduleFromNetwork()
        }
    }
    var loadBlank = false //used to render a correctly sized webview when loading the blank webview
    var rw = CGFloat(0)
    func webViewDidFinishLoad(webView: UIWebView) {
        //webView.scrollView.contentSize = CGSizeMake(webView.frame.size.width, webView.scrollView.contentSize.height);
        resizeWebview()
    }
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        super.didRotateFromInterfaceOrientation(fromInterfaceOrientation)
        resizeWebview()
    }
    func resizeWebview(){
        if loadBlank{
            webView.scrollView.minimumZoomScale = 1.0
            webView.scrollView.maximumZoomScale = 1.0
            webView.scrollView.zoomScale = 1.0
        }else{
            let contentSize = webView.scrollView.contentSize
            let viewSize = webView.bounds.size
            let rw = viewSize.width / contentSize.width
            webView.scrollView.minimumZoomScale = rw
            webView.scrollView.maximumZoomScale = rw
            webView.scrollView.zoomScale = rw
            self.rw = rw
        }
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0
        let maxY = webView.scrollView.contentSize.height*rw - webView.bounds.height
        if maxY < 0 { // if webview content height smaller than the webview bounds height
            if scrollView.contentOffset.y > 0{
                scrollView.contentOffset.y = 0
            }
        }else{
            if scrollView.contentOffset.y > maxY{
                scrollView.contentOffset.y = maxY
            }
        }
        let y = (self.navigationController?.navigationBar.frame.size.height)!-webView.scrollView.contentOffset.y/2+loadingAnimation.bounds.height/2
        loadingAnimation.center = CGPointMake(loadingAnimation.center.x, y); // set center
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if (scrollView.contentOffset.y < -100){
            //reach top
            UIView.animateWithDuration(1.0, animations: {
                self.webView.scrollView.contentInset = UIEdgeInsetsMake(60, 0, -60, 0)
                //self.webView.layoutIfNeeded()
            })
            getScheduleFromNetwork()
        }
    }
    func getScheduleFromNetwork(){
        if (isConnectedToNetwork() == true) { //first check if user is even connected to wifi
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                let defaults = NSUserDefaults.standardUserDefaults()
                let un = defaults.objectForKey("username") as! String
                let pw = defaults.objectForKey("password") as! String
                var schedule = ""
                if un == "DEMO" && pw == "DEMO" {
                    schedule = FileReader.readFileContent("CopyBirdCode/demo_table", typeOfResource: "html")
                    sleep(1)
                }else{
                    var core: PSCore = PSCore(NSURL(string: "https://powerschool.isb.ac.th"))
                    var student = core.auth(un, password: pw)
                    if (student != nil) {
                        schedule = student!.fetchSchedule()
                    }else {
                        //scummy workaround wtf problem by trying twice
                        core  = PSCore(NSURL(string: "https://powerschool.isb.ac.th"))
                        student = core.auth(un, password: pw)
                        if (student != nil) {
                            schedule = student!.fetchSchedule()
                        }else {
                            print ("You Cannot Log In") //this error should be changed to "cannot conenct to ps server" and displayed to user
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.loadBlank = false
                    self.webView.loadHTMLString(self.compact(schedule), baseURL: nil)
                    self.nonPullLoadingAn.stopAnimating()
                    UIView.animateWithDuration(0.5, animations: {
                        self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
                    })
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(schedule, forKey: "schedule")
                    defaults.setObject(NSDate(), forKey: "schedule_updated")
                }
            }
        } else { //if not connected to network
            print ("NO WIFI")
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
    
    //var compactString:String? = nil //it's wise programing to declare variables that are only used in one method INSIDE that method
    
    func compact(middle: NSString) -> String{
        var path = ""
        let cs = NSUserDefaults.standardUserDefaults().objectForKey("color_schedule")
        if cs == nil || cs as! Bool == true{
            path = "CopyBirdCode/topcolor"
        }else{
            path = "CopyBirdCode/top"
        }
        let compactString = FileReader.readFileContent(path, typeOfResource: "txt") + (middle as String) + FileReader.readFileContent("CopyBirdCode/closer", typeOfResource: "txt")
        return compactString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout(sender: AnyObject) {
        (self.tabBarController as! TabBarViewController).logout()
    }
    @IBAction func tutorial(sender: AnyObject) {
        tutorial?.enabled = !(tutorial?.enabled)!
    }
    
    /*
     func matchesForRegexInText(regex: String!, text: String!) -> [String] {
     
     do {
     let regex = try NSRegularExpression(pattern: regex, options: NSRegularExpressionOptions.DotMatchesLineSeparators)
     let nsString = text as NSString
     let results = regex.matchesInString(text,
     options: [], range: NSMakeRange(0, nsString.length))
     return results.map { nsString.substringWithRange($0.range)}
     } catch let error as NSError {
     print("invalid regex: \(error.localizedDescription)")
     return []
     }
     }
     */
}

