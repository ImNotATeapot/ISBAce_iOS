//
//  LoginViewController.swift
//  ISB Ace
//
//  Created by 15998 on 4/27/2559 BE.
//  Copyright © 2559 ISB Software Development Club. All rights reserved.
//

import UIKit
import SystemConfiguration

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.delegate = self
        passwordField.delegate = self
        self.view.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Try to find next responder
        if textField.tag == 1{
            passwordField.becomeFirstResponder()
        }else {
            login(self)
            passwordField.resignFirstResponder()
        }
        return false // We do not want UITextField to insert line-breaks.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard(recognizer: UITapGestureRecognizer){
        self.view.endEditing(true) //this actually dismissed the keyboard so don't delete
        //perform grade calculator calculations in here
    }
    let api = PowerAPI.sharedInstance
    var un = ""
    var pw = ""
    @IBAction func login(sender: AnyObject) {
        print("Logging in from login screen")
        if usernameField.text == nil || usernameField.text == ""{
            showError("Please enter a username")
            return
        }else{
            un = usernameField.text!
        }
        if passwordField.text == nil || passwordField.text == ""{
            showError("Please enter a password")
            return
        }else{
            pw = passwordField.text!
        }
        if !isConnectedToNetwork(){
            showError("You're not connected to the internet")
            return
        }
        api.authenticate("powerschool.isb.ac.th", username: un, password: pw, fetchTranscript: true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.authFinished(_:)), name:"transcript_parsed", object: nil)
    }
    
    func authFinished(notification: NSNotification){
        let success = notification.object as! Bool
        if success{
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(true, forKey: "logged_in")
            defaults.setObject(un, forKey: "username")
            defaults.setObject(pw, forKey: "password")
            dismissViewControllerAnimated(true, completion: nil)
            var interval = 10*60.0
            if let setting = NSUserDefaults.standardUserDefaults().objectForKey("update_interval"){
                interval = (setting as! NSNumber).doubleValue * 60
            }
            UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(interval)
        }else{
            showError("Incorrect username or password")
        }
    }
    func showError(message: String){
        let alert = UIAlertController(title: "Unable to log in", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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

    @IBAction func demoClicked(sender: AnyObject) {
        usernameField.text = "DEMO"
        passwordField.text = "DEMO"
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
