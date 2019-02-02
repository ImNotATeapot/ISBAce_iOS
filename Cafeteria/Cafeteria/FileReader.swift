//
//  SwiftFileReader.swift
//  CopyBirdCode
//
//  Created by e2014785 on 1/15/16.
//  Copyright © 2559 ISB Software Development Club. All rights reserved.
//

import Foundation

class FileReader {
    class func readFileContent(nameOfResource: String, typeOfResource: String) -> String {
        let path = NSBundle.mainBundle().pathForResource(nameOfResource, ofType: typeOfResource)
        var fileContent: String? = nil;
        do {
            fileContent = try String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
        } catch _ as NSError {
            print("Error")
        }
        return fileContent!
    }
    class func writeFileContent(writingContent: String, nameOfResource: String, typeOfResource: String) {
        do {
            try writingContent.writeToFile(NSBundle.mainBundle().pathForResource(nameOfResource, ofType: typeOfResource)!, atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
        }
    }
    
    func writeFileContent(writingContent: String, nameOfResource: String, typeOfResource: String, printResult: Bool) {
        do {
            try writingContent.writeToFile(NSBundle.mainBundle().pathForResource(nameOfResource, ofType: typeOfResource)!, atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
        }
    }
}