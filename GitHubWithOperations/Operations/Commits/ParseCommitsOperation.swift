//
//  ParseCommitsOperation.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import Foundation

class ParseCommitsOperation: BaseOperation {
    
    // MARK: - Properties
    
    var data: Data? {
        didSet {
            self.isReady = self.data != nil
        }
    }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        
        self.name = "Parse commits operation"
        self.isReady = false
    }
    
    override final func main() {
        
        do {
            if let data = data,
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                let commits = createCommits(jsonData: json)
                
                finishOperation(success: true, result: commits as AnyObject, errors: nil)
            } else {
                
                debugPrint("Error in JSON serialization.")
                let error = NSError.error(code: jsonSerialization, userMessage: "Error try again")
                self.finishOperation(success: false, result: nil, errors: [error])
            }
        } catch {
            debugPrint(error.localizedDescription)
            
            finishOperation(success: false, result: nil, errors: [error as NSError])
        }
    }
    
    
    // MARK: - Private

    private func createCommits(jsonData: [[String: Any]]) -> [Commit]? {
        
        var commits = [Commit]()
        
        for repoDictionary in jsonData {
            if let commit = repoDictionary["commit"] as? [String: Any],
                let author = commit["author"] as? [String: Any],
                let authorName = author["name"] as? String,
                let message = commit["message"] as? String,
                let date = author["date"]  as? String {
                let commit = Commit(date: date, message: message, authorName: authorName)
                commits.append(commit)
            }
        }
        
        return commits
    }
    
}
