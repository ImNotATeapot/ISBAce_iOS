//
//  Tutorial.swift
//  ISB Ace
//
//  Created by e2014785 on 4/4/16.
//  Copyright © 2016 ISB Software Development Club. All rights reserved.
//

import Foundation
import UIKit

class Tutorial {
    var viewController:UIViewController?
    var image:UIImageView?
    var fullScreenButton:UIButton?
    let defaults = NSUserDefaults.standardUserDefaults()
    var meme = String()
    
    init(viewController: UIViewController, meme: String) { //viewController (misspelled) basically is the viewController you want to display the image in, and meme, is the tutorial image name.
        self.viewController = viewController
        self.meme = meme
        image = UIImageView(frame: viewController
            .view.frame)
        //image!.backgroundColor = UIColor.blueColor()
        image!.alpha = 1
        image!.image = UIImage(named: meme)
        checkAndSetEnabled(meme)
    }
    //checks if tutorial has been dismissed by user before
    func checkAndSetEnabled(tutorialID: String){
        if defaults.boolForKey("hide_\(tutorialID)"){
            enabled = false
        }else{
            enabled = true
        }
    }
    
    private var _enabled = true
    var enabled: Bool{
        get {
            return _enabled
        }
        set {
            _enabled = newValue
            if newValue {
                self.viewController!.navigationController!.view.addSubview(image!)
                enableButton()
                
            }else{
                image?.removeFromSuperview()
                fullScreenButton?.removeFromSuperview()
            }
        }
    }

    private func enableButton(){
        fullScreenButton = UIButton(frame: CGRect(x: 0, y: 0, width: viewController!.view.frame.size.width, height: viewController!.view.frame.size.height))
        fullScreenButton?.addTarget(self, action: #selector(Tutorial.buttonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        viewController!.navigationController!.view.addSubview(fullScreenButton!)
    }
    @objc func buttonClicked(sender: UIButton){
        //print("clicked")
        defaults.setBool(true,forKey: "hide_\(meme)")
        enabled = false
    }
    /*
     let fileManager = NSFileManager.defaultManager()
     //let projectLocation = NSSearchPathForDirectoriesInDomains(, .UserDomainMask, true) [0]
     let bundle = NSBundle.mainBundle()
     
     func checkForFile(){ // DONT WORRY ABOUT THIS
     var path = bundle.pathForResource("Tutorial", ofType:"")
     print(path)
     
     if (path != nil) {
     if self.fileManager.fileExistsAtPath(path!) {
     playTutorial();
     }
     }
     
     }
     
     func playTutorial() {
     
     }
     */
}
