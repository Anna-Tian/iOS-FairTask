//
//  NewProjectController.swift
//  FairTask
//
//  Created by xin weng on 30/4/2023.
//

import Foundation
import UIKit

class NewProjectController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var memberTable: UITableView!
    @IBOutlet weak var taskTable: UITableView!
    @IBOutlet weak var totalMemberLabel: UILabel!
    
    var selectedProject: Project = Project(projectName: "", members: [], tasks: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        
        totalMemberLabel.text = "Total: \(selectedProject.members.count)"
        
        memberTable.dataSource = self
        memberTable.delegate = self
        
        taskTable.dataSource = self
        taskTable.delegate = self
    }
    
    @IBAction func addMember(_ sender: Any) {
        showAlertController(
            title: "Add Member",
            placeholders: ["Enter member name*"],
            initialValues: [""],
            requiredFields: [0],
            viewController: self,
            keyboardType: [.default]
        ) {(values) in
            // if value is not empty, append member name to selectedProject
            if !values[0].isEmpty {
                self.selectedProject.members.append(values[0])
                self.saveUpdatedProject()
                self.memberTable.reloadData()
            }
        }
    }
    
    @IBAction func addTask(_ sender: Any) {
        showAlertController(
            title: "Edit Task",
            placeholders: ["Enter task name*", "Enter task weight"],
            initialValues: ["", ""],
            requiredFields: [0],
            viewController: self,
            keyboardType: [.default, .numberPad]
        ) {(values) in
            // if value is not empty, append task name and task weight to selectedProject
            if !values[0].isEmpty {
                let newTask = Task(taskName: values[0], taskWeight: Int(values[1]))
                self.selectedProject.tasks.append(newTask)
                self.saveUpdatedProject()
                self.taskTable.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRow = 1
        switch tableView {
        case memberTable:
            // display the "Add member" cell if no members in the list, else display members and "Add member" cell
            numberOfRow = selectedProject.members.count
        case taskTable:
            numberOfRow = selectedProject.tasks.count
        default:
            break
        }
        return numberOfRow
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        switch tableView {
        case memberTable:
            // Display member cell
            let listMemberCell = tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath)
            listMemberCell.textLabel?.text = selectedProject.members[indexPath.row]
            cell = listMemberCell
        case taskTable:
            // Display task cell
            let listTaskCell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
            let taskWeight = selectedProject.tasks[indexPath.row].taskWeight != nil ? "\(selectedProject.tasks[indexPath.row].taskWeight!)" : ""
            listTaskCell.textLabel?.text = selectedProject.tasks[indexPath.row].taskName + " - " + taskWeight + "%"
            cell = listTaskCell
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case memberTable:
            showAlertController(
                title: "Edit Member",
                placeholders: ["Enter member name*"],
                initialValues: [self.selectedProject.members[indexPath.row]],
                requiredFields: [0],
                viewController: self,
                keyboardType: [.default]
            ) {(values) in
                self.selectedProject.members[indexPath.row] = values[0]
                self.saveUpdatedProject()
                self.memberTable.reloadData()
            }
        case taskTable:
            let taskWeight = self.selectedProject.tasks[indexPath.row].taskWeight
            showAlertController(
                title: "Edit Task",
                placeholders: ["Enter task name*", "Enter task weight"],
                initialValues: [self.selectedProject.tasks[indexPath.row].taskName, taskWeight != nil ? "\(taskWeight!)" : ""],
                requiredFields: [0],
                viewController: self,
                keyboardType: [.default, .numberPad]
            ) {(values) in
                self.selectedProject.tasks[indexPath.row].taskName = values[0]
                self.selectedProject.tasks[indexPath.row].taskWeight = Int(values[1]) ?? nil
                self.saveUpdatedProject()
                self.taskTable.reloadData()
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            switch tableView {
            case memberTable:
                selectedProject.members.remove(at: indexPath.row)
            case taskTable:
                selectedProject.tasks.remove(at: indexPath.row)
            default:
                break
            }
            saveUpdatedProject()
            tableView.reloadData()
        }
    }
    
    func saveUpdatedProject() {
        // Encode the updated project data as JSON
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode([selectedProject]) {
            // Save the encoded data to UserDefaults
            UserDefaults.standard.set(encoded, forKey: PROJECT_KEY)
        }
        totalMemberLabel.text = "Total: \(selectedProject.members.count)"
    }
}
