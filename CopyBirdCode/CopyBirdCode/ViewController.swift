//
//  ViewController.swift
//  CopyBirdCode
//
//  Created by e2014785 on 1/14/16.
//  Copyright © 2016 e2014785. All rights reserved.
//

/*Hi keene, there's really no need to write the string that you "compact" (concatenate really) into another file, this is inneficient since writing to disk takes up considerable processing.  You should just store the concatenated string in a variable.
*/

import UIKit
import SystemConfiguration

class ViewController: UIViewController {
    
    var fileReader = FileReader()
    @IBOutlet weak var webView: UIWebView!
    let bundle = NSBundle.mainBundle()
    var fileContent:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
         //Funny enough, I forgot that the function i wrote in the API does all the regex stuff for you ahahah, at least you learned to use regex so the effort was not wasted
        
        //var matches = [NSString()]
        //let writeFileURL = NSBundle.mainBundle().URLForResource("writeFile", withExtension:"html")
        //let request = NSURLRequest(URL: writeFileURL!)
        //let schedURL = NSBundle.mainBundle().URLForResource("sched", withExtension:"html")
        //fileContent = try? String(contentsOfURL: schedURL!)
        //matches = matchesForRegexInText("(<table id=\"tableStudentSchedMatrix\".*<\\/table>)", text: fileContent)
        //compact(matches[0])
        
        let core: PSCore = PSCore(NSURL(string: "https://powerschool.isb.ac.th"))
        let student: PSUser? = core.auth("15998", password: "3454")
        
        if (isConnectedToNetwork() == true) {
            
        if (student != nil) {
        let schedule = student!.fetchSchedule()
        webView.loadHTMLString(compact(schedule), baseURL: nil)
        }
        
        else {
          print ("You Cannot Log In")
        }
            
            
        }
        else {
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
        let compactString = fileReader.readFileContent("top", typeOfResource: "txt") + (middle as String) + fileReader.readFileContent("closer", typeOfResource: "txt")
        return compactString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

