//
//  ViewController.swift
//  Cafeteria
//
//  Created by 15998 on 5/18/16.
//  Copyright © 2016 Software Development Club. All rights reserved.
//
import UIKit
import Foundation

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        parseCafeteria(5)//this is the function you're interested in - the parameter is the day of the week from 1-5
    }
    //This function parses a TEST FILE at HTML/sample_site.html into the respective Sections and Food items.  In the real app, the test file will need to be replaced with the latest cafeteria page found at studentdevelopers.isb.ac.th/cafeteria
    func parseCafeteria(day: Int){
        let html = FileReader.readFileContent("HTML/sample_site", typeOfResource: "html")
        if let doc = HTML(html: html, encoding: NSUTF8StringEncoding) {
            //print(doc.title)
            let div = doc.xpath("//div[@id='slide\(day)']").at(0)!
            var sections = [Section]()
            print("DAY: "+div.xpath("./h1[1]").at(0)!.text!) //print the day as per the caf site
            for header in div.xpath("./div/table/tr[1]/td"){
                sections.append(Section(name: header.text!))
                //print("section: "+header.text!)
            }
            for row in div.xpath("./div/table/tr[position()>1]"){
                var col = 0
                for food in row.xpath("./td"){
                    let img = food.xpath("./a/img").at(0)!
                    let urlString = img["src"]!
                    let url = NSURL(string: urlString)!
                    let imgID = img["id"]!
                    let matches = matchesForRegexInText("(?:\(imgID):')(.*?)(?:',)", text: html)
                    if matches.count > 0{
                        let description = matches[0]
                        sections[col].foods.append(Food(imageURL: url,description: description))
                    }
                    col += 1
                }
            }
            //This loop is completely for show since it just shows off the data that was just parsed feel free to remove it
            for section in sections{
                print("SECTION: "+section.name)
                var i = 0
                for food in section.foods{
                    print("\t\(i): \(food.imageURL)") //print away each food's image url
                    //print("\t\(i): \(food.description)") //print away each food's description
                    i+=1
                }
            }
        }
    }
    //For devs more familiar with java than with swift, a STRUCT as seen bellow is like a class except it's safer for multithreading and memory management.
    //This struct is the "Section" i.e. Asian, Continental, Noodle, Japanese, or Vegetarian, or Live
    struct Section {
        var name: String
        var foods = [Food]()
        init(name: String){
            self.name = name
        }
    }
    //This struct represents individual food items.  The UIImage is not required in contstructor because the UIImage is set later once the app has time to fetch the images from the network. (Patriya knows about this type of operation)
    struct Food {
        var imageURL: NSURL
        var image: UIImage!
        var description: String
        init(imageURL: NSURL, description: String){
            self.imageURL = imageURL
            self.description = description
        }
    }
    //This function finds regex matches within a given string that fit a given regex search pattern... Regex made ez
    func matchesForRegexInText(regex: String!, text: String!) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matchesInString(text,
                                                options: [], range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substringWithRange($0.rangeAtIndex(1))}
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

