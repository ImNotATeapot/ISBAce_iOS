//
//  CalculatorsTableViewController.swift
//  ISB Ace
//
//  Created by e1718781 on 4/4/16.
//  Copyright © 2016 ISB Software Development Club. All rights reserved.
//

import UIKit
/*RUUUBEEEEENNNN here is basically what i've done and what you still need to do:
 I've worked a ton on the GUI and you should try to understand that AFTER we finish the app for learning purposes. However at the moment we're running out of time so don't worry about it.
 
 Currently, I'm using a class for each cell in the tableview called "CalculatorViewCell" - it inherits from "UITableViewCell" class.  This custom class contains the 5 fields that each cell in the calculator has: courseNameField, examWeightedField, examWeightField, examScoreField, overallGradeField.
 
 What you need to do is ittereate through all the cells and recalculate either the minimum exam scores or the predicted final grade for EVERY course depending on the mode of the switch at the top.  Also, you should automatically recalculate the GPA based on the final grades for every course.  The hard part of this will be to handle the posibility that users leave data blank without the app crashing or something.  ALL of the things should be recalculated if at any point the user switches the switch or enters new data into the table (i.e. when the dismessKeyboard method is called)
 */
class CalculatorsTableViewController: UIViewController, UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate {
    @IBOutlet weak var GPA: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var modeSwitch: UISwitch!
    var latestSections = [Section]()
    var cellsData = [CellModel]()
    var tutorial: Tutorial?
    
