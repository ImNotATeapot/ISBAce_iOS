//
//  GradesTableViewController.swift
//  PowerAPIApp
//
//  Created by e1615998 on 3/16/16.
//  Copyright © 2016 ramicaza. All rights reserved.
//

import UIKit

class GradesTableViewController: UITableViewController {
    let api = PowerAPI.sharedInstance
    var S1Sections = [Section]()
    var S2Sections = [Section]()
    var S1SectionMap = [Int]()
    var S2SectionMap = [Int]()
    var selectedSection = 0
    var selectedGrade = 0
    var tutorial: Tutorial?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "navbar_icon"))

        //PowerAPI.sharedInstance.authenticate("powerschool.isb.ac.th", username: un, password: pw, fetchTranscript: true) //this will most likely need to be placed elswhere
        //self.navigationController?.setNavigationBarHidden(true, animated: false)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GradesTableViewController.handleTranscript(_:)), name:"transcript_parsed", object: nil)
        self.refreshControl?.backgroundColor = UIColor(red: 255/255.0, green: 227/255.0, blue: 0/255.0, alpha: 1.0)
        self.refreshControl?.tintColor = UIColor.whiteColor()
        self.refreshControl?.addTarget(self, action: #selector(GradesTableViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.displayGrades()

        tutorial = Tutorial(viewController: self, meme: "tutorial_grades")
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.displayGrades()
    }
    
    func refresh(sender:AnyObject){
        let defaults = NSUserDefaults.standardUserDefaults()
        let un = defaults.objectForKey("username") as! String
        let pw = defaults.objectForKey("password") as! String
        PowerAPI.sharedInstance.authenticate("powerschool.isb.ac.th", username: un, password: pw, fetchTranscript: true) //this will most likely need to be placed elswhere
    }
    func handleTranscript(notification : NSNotification){
        if notification.object as! Bool == true{
            displayGrades()
        }else{
            print ("weird, transcript failed to parse")
        }
    }
    func displayGrades(){
        //print("Student Information: \(api.studentInformation)\n")
        //print("displaying grades")
        getLatestSections()//maybe reduce bureaucratic programming later if remember
        /*for section in api.sections {
         for assignment in section.assignments{
         print("Class: \(section.name), Name:\(assignment.name), Grade: \(assignment.percent)")
         }
         if let percent = section.finalGrade["percent"]{
         print("Class: \(section.name), \(section.reportingTerm) Grade: "+percent)
         }
         }*/
        self.refreshControl?.endRefreshing()
        self.tableView?.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if S1Sections.count == 0{
            return 0
        }else{
            if S2Sections.count == 0{
                return 1
            }else{
                return 2
            }
        }
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Semester 1 Grades"
        }else{
            return "Semester 2 Grades"
        }
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return S1Sections.count
        }else{
            return S2Sections.count
        }
    }
    private func getLatestSections(){
        S1Sections.removeAll()
        S2Sections.removeAll()
        S1SectionMap.removeAll()
        S2SectionMap.removeAll()
        var i = 0
        for section in api.sections{
            if section.reportingTerm == "S1"{
                S1Sections.append(section)
                S1SectionMap.append(i)
            }else if section.reportingTerm == "S2"{ //might seem redundant but classes like comm are neither S1 nor S2 - maybe add seperate behavior for these weird classes
                S2Sections.append(section)
                S2SectionMap.append(i)
            }
            i += 1
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if api.sections.count != 0 { //checks if api fetched courses yet
            let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("grades_cell", forIndexPath: indexPath)
            var section = Section()
            if indexPath.section == 0{
                section = S1Sections[indexPath.row]
            }else{
                section = S2Sections[indexPath.row]
            }
            let name = section.name
            let letterGrade = section.finalGrade["grade"]
            var numberGrade = section.finalGrade["percent"]
            if letterGrade == nil{
                numberGrade = ""
            }
            if numberGrade == nil || numberGrade == "0.0" || numberGrade == ""{
                numberGrade = ""
            }else{
                numberGrade = numberGrade! + "%"
            }
            (cell.viewWithTag(1) as! UILabel).text = letterGrade
            (cell.viewWithTag(2) as! UILabel).text = name
            (cell.viewWithTag(3) as! UILabel).text = numberGrade
            //cell.textLabel?.text = name
            //cell.detailTextLabel?.text = numberGrade
            return cell
        }
        else {
            return tableView.dequeueReusableCellWithIdentifier("grades_cell", forIndexPath: indexPath)
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "to_assignments")
        {
            let vc = segue.destinationViewController as! AssignmentsTableViewController
            if selectedSection == 0{
                vc.sectionIndex = self.S1SectionMap[self.selectedGrade]
            }else{
                vc.sectionIndex = self.S2SectionMap[self.selectedGrade]
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Keep track of which article the user selected
        selectedSection = indexPath.section
        selectedGrade = indexPath.row
        // Trigger the segue to go to the detail view
        self.performSegueWithIdentifier("to_assignments", sender: self)
    }
    
    @IBAction func logout(sender: AnyObject) {
        (self.tabBarController as! TabBarViewController).logout()
    }
    @IBAction func tutorial(sender: AnyObject) {
        tutorial?.enabled = !(tutorial?.enabled)!
    }
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
