//
//  GetCommitsGroupOperation.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import Foundation

class GetCommitsGroupOperation: BaseGroupOperation {
    
    // MARK: - Initialization
    
    init(repo: Repo) {
        
        let fetchCommitsOperation = FetchCommitsOperation(repo: repo)
        let parseCommitsOperation = ParseCommitsOperation()

        parseCommitsOperation.addDependency(fetchCommitsOperation)
        let listOfOperations = [fetchCommitsOperation, parseCommitsOperation]
        
        super.init(operations: listOfOperations)
        self.name = "Commits group operation"
        
        fetchCommitsOperation.operationCompletionBlock = { (status, result, errors) in
            if let result = self.internalQueue.aggregatedQueueResults[FetchCommitsOperation.key] as? Data {
                parseCommitsOperation.data = result
            } else {
                self.cancel()
            }
        }
    }
    
}

