//
//  ViewController.swift
//  PowerAPIApp
//
//  Created by e1615998 on 1/15/16.
//  Copyright © 2016 ramicaza. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    var string = String()
    let api = PowerAPI.sharedInstance
    override func viewDidLoad() {
        string = "hello"
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        userNameField.text = "15998"
        passwordField.text = "3454"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTranscript:", name:"transcript_parsed", object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func handleTranscript(notification : NSNotification){
        performSegueWithIdentifier("show_grades", sender: nil)
        print("Student Information: \(api.studentInformation)\n")
        /*for section in api.sections {
            for assignment in section.assignments{
                print("Class: \(section.name), Name:\(assignment.name), Grade: \(assignment.percent)")
            }
            if let percent = section.finalGrade["percent"]{
            print("Class: \(section.name), \(section.reportingTerm) Grade: "+percent)
            }
        }*/
    }
    @IBAction func authenicate(sender: AnyObject) {
        //print("authenicating")
        api.authenticate("powerschool.isb.ac.th", username: userNameField.text!, password: passwordField.text!, fetchTranscript: true)
    }
    
}

