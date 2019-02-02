//
//  Section.swift
//  PowerAPIApp
//
//  Created by e1615998 on 2/20/16.
//  Copyright © 2016 ramicaza. All rights reserved.
//

import Foundation
///This "Section" object is really just a course.  The
class Section: NSObject{
    private var _assignments = [Assignment]()
    private var _expression = String()
    private var _finalGrade = [String: String]() //confusing stuff right here
    private var _name = String()
    private var _roomName = String()
    private var _teacher = [String: String?]()
    private var _reportingTerm = String()
    ///An array of all the assignments in the section
    var assignments: [Assignment]{
        return _assignments
    }
    ///an expression that gives the period number and helps with sorting
    var expression: String{
        return _expression
    }
    //A dictionary with percent score and letter final grade
    var finalGrade: [String: String]{
        return _finalGrade
    }
    ///The name of the course/section
    var name: String{
        return _name
    }
    ///Course's room name (if exists)
    var roomName: String{
        return _roomName
    }
    ///Dictionary containing teacher credentials
    var teacher: [String: String?]{
        return _teacher
    }
    ///String containing the reporting term i.e. "S1" or "S2"
    var reportingTerm: String{
        return _reportingTerm
    }
    init(details: [String: Any]){
        self._assignments = details["assignments"] as! [Assignment]
        self._expression = (details["section"]as! AEXMLElement)["expression"].stringValue
        self._name = (details["section"] as! AEXMLElement)["schoolCourseTitle"].stringValue
        if details["finalGrades"] != nil {
            for finalGrade in (details["finalGrades"] as! [[String: String]]){ // this loop should NEVER actually loop
                let reportingTerms = details["reportingTerms"] as! [String: String]
                self._reportingTerm = reportingTerms[finalGrade["reportingTermId"]!]!
                self._finalGrade["grade"] = finalGrade["grade"]
                self._finalGrade["percent"] = finalGrade["percent"]
            }
        }
        _roomName = (details["section"] as! AEXMLElement)["roomName"].stringValue
        let teacher = details["teacher"] as! [String: String]
        self._teacher = ["firstName": teacher["firstName"],"lastName": teacher["lastName"],"email": teacher["email"],"schoolPhone": teacher["schoolPhone"]]
    }
    override init(){
        super.init()
    }
}