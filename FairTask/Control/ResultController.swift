//
//  ResultController.swift
//  FairTask
//
//  Created by xin weng on 30/4/2023.
//

import Foundation
import UIKit

class ResultController: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var successLabel: UILabel!
    

    @IBAction func retryButtonTapped(_ sender: Any) {
        // Store the current task distribution in the historyResults array
        historyResults.append(taskDistributions)
        
        reloadTableData()
    }
    
    var taskDistributions: [TaskDistribution] = []
    var historyResults: [[TaskDistribution]] = []
    var selectedProject: Project!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the successLabel's text based on the result type
        successLabel.text = taskDistributions[0].taskName.isEmpty ?"Successfully Shuffled!" : "Successfully Divided!"
        reloadTableData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // Retrieve result data to the tableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == historyTableView {
            return historyResults.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == historyTableView {
            return "Attempt \(section + 1)"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == resultTableView {
            return taskDistributions.count
        } else if tableView == historyTableView {
            return historyResults[section].count
        }
        return 0
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == resultTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath)

            let taskDistribution = taskDistributions[indexPath.row]
            if taskDistribution.taskName.isEmpty {
                cell.textLabel?.text = taskDistribution.memberName
            } else if taskDistribution.assignedTaskWeight == 0 {
                cell.textLabel?.text = "\(taskDistribution.memberName) - \(taskDistribution.taskName)"
            } else {
                cell.textLabel?.text = "\(taskDistribution.memberName) - \(taskDistribution.taskName) (\(taskDistribution.assignedTaskWeight))"
            }

            return cell
        } else if tableView == historyTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)

            let taskDistribution = historyResults[indexPath.section][indexPath.row]
            if taskDistribution.taskName.isEmpty {
                cell.textLabel?.text = taskDistribution.memberName
            } else if taskDistribution.assignedTaskWeight == 0 {
                cell.textLabel?.text = "\(taskDistribution.memberName) - \(taskDistribution.taskName)"
            } else {
                cell.textLabel?.text = "\(taskDistribution.memberName) - \(taskDistribution.taskName) (\(taskDistribution.assignedTaskWeight))"
            }

            return cell
        }

        return UITableViewCell()
    }
    
    func reloadTableData() {
        // Perform the randomisation process again and store the results in a new array
        let newTaskDistributions = randomiseTasksAgain()

        // Update the main result table view
        taskDistributions = newTaskDistributions
        resultTableView.reloadData()
        
        // Reload the history table view
        historyTableView.reloadData()
    }

    
    func randomiseTasksAgain() -> [TaskDistribution] {
        guard let project = selectedProject else {
            return []
        }

        // Check if selected project has tasks, if no tasks, randomise the order of members
        if project.tasks.isEmpty {
            return project.members.shuffled().map { TaskDistribution(memberName: $0, taskName: "", assignedTaskWeight: 0) }
        }

        // Divide tasks based on equal percentage and random assign to members
        let taskDistributions = project.tasks.isEmpty || project.tasks.filter { $0.taskWeight != nil }.isEmpty ?
            assignTasksToMembersWithoutWeight(project: project) :
            assignTasksToMembers(project: project)

        return taskDistributions
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
}
