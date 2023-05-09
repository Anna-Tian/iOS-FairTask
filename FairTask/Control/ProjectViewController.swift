//
//  ProjectViewController.swift
//  FairTask
//
//  Created by Na Tian on 4/5/2023.
//

import UIKit

class ProjectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var memberTable: UITableView!
    @IBOutlet weak var taskTable: UITableView!
    @IBOutlet weak var totalMemberLabel: UILabel!
    @IBOutlet weak var randomiseButton: UIButton!
    
    @IBOutlet weak var memberHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var taskHeightConstant: NSLayoutConstraint!
    
    var selectedProject: Project = Project(projectName: "", members: [], tasks: [])
    var selectedProjectIndex: Int = 0
    var projectDict = ProjectDict(projects: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // initialise the variables
        projectNameLabel.text = selectedProject.projectName.isEmpty ? "Unnamed Project" : selectedProject.projectName
        totalMemberLabel.text = "Total: \(selectedProject.members.count)"
        randomiseButton.isEnabled = selectedProject.members.count == 0 ? false : true
        deleteButton.isEnabled = selectedProjectIndex < projectDict.projects.count ? true : false
        
        memberHeightConstant.constant = CGFloat(Double(selectedProject.members.count) * 45)
        taskHeightConstant.constant = CGFloat(Double(selectedProject.tasks.count) * 45)
        
    }
    
    @IBAction func editProjectName(_ sender: Any) {
        let projectName = self.selectedProject.projectName
        showPopUpWindow(
            title: "Change Project Name",
            placeholders: ["Project Name"],
            initialValues: [projectName.isEmpty || projectName == "Unnamed Project" ? "" : projectName],
            requiredFields: [],
            viewController: self,
            keyboardType: [.default]
        ) {(values) in
            self.selectedProject.projectName = values[0].isEmpty ? "Unnamed Project" : values[0]
            self.projectNameLabel.text = values[0].isEmpty ? "Unnamed Project" : values[0]
            self.saveUpdatedProject()
        }
    }
    
    @IBAction func addMember(_ sender: Any) {
        showPopUpWindow(
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
        showPopUpWindow(
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
            listTaskCell.textLabel?.text = selectedProject.tasks[indexPath.row].taskName
            listTaskCell.detailTextLabel?.text = taskWeight
            cell = listTaskCell
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case memberTable:
            showPopUpWindow(
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
            showPopUpWindow(
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
    
    @IBAction func randomiseTasks(_ sender: Any) {
        /** TO-DOs: (completed, keep for better understand the logic in the future)
         1. check if selectedProject has task
            1.1. true: go to Step 2
            1.2. false: random order members, print the result
         2. check any of the task has weight value,
             2.1. if all of the task has no weight,
                2.1.1. if members.count != tasks.count, then pops up an alert: "Each member should asign one task".
                2.1.2. else random assign task to different member.
             2.2. else if only some tasks have weight, and some not, then pop up an alert: " Either leave all th weight field blank or fill all the weight field"
             2.3. else if weight sum not equal to 100, then pop up an alert: " weight should be 0 or 100 "
             2.4. else go to Step 3
         3. assign the tasks to members in a way that each member's assigned task weights are within 20% of the average weight per member,
         and return a list of 'TaskDistribution' instances indicating which member has been assigned which task and how much of it.
            in detailed:
             1. calculate the average weight per member based on the total weight and the number of members
             2. iterate through each task in the project until all task are assigned
             3. for each task, iterate through the members in a shuffled order until the weight of that member is within the acceptable range
             4. assign the task to that member and update their weight and reamining tasks list accordingly.
             5. if no member can be found to accept the task at full weight, assign a portion of the task to the member with the lowest weight, update the weight of the remaining portion of the task and continue to the next tasks
             6. when all the task have been assigned, return the result task distribution
         */
        
        /**
         some input and output test:
         let input1: Project = Project(projectName: "Project 1", members: ["A", "B"], tasks: [Task(taskName: "a", taskWeight: 20), Task(taskName: "b", taskWeight: 80)])
         let input2: Project = Project(projectName: "Project 2", members: ["A", "B", "C", "D"], tasks: [Task(taskName: "a", taskWeight: 30), Task(taskName: "b", taskWeight: 10), Task(taskName: "c", taskWeight: 60)])
         let input3: Project = Project(projectName: "Project 1", members: ["A", "B", "C", "D"], tasks: [Task(taskName: "a", taskWeight: 30), Task(taskName: "b", taskWeight: 30), Task(taskName: "c", taskWeight: 20), Task(taskName: "d", taskWeight: 20)])
         let input4: Project = Project(projectName: "Project 1", members: ["A", "B", "C"], tasks: [Task(taskName: "a", taskWeight: 30), Task(taskName: "b", taskWeight: 30), Task(taskName: "c", taskWeight: 40)])
         let input5: Project = Project(projectName: "Project 1", members: ["A", "B", "C"], tasks: [Task(taskName: "a", taskWeight: 20), Task(taskName: "b", taskWeight: 30), Task(taskName: "c", taskWeight: 50)])
         let input6: Project = Project(projectName: "Project 1", members: ["A", "B", "C", "D"], tasks: [Task(taskName: "a", taskWeight: 20), Task(taskName: "b", taskWeight: 30), Task(taskName: "c", taskWeight: 50)])
         let input7: Project = Project(projectName: "Project 1", members: ["A", "B", "C", "D"], tasks: [Task(taskName: "a", taskWeight: 10), Task(taskName: "b", taskWeight: 10), Task(taskName: "c", taskWeight: 10), Task(taskName: "d", taskWeight: 10), Task(taskName: "e", taskWeight: 10), Task(taskName: "f", taskWeight: 10), Task(taskName: "g", taskWeight: 20), Task(taskName: "h", taskWeight: 20)])
         
         inputShort1 = ["A", "B"], [("a", 20), ("b", 80)]
         result = ["A - b(50)", "B - a(20)", "B - b(30)"]

         inputShort2 = ["A", "B", "C", "D"], [("a", 30), ("b", 10), ("c", 60)]
         result = ["A - a(30)", "C - c(25)", "B - b(10)", "D - c(25)", "B - c(10)"]

         inputShort3 = ["A", "B", "C", "D"], [("a", 30), ("b", 30), ("c", 20), ("d", 20)]
         result = ["A - d(20)", "B - b(30)", "C - a(30)", "D - c(20)"]

         inputShort4 = ["A", "B", "C"], [("a", 30), ("b", 30), ("c", 40)]
         result = ["A - a(30)", "B - c(40)", "C - b(30)"]

         inputShort5 = ["A", "B", "C"], [("a", 20), ("b", 30), ("c", 50)]
         result = ["A - b(30)", "B - a(20)", "C - c(33)", "B - c(17)"]

         inputShort6 = ["A", "B", "C", "D"], [("a", 20), ("b", 30), ("c", 50)]
         result = ["A - a(20)", "C - c(25)", "B - b(30)", "D - c(25)"]

         inputShort7 = ["A", "B", "C", "D"], [("a", 10), ("b", 10), ("c", 10), ("d", 10), ("e", 10), ("f", 10), ("g", 20), ("h", 20)]
         result = ["A - h(20)", "A - b(10)", "B - c(10)", "B - d(10)", "B - a(10)", "C - f(10)", "C - g(20)", "D - e(10)"]
         */
        
        // Check if selected project has tasks, if no tasks, randomise the order of members
        if selectedProject.tasks.isEmpty {
            let shuffledMembers = selectedProject.members.shuffled()
            performSegue(withIdentifier: "goToResult", sender: shuffledMembers)
            return
        }
//            // TO-DOs: pass data to result ViewController
//            showAlert(title: "Successful", message: "Random order of members: \(shuffledMembers)", viewController: self)
//            return
//        }
        
        // Check task weight with different condition
        let tasksWithWeight = selectedProject.tasks.filter { $0.taskWeight != nil }
        let totalWeight = selectedProject.tasks.reduce(0) { $0 + ($1.taskWeight ?? 0) }
        if tasksWithWeight.isEmpty && selectedProject.members.count != selectedProject.tasks.count {
            showAlert(title: "Failed", message: "Each member should assign one task", viewController: self)
            return
        } else if !tasksWithWeight.isEmpty && tasksWithWeight.count != selectedProject.tasks.count {
            showAlert(title: "Failed", message: "Either leave all the weight field blank or fill all the weight field", viewController: self)
            return
        } else if totalWeight != 100 && totalWeight != 0 {
            showAlert(title: "Failed", message: "Weight should be 0 or 100", viewController: self)
            return
        }
        
        // Divide tasks based on equal percentage and random assign to members
        let taskDistributions = tasksWithWeight.isEmpty ?
        assignTasksToMembersWithoutWeight(project: selectedProject) :
        assignTasksToMembers(project: selectedProject)
        
        
//        // TO-DOs: pass data to result ViewController
//        let taskDistributionStrings = taskDistributions.map { distribution in
//            "\(distribution.memberName) - \(distribution.taskName)(\(distribution.assignedTaskWeight))"
//        }
//        showAlert(title: "Successful", message: "Task Distributions: \(taskDistributionStrings)", viewController: self)
        
        // Perform the segue to ResultViewController
            performSegue(withIdentifier: "goToResult", sender: taskDistributions)
    }
    
        
    func assignTasksToMembersWithoutWeight(project: Project) -> [TaskDistribution] {
        var taskDistributions: [TaskDistribution] = []
        var taskIndex = 0
        var remainingTasks = project.tasks.shuffled()
        
        // iterate unitl all tasks are assigned
        while !remainingTasks.isEmpty {
            // assigns the current task to each member of the project in turn
            for member in project.members {
                let taskDistribution = TaskDistribution(memberName: member, taskName: remainingTasks[taskIndex].taskName, assignedTaskWeight: 0)
                taskDistributions.append(taskDistribution)
                remainingTasks.remove(at: taskIndex)
                if remainingTasks.isEmpty {
                    break
                }
            }
            taskIndex += 1
            
        }
        return taskDistributions
    }

    func assignTasksToMembers(project: Project) -> [TaskDistribution] {
        let totalWeight = project.tasks.reduce(0) { $0 + ($1.taskWeight ?? 0) }
        // calculate the average weight per member
        let weightPerMember = Double(totalWeight) / Double(project.members.count)

        var remainingTasks = project.tasks.shuffled()
        var taskDistributions: [TaskDistribution] = []
        
        // set the initial weight for each member to 0
        var assignedTasks: [String: [TaskDistribution]] = [:]
        for member in project.members {
            assignedTasks[member] = []
        }
        
        var taskIndex = 0
        // iterate unitl all tasks are assigned
        while !remainingTasks.isEmpty {
            let task = remainingTasks[taskIndex]
            var taskAssigned = false

            for member in project.members {
                // Check if the task weight plus the member's current weight is within the acceptable range
                if Double((task.taskWeight ?? 0)) + Double(assignedTasks[member]!.reduce(0) { $0 + $1.assignedTaskWeight }) <= weightPerMember * 1.2 {
                    // assign the task to the member
                    let assignedTaskWeight = task.taskWeight ?? 0
                    let taskDistribution = TaskDistribution(memberName: member, taskName: task.taskName, assignedTaskWeight: assignedTaskWeight)
                    assignedTasks[member]!.append(taskDistribution)
                    taskDistributions.append(taskDistribution)
                    
                    // remove the assigned task from the remaining tasks and mark the task as assigned
                    remainingTasks.remove(at: taskIndex)
                    taskAssigned = true
                    break
                }
            }
            
            // If the task is not assigned, assign a portion of the task to the member with the lowest weight
            if !taskAssigned {
                let minMember = assignedTasks.min { a, b in a.value.reduce(0) { $0 + $1.assignedTaskWeight } < b.value.reduce(0) { $0 + $1.assignedTaskWeight } }!.key
                let remainingWeightForMember = Int(weightPerMember) - assignedTasks[minMember]!.reduce(0) { $0 + $1.assignedTaskWeight }

                let assignedTaskWeight = remainingWeightForMember
                let taskDistribution = TaskDistribution(memberName: minMember, taskName: task.taskName, assignedTaskWeight: assignedTaskWeight)
                assignedTasks[minMember]!.append(taskDistribution)
                taskDistributions.append(taskDistribution)

                // Reduce the weight of the remaining task
                remainingTasks[taskIndex].taskWeight = (remainingTasks[taskIndex].taskWeight ?? 0) - remainingWeightForMember
            } else {
                // Reset the task index to 0 if the task was assigned
                taskIndex = 0
                continue
            }
            
            // Increment the task index, wrapping it around if it goes beyond the remaining tasks count
            taskIndex = (taskIndex + 1) % remainingTasks.count
        }

        return taskDistributions
    }
    
    
    func saveUpdatedProject() {
        // Encode the updated project data as JSON
        selectedProject.projectName = selectedProject.projectName.isEmpty ? "Unnamed Project" : selectedProject.projectName
        if (selectedProjectIndex < projectDict.projects.count) {
            projectDict.projects[selectedProjectIndex] = selectedProject
        } else {
            projectDict.projects.append(selectedProject)
        }
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(projectDict) {
            // Save the encoded data to UserDefaults
            UserDefaults.standard.set(encoded, forKey: PROJECT_KEY)
        }
        
        deleteButton.isEnabled = true
        totalMemberLabel.text = "Total: \(selectedProject.members.count)"
        randomiseButton.isEnabled = selectedProject.members.count == 0 ? false : true
        
        memberHeightConstant.constant = CGFloat(Double(selectedProject.members.count) * 45)
        taskHeightConstant.constant = CGFloat(Double(selectedProject.tasks.count) * 45)
        
        // Print the encoded data and the selected project
        if let projectDictData = UserDefaults.standard.data(forKey: PROJECT_KEY),
           let decodedProjectDict = try? JSONDecoder().decode(ProjectDict.self, from: projectDictData) {
            let projectStrings = decodedProjectDict.projects.map { project in
                "\(project.projectName) - \(project.members)"
            }
            print(projectStrings)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ResultController {
            if let taskDistributions = sender as? [TaskDistribution], segue.identifier == "goToResult" {
                vc.taskDistributions = taskDistributions
            } else if let shuffledMembers = sender as? [String], segue.identifier == "goToResult" {
                vc.shuffledMembers = shuffledMembers
            }
        }
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Are you sure?", message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action) in
            self.projectDict.projects.remove(at: self.selectedProjectIndex)
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(self.projectDict) {
                // Save the encoded data to UserDefaults
                UserDefaults.standard.set(encoded, forKey: PROJECT_KEY)
            }
            let vc = self.storyboard?.instantiateViewController(identifier: "ViewController") as! ViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}
