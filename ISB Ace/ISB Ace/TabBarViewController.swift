//
//  TabBarViewController.swift
//  ISB Ace
//
//  Created by 15998 on 4/27/2559 BE.
//  Copyright © 2559 ISB Software Development Club. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(animated: Bool) {
        if !NSUserDefaults.standardUserDefaults().boolForKey("logged_in"){
            performSegueWithIdentifier("to_login", sender: self)
        }
    }
    func logout(){
        print("logout - from tabbar controller")
        //do logout stuff here like clear data
        PowerAPI.sharedInstance.logout()
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("transcript")
        defaults.removeObjectForKey("username")
        defaults.removeObjectForKey("password")
        defaults.removeObjectForKey("logged_in")
        defaults.removeObjectForKey("schedule")
        //defaults.removeObjectForKey("hide_tutorial_rss")
        //defaults.removeObjectForKey("hide_tutorial_grades")
        //defaults.removeObjectForKey("hide_tutorial_schedule")
        //defaults.removeObjectForKey("hide_tutorial_calculator")
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(2592000)//lol 30 days refresh interval
        performSegueWithIdentifier("to_login", sender: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
