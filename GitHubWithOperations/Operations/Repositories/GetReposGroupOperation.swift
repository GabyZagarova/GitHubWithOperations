//
//  GetReposGroupOperation.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import Foundation

class GetReposGroupOperation: BaseGroupOperation {
    
    // MARK: - Initialization
    
    init() {
        let fetchUserReposOperation = FetchUserReposOperation()
        let parseUserReposOperation = ParseUserReposOperation()
        let saveContextOperation = SaveContextOperation()
        
        parseUserReposOperation.addDependency(fetchUserReposOperation)
        saveContextOperation.addDependency(parseUserReposOperation)
        
        let listOfOperations = [fetchUserReposOperation, parseUserReposOperation, saveContextOperation]
        
        super.init(operations: listOfOperations)
        self.name = "Repos group operation"

        fetchUserReposOperation.operationCompletionBlock = { (status, result, errors) in
            if let result = self.internalQueue.aggregatedQueueResults[FetchUserReposOperation.key] as? Data {
                parseUserReposOperation.data = result
            } else {
                self.cancel()
            }
        }
    }
}
