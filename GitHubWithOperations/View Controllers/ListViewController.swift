//
//  ListViewController.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: BaseViewController {

    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var tableViewDataSource: [Repo] = []

    fileprivate var profileBarButtonItem: UIBarButtonItem {
        let profileButton = UIBarButtonItem(title: NSLocalizedString("Profile", comment: ""), style: .plain, target: self, action: #selector(profileBarButtonItemPressed(sender:)))
        return profileButton
    }
    
    fileprivate var logoutBarButtonItem: UIBarButtonItem {
        let logoutButton = UIBarButtonItem(title: NSLocalizedString("Logout", comment: ""), style: .plain, target: self, action: #selector(logoutBarButtonItemPressed(sender:)))
        return logoutButton
    }

    // MARK: - Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Repos list"
        navigationItem.rightBarButtonItem = profileBarButtonItem
        navigationItem.leftBarButtonItem = logoutBarButtonItem
        
        let getReposGroupOperation = GetReposGroupOperation()
        startAnimatingLoadingIndicator(message: NSLocalizedString("Downloading...", comment: ""))

        operationsManager?.startOperation(operation: getReposGroupOperation, completion: { (success, result, errors) in
           
            self.stopAnimatingLoadingIndicator(message: nil)
            self.loadRepos()
        })
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destination = segue.destination as? ProfileViewController {
            destination.operationsManager = operationsManager
        }
    }
    
    // MARK: - Actions
    
    @objc func profileBarButtonItemPressed(sender: UIBarButtonItem) {
        operationsManager?.cancelOperationQueue()

        performSegue(withIdentifier: "ShowProfileScreenSegueIdentifier", sender: nil)
    }
    
    @objc func logoutBarButtonItemPressed(sender: UIBarButtonItem) {
        operationsManager?.cancelOperationQueue()
        
        let saveContextOperation = LogoutOperation()
        
        operationsManager?.startOperation(operation: saveContextOperation, completion: { (success, result, errors) in
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    // MARK: - Private

    private func loadRepos() {
        
        // TODO: Data Provider
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Repo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            
            tableViewDataSource += try operationsManager?.mainContext?.fetch(fetchRequest) as! [Repo]
            if tableViewDataSource.isEmpty {
                tableView.isHidden = true
                emptyLabel.isHidden = false
            } else {
                tableView.isHidden = false
                emptyLabel.isHidden = true
                tableView.reloadData()
            }
            
        } catch {
//            debugPrint("Fetching user repos objects failed")
        }
    }
    
}

// MARK: - UITableViewDataSource

extension ListViewController: UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDataSource.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Value1")
        
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "Value1")
        }
        
        let repo = tableViewDataSource[indexPath.row]
        cell!.textLabel?.text = repo.name
        cell!.detailTextLabel?.text = repo.language
        cell!.detailTextLabel?.text = "Size \(repo.size)KB"
      
        return cell!
    }
    
}

// MARK: - UITableViewDelegate

extension ListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let repo = tableViewDataSource[indexPath.row]
        let getPullRequestsGroupOperation = GetPullRequestsGroupOperation(repo: repo)
        let getReleasesGroupOperation = GetReleasesGroupOperation(repo: repo)
        let getCommitsGroupOperation = GetCommitsGroupOperation(repo: repo)

        operationsManager?.startOperationSequence(operations: [getPullRequestsGroupOperation, getReleasesGroupOperation, getCommitsGroupOperation], withDependency: true, completion: { (success, result, errors) in
            
            if let pullRequestResult = result?[GetPullRequestsGroupOperation.key] as? [String: AnyObject],
                let pullRequests = pullRequestResult[ParsePullRequestsOperation.key] as? [PullRequest] {
                print(pullRequests)
            }
        })
    }
    
}
