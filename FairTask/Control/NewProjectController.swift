//
//  NewProjectController.swift
//  FairTask
//
//  Created by xin weng on 30/4/2023.
//

import Foundation
import UIKit

class NewProjectController: UIViewController, UITableViewDataSource, UITableViewDelegate, AddMemberDelegate {

    @IBOutlet weak var memberTable: UITableView!
    @IBOutlet weak var taskTable: UITableView!
    @IBOutlet weak var totalMemberLabel: UILabel!
    
    var selectedProject: Project = Project(projectName: "", members: [], tasks: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        
        totalMemberLabel.text = "Total: \(selectedProject.members.count)"
        
        memberTable.register(AddMemberTableViewCell.nib(), forCellReuseIdentifier: AddMemberTableViewCell.identifier)
        memberTable.dataSource = self
        memberTable.delegate = self
        
        taskTable.register(AddMemberTableViewCell.nib(), forCellReuseIdentifier: AddMemberTableViewCell.identifier)
        taskTable.dataSource = self
        taskTable.delegate = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRow = 1
        switch tableView {
        case memberTable:
            // display the "Add member" cell if no members in the list, else display members and "Add member" cell
            numberOfRow = selectedProject.members.isEmpty ? 1 : selectedProject.members.count + 1
        case taskTable:
            numberOfRow = selectedProject.tasks.isEmpty ? 1 : selectedProject.tasks.count + 1
        default:
            break
        }
        return numberOfRow
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        switch tableView {
        case memberTable:
            if indexPath.row >= selectedProject.members.count {
                // Display add member cell
                let addCell = tableView.dequeueReusableCell(withIdentifier: AddMemberTableViewCell.identifier, for: indexPath) as! AddMemberTableViewCell
                addCell.delegate = self // set the delegate to the view controller
                cell = addCell
            } else {
                // Display member cell
                let listMemberCell = tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath)
                listMemberCell.textLabel?.text = selectedProject.members[indexPath.row]
                cell = listMemberCell
            }
        case taskTable:
            if indexPath.row >= selectedProject.tasks.count {
                // Display add task cell
                let addCell = tableView.dequeueReusableCell(withIdentifier: AddMemberTableViewCell.identifier, for: indexPath) as! AddMemberTableViewCell
                addCell.delegate = self // set the delegate to the view controller
                addCell.newMemberTextField.placeholder = "Add new task"
                cell = addCell
            } else {
                let listTaskCell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
                let taskWeight = selectedProject.tasks[indexPath.row].taskWeight != nil ? "\(selectedProject.tasks[indexPath.row].taskWeight!)" : ""
                listTaskCell.textLabel?.text = selectedProject.tasks[indexPath.row].taskName + " - " + taskWeight + "%"
                cell = listTaskCell
            }
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case memberTable:
            if indexPath.row < selectedProject.members.count {
                // Display an alert to edit the member text
                let alertController = UIAlertController(title: "Edit Member", message: nil, preferredStyle: .alert)
                alertController.addTextField { (textField) in
                    textField.placeholder = "Enter member name"
                    textField.text = self.selectedProject.members[indexPath.row]
                }
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action) in
                    // Update the member text and reload the table
                    let newMemberName = alertController.textFields?.first?.text ?? ""
                    self.selectedProject.members[indexPath.row] = newMemberName
                    self.saveUpdatedProject()
                    self.memberTable.reloadData()
                }))
                present(alertController, animated: true, completion: nil)
            }
        case taskTable:
            if indexPath.row < selectedProject.tasks.count {
                // Display an alert to edit the task text
                let alertController = UIAlertController(title: "Edit Task", message: nil, preferredStyle: .alert)
                alertController.addTextField { (textField) in
                    textField.placeholder = "Enter task name"
                    textField.text = self.selectedProject.tasks[indexPath.row].taskName
                }
                alertController.addTextField { (textField) in
                    textField.placeholder = "Enter task weight"
                    let taskWeight = self.selectedProject.tasks[indexPath.row].taskWeight
                    textField.text = taskWeight != nil ? "\(taskWeight!)" : ""
                }
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action) in
                    // Update the task text and reload the table
                    self.selectedProject.tasks[indexPath.row].taskName = alertController.textFields?.first?.text ?? ""
                    self.selectedProject.tasks[indexPath.row].taskWeight = Int(alertController.textFields?.last?.text ?? "") ?? nil
                    self.saveUpdatedProject()
                    self.taskTable.reloadData()
                }))
                present(alertController, animated: true, completion: nil)
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
    
    // MARK: - AddMemberDelegate
    func addNewMember(_ memberName: String) {
        selectedProject.members.append(memberName)
        saveUpdatedProject()
        memberTable.reloadData() // reload the table view to display the new member cell
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
