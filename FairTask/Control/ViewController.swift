//
//  ViewController.swift
//  FairTask
//
//  Created by Na Tian on 25/4/2023.
//
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var projectSelectionButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setProjectSelectionButton()
        // Do any additional setup after loading the view.
    }
    func setProjectSelectionButton(){
        
        let optionClosure = {(action : UIAction) in
            print(action.title)}
        
        projectSelectionButton.menu = UIMenu (children : [
            UIAction(title : "Project 1", state : .on, handler: optionClosure),
            UIAction(title : "Project 2", handler: optionClosure),
            UIAction(title : "Project 3", handler: optionClosure)])
        
        projectSelectionButton.showsMenuAsPrimaryAction = true
        projectSelectionButton.changesSelectionAsPrimaryAction = true
    }
}

