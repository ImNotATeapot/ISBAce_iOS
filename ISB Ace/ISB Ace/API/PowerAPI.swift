//
//  PowerAPI.swift
//  PowerAPIApp
//
//  Created by e1615998 on 1/15/16.
//  Copyright © 2016 ramicaza. All rights reserved.
//

import UIKit
/*TODO:
 - CHANGE NOTIFICATION WHEN FETCH TRANSCRIPT  TO DELEGATION NICO
 - IMPLEMENT GETTERS AND SETTERS AND DOCUMENTATION
 - DOCUMENATION + EXAMPLES
 */
/**
 This class is a singleton meaning that only 1 instance ever exists while the application is running. Therefore, we can safetly have multiple viewcontrollers accessing it at once
 
 Here is a rundown of the important variables:
 * "studentInformation" variable is a dictionary of student related info (e.g. name, birthday, etc.)
 * "sections" are all of the student's courses
 * check out quickhelp/documentation for the "section" object to see what goodies are in there
 */
class PowerAPI: NSObject {
    static var sharedInstance = PowerAPI()
    private var _studentInformation = [String: String]()
    private var _sections = [Section]()
    var client = SoapClient()
    private override init(){
        super.init()
        //this code initializes object using cached transcript if available
        if let cachedTranny = NSUserDefaults.standardUserDefaults().objectForKey("transcript"){
            print("Initializing PSAPI with cached transcript")
            let fakeNotification = NSNotification(name: "transcript_fetched", object: cachedTranny)
            parseTranscript(fakeNotification) // fake notification used when first initialized
        }else{
            print("Initializing PSAPI without cached transcript")
        }
        //register observer for transcript fetched
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PowerAPI.parseTranscript(_:)), name:"transcript_fetched", object: nil)
    }
    ///Dictionary of Strings containing student information
    var studentInformation: [String: String]{
        return _studentInformation
    }
    ///An array of "Section" objects.  "Sections" are  just a name for courses - you will need to check if they're S1 or S2
    var sections: [Section]{
        return _sections
    }
    /**
     Authenticates the user with the username and password.  When authentication is finished, a notification is sent out under the title "authentication_finished".  If "fetchTranscript" parameter is set true, a notification "transcript_parsed" is sent out after the transcript has been fetched and parsed
     - parameter  url: The url of the powerschool server.
     - parameter  fetch_transcript: You can tell the api to automatically fetch and parse the user's transcript when finished authenicating (usually just set to true
     */
    func authenticate(url:String, username: String,password: String,fetchTranscript: Bool){
        if username == "DEMO" && password == "DEMO" { //checks if the user is using the app in demo-mode
            let demoTranscript = FileReader.readFileContent("CopyBirdCode/demo_transcript",typeOfResource: "xml")
            let data = demoTranscript.dataUsingEncoding(NSUTF8StringEncoding)
            let fakeNotification = NSNotification(name: "transcript_fetched", object: data)
            
            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0*Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self.parseTranscript(fakeNotification) // fake notification used when first initialized
            })
        }else{
            /*if url.substringFromIndex(url.endIndex.advancedBy(-1)) != "/" {
             url = url+"/"
             }*/
            //if user wants to also fetch transcript, do so right after authentication finishes
            if(fetchTranscript){
                NSNotificationCenter.defaultCenter().removeObserver(self, name: "authentication_finished", object: nil)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PowerAPI.fetchTranscript(_:)), name:"authentication_finished", object: nil)
            }
            client.myAuthenticate(user: username,with: password) //for some reason "client.authenticate calls the wrong function"
        }
    }
    func fetchTranscript(notification : NSNotification){
        client.fetchTranscript()
    }
    func parseTranscript(notification : NSNotification){ //sloppy fix double transcript_parsed thing
        //print(NSString(data: notification.object as! NSData, encoding: NSUTF8StringEncoding))
        do{
            let data = notification.object as! NSData
            if !String(data: notification.object as! NSData, encoding: NSUTF8StringEncoding)!.containsString("studentDataVOs") {
                NSNotificationCenter.defaultCenter().postNotificationName("transcript_parsed", object: false) //
                return
            }
            let xmlDoc = try AEXMLDocument(xmlData: data)
            //print(xmlDoc.xmlString)
            let studentData = xmlDoc.root["soapenv:Body"]["ns:getStudentDataResponse"]["return"]["studentDataVOs"]
            self._studentInformation = Packager.information(studentData["student"])
            let assignmentCategories = Packager.assignmentCategories(studentData["assignmentCategories"])
            let assignmentScores = Packager.assignmentScores(studentData["assignmentScores"])
            let finalGrades = Packager.finalGrades(studentData["finalGrades"])
            let reportingTerms = Packager.reportingTerms(studentData["reportingTerms"])
            let teachers = Packager.teachers(studentData["teachers"])
            let assignments: [String: [Assignment]] = Packager.assignments(studentData["assignments"], assignmentCategories: assignmentCategories, assignmentScores: assignmentScores)
            self._sections = Packager.sections(studentData["sections"], assignments: assignments, finalGrades: finalGrades, reportingTerms: reportingTerms, teachers: teachers)
            //These notifications are part of the final design pattern (screw ios)
            NSUserDefaults.standardUserDefaults().setObject(notification.object, forKey: "transcript")
            NSNotificationCenter.defaultCenter().postNotificationName("transcript_parsed", object: true)
        }catch{
            NSNotificationCenter.defaultCenter().postNotificationName("transcript_parsed", object: false)
            print("\(error)")
        }
    }
    func logout(){
        NSUserDefaults.standardUserDefaults().removeObjectForKey("transcript")
        _studentInformation = [String: String]()
        _sections = [Section]()
        client = SoapClient()
        print("Just reset powerapi")
        //stop auto-grade-change checking
    }
}
