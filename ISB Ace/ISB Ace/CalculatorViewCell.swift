//
//  CalculatorViewCell.swift
//  ISB Ace
//
//  Created by 15998 on 4/24/2559 BE.
//  Copyright © 2559 ISB Software Development Club. All rights reserved.
//
import UIKit

class CalculatorViewCell: UITableViewCell{
    @IBOutlet weak var courseNameField: UILabel!
    @IBOutlet weak var enableSwitch: UISwitch!
    @IBOutlet weak var examWeightField: UITextField!
    @IBOutlet weak var examScoreField: UITextField!
    @IBOutlet weak var overallGradeField: UITextField!
    var index: Int!
    var isWeighted: Bool!
    var editedCallback: ((CalculatorViewCell) -> Void)!
    @IBAction func switchFlicked(sender: AnyObject) { //call one callback when any editing of cell occurs
        textFieldEdited(sender)
    }
    @IBAction func textFieldEdited(sender: AnyObject) {
        editedCallback(self)
    }
}