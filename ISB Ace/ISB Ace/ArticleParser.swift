
//
//  ArticleParser.swift
//  ISB Ace
//
//  Created by Patriya Piyawiroj on 3/19/2559 BE.
//  Copyright © 2559 ISB Software Development Club. All rights reserved.
//


import UIKit

//
protocol ParserDelegate {
    
    // Any Parser Delegate must implement this method
    // Parser will call this method when article array is ready
    func articlesReady()
    
}

class ArticleParser: NSObject, NSXMLParserDelegate {
    
    let feedURLString:String = "http://inside.isb.ac.th/pn/feed"
    
    var articles:[Article] = [Article]()
    var delegate:ParserDelegate?
    
    // Parser vars
    var currentElement:String = ""
    var foundCharacters:String = ""
    var currentArticle:Article = Article()
    
    
    func getArticles() {
        
        // Create URL
        let feedURL:NSURL? = NSURL(string: feedURLString)
        
        // Initialize new parser
        let feedParser:NSXMLParser? = NSXMLParser(contentsOfURL: feedURL!)
        
        // Kick off feed helper to parse NSURL
        if let actualFeedParser = feedParser {
            
            // Download feed and parse out articles
            actualFeedParser.delegate = self
            actualFeedParser.parse()
        }
        
    }
    
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        if elementName == "item" ||
            elementName == "title" ||
            elementName == "description" ||
            elementName == "link" {
            
            self.currentElement = elementName
        }
        
        if elementName == "item" {
            self.currentArticle = Article()
        }
        
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String?) {
        
        if self.currentElement == "item" ||
            self.currentElement == "title" ||
            self.currentElement == "description" ||
            self.currentElement == "link" {
            
            self.foundCharacters += string!
        }
        
    }
    
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "title" {
            let title:String = foundCharacters.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            self.currentArticle.articleTitle = title
        }
            
        else if elementName == "description" {
            let description:String = foundCharacters.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            self.currentArticle.articleDescription = description
        }
            
            
        else if elementName == "link" {
            let link:String = foundCharacters.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            self.currentArticle.articleLink = link
        }
            
            
        else if elementName == "item" {
            self.articles.append(self.currentArticle)
            
        }
        
        self.foundCharacters = ""
        
    }
    
    
    func parserDidEndDocument(parser: NSXMLParser) {
        
        // Notify the view controller that they array of articles is ready
        
        // Check if there's an object assigned as delegate.. If so, call articlesReady method
        if let actualDelegate = self.delegate {
            // There is an obj assigned to delegate property
            actualDelegate.articlesReady()
        }
        
    }
    
    
}