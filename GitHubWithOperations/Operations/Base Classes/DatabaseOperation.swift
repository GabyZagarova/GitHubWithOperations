//
//  DatabaseOperation.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import Foundation
import CoreData

class DatabaseOperation: BaseOperation {
    
    // MARK: - Initialization

    override init() {
        super.init()
        
        self.requireAccessToken = false
        self.requireInternet = false
    }
}
