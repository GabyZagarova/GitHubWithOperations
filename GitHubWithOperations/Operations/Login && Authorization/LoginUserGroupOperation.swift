//
//  LoginUserGroupOperation.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import Foundation

class LoginUserGroupOperation: BaseGroupOperation {
    
    // MARK: - Initialization
    
    init(username: String, password: String) {
        
        //All of the operations should depend on the first one or the each one of them to the previous one
        let authorizationOperation = AuthorizationOperation(username: username, password: password)
        let fetchUserInfoOperation = FetchUserInfoOperation()
        let parseUserInfoOperation = ParseUserInfoOperation()
        let saveContextOperation = SaveContextOperation()
        
        fetchUserInfoOperation.addDependency(authorizationOperation)
        parseUserInfoOperation.addDependency(fetchUserInfoOperation)
        saveContextOperation.addDependency(parseUserInfoOperation)
        
        let listOfOperations = [authorizationOperation, fetchUserInfoOperation, parseUserInfoOperation, saveContextOperation]

        super.init(operations: listOfOperations)
        self.name = "Login group operation"

        // If the user is not able to authenticate it's better to cancel the rest of the group operations
        authorizationOperation.operationCompletionBlock = { (status, result, errors) in
            if errors != nil {
                self.cancel()
            }
        }
        
        fetchUserInfoOperation.operationCompletionBlock = { (status, result, errors) in
            if let result = self.internalQueue.aggregatedQueueResults[FetchUserInfoOperation.key] as? Data {
                parseUserInfoOperation.data = result
            } else {
                self.cancel()
            }
        }

    }
    
}
