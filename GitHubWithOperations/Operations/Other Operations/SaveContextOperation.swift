//
//  SaveContextOperation.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SaveContextOperation: DatabaseOperation {

    // MARK: - Initialization

    override init() {
        super.init()
        self.name = "Save main context operation"
    }
    
    override final func main() {
        
        guard let context = self.context else {
            let error = NSError.error(code: missingParameter, userMessage: "Error try again")
            
            finishOperation(success: false, result: nil, errors: [error])
            return
        }
        
        context.perform {
            CoreDataManager.shared.saveContext(context)
            
            self.finishOperation()
        }
    }
    
}
