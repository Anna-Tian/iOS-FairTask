//
//  ResultController.swift
//  FairTask
//
//  Created by xin weng on 30/4/2023.
//

import Foundation
import UIKit

class ResultController: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var resultTableView: UITableView!
    
    
    var taskDistributions: [TaskDistribution] = []
    var shuffledMembers: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the successLabel's text based on the result type
        if !taskDistributions.isEmpty {
            successLabel.text = "Successfully Divided!"
        } else if !shuffledMembers.isEmpty {
            successLabel.text = "Successfully Shuffled!"
        }
    }
    
    // Retrieve result data to the tableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return !taskDistributions.isEmpty ? taskDistributions.count : shuffledMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath)
        
        if !taskDistributions.isEmpty {
            let taskDistribution = taskDistributions[indexPath.row]
            cell.textLabel?.text = "\(taskDistribution.memberName) - \(taskDistribution.taskName) (\(taskDistribution.assignedTaskWeight))"
        } else {
            let memberName = shuffledMembers[indexPath.row]
            cell.textLabel?.text = memberName
        }
        
        return cell
    }
}
