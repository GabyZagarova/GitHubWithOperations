//
//  UpdateTokenOperation.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import Foundation

class UpdateTokenOperation: BaseOperation {
    
    // MARK: - Initialization

    override init() {
        super.init()
        self.name = "Update access token with refresh token operation"
        
        self.requireInternet = true
        self.requireAccessToken = true
    }
    
    override func main() {
        finishOperation()
    }
    
}