    @IBAction func modeSwitchFlicked(sender: AnyObject) {
        tableView.reloadData()
    }
    func dismissKeyboard(recognizer: UITapGestureRecognizer){
        //print("keyboard dismissed")
        self.view.endEditing(true) //this actually dismissed the keyboard so don't delete
        /*
        for i in 0 ..< tableView.numberOfRowsInSection(0) {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as! CalculatorViewCell
            cell.examWeightField.resignFirstResponder()
            cell.examScoreField.resignFirstResponder()
            cell.overallGradeField.resignFirstResponder()
        }
        calculateGPA()
        */
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        positionGPA()
    }
    /*func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
     let cell = tableView.dequeueReusableCellWithIdentifier("calculator_header_cell") as! CalculatorViewCell
     /*if cell == nil {
     cell = CalculatorViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "calculator_header_cell")
     }*/
     self.tableView.tableHeaderView = cell;
     return cell
     }*/
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //SET UP CELL
        let cell = tableView.dequeueReusableCellWithIdentifier("calculator_view_cell", forIndexPath: indexPath) as! CalculatorViewCell
        let model = cellsData[indexPath.row]
        
        cell.courseNameField.text = model.courseNameField
        cell.isWeighted = model.isWeighted
        cell.editedCallback = model.editedCallback
        cell.index = indexPath.row
        cell.enableSwitch.on = model.enableSwitch
        cell.examWeightField.text = model.examWeightField
        cell.examScoreField.text = model.examScoreField //this makes things simple
        cell.overallGradeField.text = model.overallGradeField
        
        //depending on mode
        if modeSwitch.on {
            cell.overallGradeField.enabled = true
            cell.overallGradeField.textColor = UIColor.blackColor()
            cell.examScoreField.enabled = false
            cell.examScoreField.textColor = UIColor.lightGrayColor()
        }else{
            cell.overallGradeField.enabled = false
            cell.overallGradeField.textColor = UIColor.lightGrayColor()
            cell.examScoreField.enabled = true
            cell.examScoreField.textColor = UIColor.blackColor()
        }
        return cell
    }
    func cellEdited(cell: CalculatorViewCell){
        //PERFORM CALCULATIONS FOR THAT ROW
        let mode = modeSwitch.on
        var result = ""
        var currentGrade = 0.0
        var examWeight = 0.0
        var examScore = 0.0
        var overallGrade = 0.0
        if mode == true
        {
            cell.examScoreField.enabled = false
            cell.examScoreField.textColor = UIColor.lightGrayColor()
            cell.overallGradeField.enabled = true
            cell.overallGradeField.textColor = UIColor.blackColor()
            if let s1 = cell.overallGradeField.text, let d1 = Double(s1){
                overallGrade = d1
                if let s2 = latestSections[cell.index].finalGrade["percent"], let d2 = Double(s2){
                    currentGrade = d2
                    if let s3 = cell.examWeightField.text, let d3 = Double(s3) where d3 > 0{
                        examWeight = d3
                        result = String((100.0*overallGrade - currentGrade*(100.0  - examWeight))/examWeight)
                    }else{
                        result = "NA"
                    }
                }else{
                    result = "NA"
                }
            }else{
                result = "NA"
            }
            cell.examScoreField.text = result
        }
        else //if mode is false
        {
            cell.overallGradeField.enabled = false
            cell.overallGradeField.textColor = UIColor.lightGrayColor()
            cell.examScoreField.enabled = true
            cell.examScoreField.textColor = UIColor.blackColor()
            if let s1 = cell.examScoreField.text, let d1 = Double(s1){
                examScore = d1
                if let s2 = latestSections[cell.index].finalGrade["percent"], let d2 = Double(s2){
                    currentGrade = d2
                    if let s3 = cell.examWeightField.text, let d3 = Double(s3){
                        examWeight = d3
                        result = String((examScore*examWeight + currentGrade * (100.0 - examWeight))/100.0)
                    }else{
                        result = "NA"
                    }
                }else{
                    result = "NA"
                }
            }else{
                result = "NA"
            }
            cell.overallGradeField.text = result
        }
        let model = cellsData[cell.index]
        //These are the only 4 fields that can be edited in each cell, so I update them in the model
        model.enableSwitch = cell.enableSwitch.on
        model.examWeightField =  cell.examWeightField.text
        model.examScoreField = cell.examScoreField.text //this makes things simple
        model.overallGradeField = cell.overallGradeField.text
        calculateGPA()
    }
    //TODO: NEED TO MAKE THIS METHOD INCLUDE OUTLIERS - CONSULT JUDGE
    func isWeighted(courseName: String) -> Bool{
        let cn = courseName.lowercaseString
        if cn.rangeOfString("ib") != nil || cn.rangeOfString("ap") != nil {
            return true
        }else{
            return false
        }
    }
    var currentSemester: Int = 1
    func getLatestSections()
    {
        latestSections.removeAll()        
        var s2Available = false
        for section in PowerAPI.sharedInstance.sections
        {
            //if there are any S2 courses available, only display S2 courses
            if section.reportingTerm == "S2"
            {
                s2Available = true
            }
        }
        for section in PowerAPI.sharedInstance.sections
        {
            if section.reportingTerm == "S1" && !s2Available
            {
                latestSections.append(section)
            }
            else if section.reportingTerm == "S2"
            { //"else if" might seem redundant but classes like comm are neither S1 nor S2 - maybe add seperate behavior for these weird classes
                latestSections.append(section)
            }
        }
        if s2Available {
            currentSemester = 1
        }else{
            currentSemester = 0
        }
    }
    //TODO: handle possible nil optional value in here: switch(latestSections[i].finalGrade["grade"]!)
    //TODO: handle possibility of weighted and unweighted courses
    //Function to calculate GPA, for display at the bottom of storyboard pane
    let boundaries: [Double] = [98,94,90,87,83,80,77,73,70,67,63,60,0]
    let weightedMap: [Double] = [4.8,4.5,4.2,3.8,3.5,3.2,2.8,2.5,2.2,1.8,1.5,1.2,0.0]
    let unweightedMap: [Double] = [4.3,4.0,3.7,3.3,3.0,2.7,2.3,2.0,1.7,1.3,1.0,0.7,0.0]
    let validLetters: [String] = ["A+","A","A-","B+","B","B-","C+","C","C-","D+","D","D-","F"]
    func calculateGPA() {
        var sum = 0.0
        var validCourses = 0
        for i in 0 ..< cellsData.count
        {
            var grade = 0.0
            let cell = cellsData[i]
            var validLetter: Bool
            if let grade = latestSections[i].finalGrade["grade"] where validLetters.contains(grade){
                validLetter = true
            }else{
                validLetter = false
            }
            if let s = cell.overallGradeField,let d = Double(s) where d >= 0 && validLetter && cell.enableSwitch{
                validCourses += 1
                grade = d
            }else{
                //cell.enableSwitch.on = false
                continue
            }
            for i in 0...boundaries.count{
                if grade >= boundaries[i]{
                    if cell.isWeighted! {
                        sum+=weightedMap[i]
                    }else{
                        sum+=unweightedMap[i]
                    }
                    break
                }
            }
        }
        var result = sum/Double(validCourses)
        result = Double(round(1000*result)/1000)
        var msg = ""
        if currentSemester == 0{
            msg += "S1 GPA: "
        }else{
            msg += "S2 GPA: "
        }
        msg += String(result)
        
        if NSUserDefaults.standardUserDefaults().boolForKey("show_gpa") {
            GPA.text = msg
        }else{
            GPA.text = "To see GPA, enable \"Show GPA\" in settings"
        }
        GPA.sizeToFit()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.automaticallyAdjustsScrollViewInsets = false
        //a UI hack to get rid of top space in tableview
        if self.interfaceOrientation == UIInterfaceOrientation.Portrait || self.interfaceOrientation == UIInterfaceOrientation.PortraitUpsideDown {
            tableView.contentInset = UIEdgeInsetsMake(-60, 0, 0, 0);
        }else{
            tableView.contentInset = UIEdgeInsetsMake(-30, 0, 0, 0);
        }
        tutorial = Tutorial(viewController: self, meme: "tutorial_calculator")
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "navbar_icon"))
        //getLatestSections() //this sets the global variables "currentSemester" and "latestSections" - decided to make these global since they are used throughout this entire class' methods
        //TODO: check if the setting to display GPA is enabled, if not display "GPA disabled message"
        self.view.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        //calculateGPA()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func populateDataModel(){
        //this method resets and populates cellsData
        cellsData.removeAll()
        for i in 0 ..< latestSections.count{
            var letterGrade =  latestSections[i].finalGrade["grade"]
            var numberGrade = latestSections[i].finalGrade["percent"]
            if letterGrade == nil {
                letterGrade = ""
            }
            if numberGrade == nil {
                numberGrade = ""
            }
            //SET UP CELL
            let cell = CellModel()
            cell.courseNameField = latestSections[i].name
            cell.isWeighted = isWeighted(latestSections[i].name)
            cell.editedCallback = cellEdited
            cell.examWeightField = "20"
            cell.examScoreField = numberGrade //this makes things simple
            cell.overallGradeField = numberGrade
            cell.index = i
            var validLetter: Bool
            if let grade = latestSections[i].finalGrade["grade"] where validLetters.contains(grade){
                validLetter = true
            }else{
                validLetter = false
            }
            if let s = latestSections[i].finalGrade["percent"],let d = Double(s) where d >= 0 && validLetter{
                cell.enableSwitch = true
            }else{
                cell.enableSwitch = false
            }
            cellsData.append(cell)
        }
        
    }
    class CellModel{
        var examWeightField: String!
        var examScoreField: String!
        var overallGradeField: String!
        var courseNameField: String!
        var isWeighted: Bool!
        var editedCallback: ((CalculatorViewCell) -> Void)!
        var enableSwitch: Bool!
        var index: Int!
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getLatestSections() //this sets the global variables "currentSemester" and "latestSections" - decided to make these global since they are used throughout this entire class' methods
        if cellsData.count == 0{//only resets the data if the view has been destroyed
            populateDataModel()
        }
        tableView.reloadData() //this is necessary to load the courses into the tableview
    }
    override func shouldAutorotate() -> Bool {
        return false
    }
    func positionGPA(){
        var rowRect = tableView.rectForRowAtIndexPath(NSIndexPath(forRow: latestSections.count-1, inSection: 0))
        let offsetPoint = tableView.contentOffset
        rowRect.origin.y -= offsetPoint.y
        // Move to the actual position of the tableView
        rowRect.origin.y += tableView.frame.origin.y
        GPA.center.y = rowRect.origin.y+66
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calculateGPA()
        positionGPA()
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return latestSections.count
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