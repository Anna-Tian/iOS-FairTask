//
//  Model.swift
//  FairTask
//
//  Created by Na Tian on 3/5/2023.
//
// comment update
import Foundation
import UIKit

let PROJECT_KEY = "project"

struct Task: Codable, Hashable {
    var taskName: String
    var taskWeight: Int?
}

struct Project: Codable, Hashable {
    var projectName: String
    var members: [String]
    var tasks: [Task]
}

// Define the Project dictionary
struct ProjectDict: Codable {
    var projects: [Project]
}

struct TaskDistribution: Codable, Hashable {
    var memberName: String
    var taskName: String
    var assignedTaskWeight: Int
}

func showPopUpWindow(title: String?, placeholders: [String], initialValues: [String?], requiredFields: Set<Int>, viewController: UIViewController, keyboardType: [UIKeyboardType], saveHandler: (([String]) -> Void)?) {
    let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
    
    for (index, placeholder) in placeholders.enumerated() {
        alertController.addTextField { (textField) in
            textField.placeholder = placeholder
            textField.text = initialValues[index]
            textField.keyboardType = keyboardType[index]
        }
    }
    
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action) in
        var values = [String]()
        for (index, textField) in alertController.textFields!.enumerated() {
            values.append(textField.text ?? "")
            
            // alert if required field is empty
            if requiredFields.contains(index) && (textField.text ?? "").isEmpty {
                let errorAlertController = UIAlertController(title: "Error", message: "Please fill the required field!", preferredStyle: .alert)
                errorAlertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action) in
                    viewController.present(alertController, animated: true, completion: nil)
                }))
                viewController.present(errorAlertController, animated: true, completion: nil)
            }
        }
        saveHandler?(values)
    }))
    
    viewController.present(alertController, animated: true, completion: nil)
}

func showAlert(title: String, message: String, viewController: UIViewController) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    viewController.present(alertController, animated: true, completion: nil)
}
