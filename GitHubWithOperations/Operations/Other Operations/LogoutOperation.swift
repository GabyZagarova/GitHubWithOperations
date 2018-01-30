//
//  LogoutOperation.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class LogoutOperation: DatabaseOperation {
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        self.name = "Logout operation"
        
        self.requireInternet = false
        self.requireAccessToken = false
    }
    
    override func main() {
        
        guard let context = self.context else {
            let error = NSError.error(code: missingParameter, userMessage: "Error try again")
            
            finishOperation(success: false, result: nil, errors: [error])
            return
        }
        
        context.perform {
            
            self.deleteUserData(context: context)
            CoreDataManager.shared.saveContext(context)
            
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "Username")
            defaults.removeObject(forKey: "Token")

            self.finishOperation()
        }
    }
    
    // MARK: - Private

    fileprivate func deleteUserData(context: NSManagedObjectContext) {
        
        deleteAllData(entity: "User", context: context)
        deleteAllData(entity: "Repo", context: context)
    }
    
    fileprivate func deleteAllData(entity: String, context: NSManagedObjectContext) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false

        do {
            if let results = try context.fetch(fetchRequest) as? [NSManagedObject] {
                for managedObject in results {
                    context.delete(managedObject)
                }
            }
        } catch let error as NSError {
            print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
        }
    }
    
}
