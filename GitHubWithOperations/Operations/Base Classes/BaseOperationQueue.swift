//
//  BaseOperationQueue.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import Foundation

/// Operation Queue define what kind of actions will be executed in that queue.
///
/// - main: User importat action, fetching datata that will be presentetd on the screen.
/// - authentication: Refresh token.

enum OperationQueueType: Int {
    
    case defaultQ
    case authentication
    
    func name() -> String {
        switch self {
        case .defaultQ:
            return "Default Operation Queue"
        case .authentication:
            return "Authentication Operation Queu"
        }
    }
    
}

class BaseOperationQueue: Foundation.OperationQueue {
    
    // MARK: - Properties
    
    var queueType: OperationQueueType?

    /// Store operations results or errors in this dictionary, use operation name for key
    var aggregatedQueueResults: [String: AnyObject] = [:]
    var aggregatedQueueErrors: [NSError] = []
    
    var onFinishBlock: (() -> Void)?
    
    // MARK: - Initialization
    
    init(type: OperationQueueType? = .defaultQ) {
        super.init()
       
        self.queueType = type
        self.name = type?.name()
    }
    
    // MARK: - Public methods

    func clear() {
        self.aggregatedQueueErrors = []
        self.aggregatedQueueResults =  [:]
    }
    
    func isExecuting() -> Bool {
        let array = operations.filter { $0.isExecuting == true }
        let executingCount = array.count > 0
        return executingCount
    }
    
}

