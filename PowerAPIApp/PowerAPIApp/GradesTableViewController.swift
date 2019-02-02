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
    var sections = [Section]()
    var realSectionMap = [Int]()
    var selectedGrade = 0
    
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
        sections = getLatestSections() // better to place to put this (i.e. before view loads)
        return sections.count
    }
    private func getLatestSections()->[Section]{
        var courseNames = Set<String>()
        var tempSections = [Section]()
        var i = 0
        for section in api.sections{
            if !courseNames.contains(section.name)&&section.reportingTerm == "S2"{ //atm crude,fix later
                courseNames.insert(section.name)
                tempSections.append(section)
                realSectionMap.append(i)
            }
            i++
        }
        return tempSections
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let section = sections[indexPath.row]
        let name = section.name
        let letterGrade = section.finalGrade["grade"]
        let numberGrade = section.finalGrade["percent"]
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = numberGrade
        
        return cell
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "to_assignments")
        {
            let vc = segue.destinationViewController as! AssignmentsTableViewController
            vc.sectionIndex = self.realSectionMap[self.selectedGrade]
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Keep track of which article the user selected
        self.selectedGrade = indexPath.row
        // Trigger the segue to go to the detail view
        self.performSegueWithIdentifier("to_assignments", sender: self)
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
