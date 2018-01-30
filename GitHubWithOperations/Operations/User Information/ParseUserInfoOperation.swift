//
//  ParseUserInfoOperation.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import Foundation
import CoreData

typealias ResponseData = [String: Any]

class ParseUserInfoOperation: BaseOperation {
    
    // MARK: - Properties
    
    var data: Data? {
        didSet {
            self.isReady = self.data != nil
        }
    }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        
        self.name = "Parse user info operation"
        self.isReady = false
    }
    
    override final func main() {
       
        do {
            if let data = data,
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let context = context {
                
                context.perform {
                    self.updateUserInfo(jsonData: json)
                    self.finishOperation()
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
    
    // MARK: - Private
    
    @discardableResult private func updateUserInfo(jsonData: [String: Any]) -> Bool {
        
        // You can optimize the code below
        var userRecordsArray: [User] = []
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        do {
            userRecordsArray = try context!.fetch(fetchRequest) as! [User]
        } catch {
//            debugPrint("Fetching old user info objects failed")
        }
        
        var user: User
        if let oldUser = userRecordsArray.first {
            user = oldUser
        } else {
            user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context!) as! User
        }
        
        user.id = Int64(truncating: jsonData["id"] as? NSNumber ?? 0)
        user.name = jsonData["name"] as? String
        user.email = jsonData["email"] as? String
        user.type = jsonData["type"] as? String
        user.location = jsonData["location"] as? String
        user.avatarURL = jsonData["avatar_url"] as? String
        user.bio = jsonData["bio"] as? String
        user.company = jsonData["company"] as? String
        user.login = jsonData["login"] as? String
        user.publicGists = Int32(truncating: jsonData["public_gists"] as? NSNumber ?? 0)
        user.publicRepos = Int32(truncating: jsonData["public_repos"] as? NSNumber ?? 0)
       
//        debugPrint("User : \(user)")
        
        return true
    }
    
}

