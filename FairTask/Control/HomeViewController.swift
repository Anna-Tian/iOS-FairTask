//
//  HomeViewController.swift
//  FairTask
//
//  Created by Na Tian on 25/4/2023.
//
import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var projectSelectionButton: UIButton!
    @IBOutlet weak var goToSelectedProjectButton: UIButton!
    @IBOutlet weak var selectionLabel: UILabel!
    @IBOutlet weak var motivationLabel: UILabel!
    
    var selectedProject: Project = Project(projectName: "", members: [], tasks: [])
    var selectedProjectIndex: Int = 0
    var projects: [Project] = []
    var apiManager = ApiManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        // Reload data or update the view here
        setupData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func setupData() {
        if let projectDictData = UserDefaults.standard.data(forKey: PROJECT_KEY),
           let decodedProjectDict = try? JSONDecoder().decode(ProjectDict.self, from: projectDictData) {
            projects = decodedProjectDict.projects
            if projects.count != 0 {
                setProjectSelectionButton(projects: projects)
            }
        }
        
        projectSelectionButton.isHidden = projects.count != 0 ? false : true
        goToSelectedProjectButton.isHidden = projects.count != 0 ? false : true
        selectionLabel.isHidden = projects.count != 0 ? false : true
        
        if let motivationQuote = motivationLabel.text {
            apiManager.fetchApi(quote: motivationQuote)
        }
        
        if let motivationDictData = UserDefaults.standard.data(forKey: MOTIVATION_KEY),
           let decodedMotivationDict = try? JSONDecoder().decode(MotivationDict.self, from: motivationDictData) {
            motivationLabel.text = decodedMotivationDict.quotes.shuffled().first?.text
        } else {
            motivationLabel.text = "Let us always meet each other with smile, for the smile is the beginning of love."
        }
    }
    
    func setProjectSelectionButton(projects: [Project]){
        var children: [UIAction] = []
        var hasSelectedProject = false
        for project in projects {
            let state: UIMenuElement.State = project.projectName == selectedProject.projectName ? .on : .off
            print("State: \(state)")
            let projectAction = UIAction(title: project.projectName, state: state, handler: { [weak self] (action) in
                self?.selectedProject = project
                self?.selectedProjectIndex = projects.firstIndex(where: { $0.projectName == project.projectName })!
                hasSelectedProject = true
            })
            children.append(projectAction)
        }
        
        if !hasSelectedProject {
            selectedProject = projects.first!
            selectedProjectIndex = 0
        }
        
        projectSelectionButton.menu = UIMenu(children: children)
        projectSelectionButton.showsMenuAsPrimaryAction = true
        projectSelectionButton.changesSelectionAsPrimaryAction = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ProjectViewController {
            vc.selectedProject = selectedProject
            vc.selectedProjectIndex = selectedProjectIndex
            vc.projectDict = ProjectDict(projects: projects)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "newProjectSegue":
            selectedProjectIndex = projects.count
            selectedProject = Project(projectName: "", members: [], tasks: [])
        case "selectedProjectSegue":
            return true
        default:
            print("Cannot find identifier")
            return false
        }
        return true
    }
}

