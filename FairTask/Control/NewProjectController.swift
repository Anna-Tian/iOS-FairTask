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
    
    var selectedProject: Project = Project(projectName: "", members: [], tasks: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        
        memberTable.register(AddMemberTableViewCell.nib(), forCellReuseIdentifier: AddMemberTableViewCell.identifier)
        memberTable.dataSource = self
        memberTable.delegate = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedProject.members.isEmpty {
            return 1 // only display the "Add Member" cell
        } else {
            return selectedProject.members.count + 1 // display member cells and the "Add Member" cell
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= selectedProject.members.count {
            // Display add cell
            let addCell = tableView.dequeueReusableCell(withIdentifier: "AddMemberTableViewCell", for: indexPath) as! AddMemberTableViewCell
            addCell.delegate = self // set the delegate to the view controller
            return addCell
        } else {
            // Display member cell
            let listMemberCell = tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath)
            listMemberCell.textLabel?.text = selectedProject.members[indexPath.row]
            return listMemberCell
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            selectedProject.members.remove(at: indexPath.row)
            saveUpdatedProject()
            memberTable.reloadData()
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
