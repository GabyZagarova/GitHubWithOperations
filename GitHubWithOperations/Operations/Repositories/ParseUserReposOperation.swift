//
//  ParseUserReposOperation.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import Foundation
import CoreData

class ParseUserReposOperation: DatabaseOperation {
    
    // MARK: - Properties
    
    var data: Data? {
        didSet {
            self.isReady = self.data != nil
        }
    }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        
        self.name = "Parse user repos operation"
        self.isReady = false
    }
    
    override final func main() {
        do {
            if let data = data,
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]],
                let context = context {
                context.perform {
                    self.deleteOldRepos()
                    let repos = self.createNewRepos(jsonData: json)
                    
                    self.finishOperation(success: true, result: repos as AnyObject, errors: nil)
                }
            } else {
                let error = NSError.error(code: jsonSerialization, userMessage: "Error try again")
                
                finishOperation(success: false, result: nil, errors: [error])
            }
        } catch {
            
            debugPrint(error.localizedDescription)
            finishOperation(success: false, result: nil, errors: [error as NSError])
        }

    }
    
    static func stringify(json: Any, prettyPrinted: Bool = false) -> String {
        var options: JSONSerialization.WritingOptions = []
        if prettyPrinted {
            options = JSONSerialization.WritingOptions.prettyPrinted
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: options)
            if let string = String(data: data, encoding: String.Encoding.utf8) {
                return string
            }
        } catch {
            print(error)
        }
        
        return ""
    }
    
    // MARK: - Private

    @discardableResult private func deleteOldRepos() -> Bool {
       
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Repo")
        do {
            let oldRecordsArray = try context!.fetch(fetchRequest) as! [Repo]
            for repo in oldRecordsArray {
                context!.delete(repo)
            }
           
            return true
        } catch {
//            debugPrint("Fetching old repo objects failed")
            return false
        }
    }
    
    private func createNewRepos(jsonData: [[String: Any]]) -> Bool {

        for repoDictionary in jsonData {
            let repo = NSEntityDescription.insertNewObject(forEntityName: "Repo", into: context!) as! Repo
            repo.id = Int64(truncating: repoDictionary["id"] as? NSNumber ?? 0)
            repo.name = repoDictionary["name"] as? String
            repo.repoDescription = repoDictionary["description"] as? String
            repo.language = repoDictionary["language"] as? String
            repo.size = Int64(truncating: repoDictionary["size"] as? NSNumber ?? 0)
            if let dateString = repoDictionary["pushed_at"] as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-mm-ddThh:mm:ssz"
                repo.pushedAt = dateFormatter.date(from: dateString)
            }
        }
        
        return true
    }
    
}
