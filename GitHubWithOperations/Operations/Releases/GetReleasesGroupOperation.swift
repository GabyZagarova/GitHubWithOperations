//
//  GetReleasesGroupOperation.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import Foundation

class GetReleasesGroupOperation: BaseGroupOperation {
    
    // MARK: - Initialization
    
    init(repo: Repo) {
        
        let fetchReleasesOperation = FetchReleasesOperation(repo: repo)
        let perseReleasesOperation = ParseReleasesOperation()

        perseReleasesOperation.addDependency(fetchReleasesOperation)
        let listOfOperations = [fetchReleasesOperation, perseReleasesOperation]
        
        super.init(operations: listOfOperations)
        self.name = "Releases group operation"
        
        fetchReleasesOperation.operationCompletionBlock = { (status, result, errors) in
            if let result = self.internalQueue.aggregatedQueueResults[FetchReleasesOperation.key] as? Data {
                perseReleasesOperation.data = result
            } else {
                self.cancel()
            }
        }
    }
    
}

