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
        
        
        if UserDefaults.standard.dictionary(forKey: PROJECT_KEY) == nil {
            let project: [Project] = [
                Project(projectName: "Project 1", members: ["Amy", "Iris"], tasks: [Task(taskName: "Project 1 Assignment 1", taskWeight: 20), Task(taskName: "Project 1 Assignment 2", taskWeight: 80)]),
                Project(projectName: "Project 2", members: ["Luna", "Clara", "Mia"], tasks: [Task(taskName: "Project 2 Assignment 1", taskWeight: nil)])
            ]
            // Encode the projectData array as JSON data
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(project) {
                // Save the encoded data to UserDefaults
                UserDefaults.standard.set(encoded, forKey: PROJECT_KEY)
            }
        }
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
    
    @IBAction func createNewProject(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "NewProjectController") as! NewProjectController
        if let data = UserDefaults.standard.data(forKey: PROJECT_KEY),
           let projects = try? JSONDecoder().decode([Project].self, from: data) {
//            vc.selectedProject = projects[0]
            vc.selectedProject = Project(projectName: "", members: [], tasks: [])
        } else {
            // Handle the case where there is no data or decoding fails
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

