//
//  GetPullRequestsGroupOperation.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import Foundation

class GetPullRequestsGroupOperation: BaseGroupOperation {
    
    // MARK: - Initialization
    
    init(repo: Repo) {
        
        let fetchPullRequestsOperation = FetchPullRequestsOperation(repo: repo)
        let parsePullRequestsOperation = ParsePullRequestsOperation()

        parsePullRequestsOperation.addDependency(fetchPullRequestsOperation)
        let listOfOperations = [fetchPullRequestsOperation, parsePullRequestsOperation]
        
        super.init(operations: listOfOperations)
        self.name = "Pull requests group operation"

        fetchPullRequestsOperation.operationCompletionBlock = { (status, result, errors) in
            if let result = self.internalQueue.aggregatedQueueResults[FetchPullRequestsOperation.key] as? Data {
                parsePullRequestsOperation.data = result
            } else {
                self.cancel()
            }            
        }
    }
}


