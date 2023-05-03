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
    
    var selectedProject: Project = Project(projectName: "", members: [], tasks: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        
        memberTable.register(AddMemberTableViewCell.nib(), forCellReuseIdentifier: AddMemberTableViewCell.identifier)
        memberTable.dataSource = self
        memberTable.delegate = self
        
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
            numberOfRow = selectedProject.tasks.count
        default:
            print("Some things wrong...")
        }
        return numberOfRow
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        switch tableView {
        case memberTable:
            if indexPath.row >= selectedProject.members.count {
                // Display add cell
                let addCell = tableView.dequeueReusableCell(withIdentifier: "AddMemberTableViewCell", for: indexPath) as! AddMemberTableViewCell
                addCell.delegate = self // set the delegate to the view controller
                cell = addCell
            } else {
                // Display member cell
                let listMemberCell = tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath)
                listMemberCell.textLabel?.text = selectedProject.members[indexPath.row]
                cell = listMemberCell
            }
        case taskTable:
            let listMemberCell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
            listMemberCell.textLabel?.text = selectedProject.tasks[indexPath.row].taskName
            cell = listMemberCell
        default:
            break
        }
        return cell
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
    }
}
