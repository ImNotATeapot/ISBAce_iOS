//
//  AssignmentsTableViewController.swift
//  PowerAPIApp
//
//  Created by e1615998 on 3/17/16.
//  Copyright © 2559 ISB Software Development Club. All rights reserved.
//

import UIKit

class AssignmentsTableViewController: UITableViewController {
    var sectionIndex = 0
    var section = Section()
    var assignments = [Assignment]()
    var api = PowerAPI.sharedInstance
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.section = api.sections[sectionIndex] //better place to put this
        self.assignments = self.section.assignments
        //print(self.section.assignments.count)
        return  self.section.assignments.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("assignment_cell", forIndexPath: indexPath)
        
        // Configure the cell...
        let name = self.assignments[indexPath.row].name
        let letterGrade = self.assignments[indexPath.row].letterGrade
        var numberGrade = self.assignments[indexPath.row].percent
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
        
        return cell
    }
    override func viewWillAppear(animated: Bool) {
        //self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = api.sections[sectionIndex].name
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(animated: Bool) {
        //self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "navbar_icon"))
        super.viewWillDisappear(animated)
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
