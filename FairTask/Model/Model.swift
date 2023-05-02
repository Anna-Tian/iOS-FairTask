//
//  Model.swift
//  FairTask
//
//  Created by Na Tian on 3/5/2023.
//

import UIKit

let PROJECT_KEY = "project"

struct Task: Codable {
    var taskName: String
    var taskWeight: Int?
}

struct Project: Codable {
    var projectName: String
    var members: [String]
    var tasks: [Task]
}
