//
//  ParsePullRequestsOperation.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import Foundation

class ParsePullRequestsOperation: BaseOperation {
    
    // MARK: - Properties
    
    var data: Data? {
        didSet {
            self.isReady = self.data != nil
        }
    }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        
        self.name = "Parse pull requests operation"
        self.isReady = false
    }
    
    override final func main() {
        do {
            if let data = data,
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                let pullRequests = createPullRequests(jsonData: json)
                
                finishOperation(success: true, result: pullRequests as AnyObject, errors: nil)
            }
        } catch {
            
            debugPrint(error.localizedDescription)
            finishOperation(success: false, result: nil, errors: [error as NSError])
        }
    }
    
    // MARK: - Private
    
    private func createPullRequests(jsonData: [[String: Any]]) -> [PullRequest]? {
        
        var pullRequests = [PullRequest]()
        
        for repoDictionary in jsonData {
            if let title = repoDictionary["title"] as? String,
                let body = repoDictionary["body"] as? String{
                let pullRequest = PullRequest(title: title, body: body)
                pullRequests.append(pullRequest)
            }
        }
        
        return pullRequests
    }
    
}
