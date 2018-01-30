//
//  ProfileViewController.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import UIKit
import CoreData

struct ProfileContent {
    var key: String
    var value: String
}

class ProfileViewController: BaseViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    var tableViewDataSource: [ProfileContent] = []
    
    // MARK: - Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Profile"
        loadUserInfo()
    }
    
    // MARK: - Private
    
    private func loadUserInfo() {
       
        //  TODO: Data Provider
        var userRecordsArray: [User] = []
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        do {
            userRecordsArray = try operationsManager?.mainContext?.fetch(fetchRequest) as! [User]
        } catch {
//            debugPrint("Fetching user info objects failed")
        }
        
        if let user = userRecordsArray.first {
            
            tableViewDataSource.append(ProfileContent(key: "Name", value: user.name ?? "No name"))
            tableViewDataSource.append(ProfileContent(key: "Email", value: user.email ?? "No email"))
            tableViewDataSource.append(ProfileContent(key: "Type", value: user.type ?? "No type"))
            tableViewDataSource.append(ProfileContent(key: "Location", value: user.location ?? "No location"))
            tableViewDataSource.append(ProfileContent(key: "Biography", value: user.bio ?? "No bio"))
            tableViewDataSource.append(ProfileContent(key: "Company", value: user.company ?? "No company"))
            tableViewDataSource.append(ProfileContent(key: "Login", value: user.login ?? "No login"))

            tableViewDataSource.append(ProfileContent(key: "Number of public gits", value: String(user.publicGists)))
            tableViewDataSource.append(ProfileContent(key: "Number of public repo", value: String(user.publicRepos)))
            tableView.reloadData()
            
            let getProfileImageOperation = GetProfileImageOperation(user: user)
            operationsManager?.startOperation(operation: getProfileImageOperation, completion: { (status, result, errors) in
                if let image = result?[GetProfileImageOperation.key] as? UIImage {
                    self.imageView.image = image
                    self.tableView.tableHeaderView = self.headerView
                }
            })
            
        } else {
            tableView.isHidden = true
        }
    }
    
}

// MARK: - UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDataSource.isEmpty ? 0 : tableViewDataSource.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "value1")
        
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "value1")
        }
        
        let profileContent = tableViewDataSource[indexPath.row]
        cell!.textLabel?.text = profileContent.key
        cell!.detailTextLabel?.text = profileContent.value
        
        return cell!
    }
    
}

// MARK: - UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

