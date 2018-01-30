//
//  OperationsManager.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import Foundation
import UIKit
import CoreData

typealias OperationCompletionBlock = ((_ success: Bool, _ result: AnyObject?, _ errors: [NSError]?) -> Void)

class OperationsManager: NSObject {
    
    // MARK: - Properties
    
    private(set) var mainContext: NSManagedObjectContext!
    private(set) var backgroundContext: NSManagedObjectContext!

    /* Use different operation queues for specific tasks, example
     authenticationOperationQueue - refresh server autherntication
     defaultOperationQueue - for main user interacions
     serverSyncOperationQueue - offline collect data sync with the server
     */
    fileprivate(set) var authenticationOperationQueue: BaseOperationQueue!
    fileprivate(set) var defaultOperationQueue: BaseOperationQueue!
    
    fileprivate let currentOperationsList: [BaseOperation] = []
    
    // MARK: - Initialization

    override init() {
        super.init()
        
        self.mainContext = CoreDataManager.shared.mainContext
        self.backgroundContext = CoreDataManager.shared.backgroundContext

        self.defaultOperationQueue = BaseOperationQueue(type: .defaultQ)
        self.authenticationOperationQueue = BaseOperationQueue(type: .authentication)
        
        NotificationCenter.default.addObserver(self, selector: #selector(noAccessTokenAvailableHandler(notification:)), name: NSNotification.Name.NoAccessTokenNotificationIdentifier, object: nil)
    }
    
    // MARK: - Deinit

    deinit {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NoAccessTokenNotificationIdentifier, object: nil)
    }
    
    // MARK: - Operations
    
    // Configure a single operation and add it immediately to a operation queue
    
    final func startOperation(queueType: OperationQueueType = .defaultQ, operation: BaseOperation!, completion: (OperationCompletionBlock)?) {
        
        self.startOperationSequence(queueType: queueType, operations: [operation], completion: completion)
    }
    
    var internalCompletion: OperationCompletionBlock?

    /*  Configure list of operations, according to dependency parameter value set or not dependencies between them, 
     all of the operations will finish with a single completion block */
    
    @discardableResult final func startOperationSequence(queueType: OperationQueueType = .defaultQ, operations: [BaseOperation], withDependency: Bool = false, completion: (OperationCompletionBlock)?) -> [BaseOperation] {
        
        // Define operation queue and context for the operation[s]
        let operationSettings = оperationSettings(queueType: queueType)
        let operationQueue = operationSettings.queue

        var previousOperation: BaseOperation?

        // All dependencies should be defined before operations is passed as parameter
        for operation in operations {
            
            operation.context = operationSettings.context
            operation.delegate = self

            //Set up Completion
            if internalCompletion == nil {
                internalCompletion = completion
            }
            
            // Dependency
            // TODO add validation and check for deadlock
            if withDependency {
                if let previousOperation = previousOperation {
                    operation.addDependency(previousOperation)
                }
                previousOperation = operation
            }
            // Add operations to the queue
            if operationQueue.operations.contains(operation) == false {
                operationQueue.addOperation(operation)
            }
            
        }
        
        operationQueue.onFinishBlock = {
            /* If there is internal completion, this means that there were more than one operation 
             that finish and we should call the internal compilation */
            if let internalCompletion = self.internalCompletion {
                DispatchQueue.main.async {
                    NSLog("All finished -> return completion to main thread.")
                    internalCompletion(operationQueue.aggregatedQueueErrors.isEmpty, operationQueue.aggregatedQueueResults as AnyObject, operationQueue.aggregatedQueueErrors)
                    self.internalCompletion = nil
                    operationQueue.clear()
                }
            } else {
                operationQueue.clear()
            }
            
        }
        
        return operations
    }
    
    // MARK: - Manage Operation Queue
    
    final func cancelOperation(operation: BaseOperation) {
        
        operation.cancel()
    }
    
    final func cancelOperationQueue(queueType: OperationQueueType = .defaultQ) {
        
        operationQueue(queueType: queueType, cancel: true, suspend: false)
    }

    final func pauseOperationQueue(queueType: OperationQueueType = .defaultQ) {
        
        operationQueue(queueType: queueType, cancel: false, suspend: true)
    }
    
    final func restartOperationQueue(queueType: OperationQueueType = .defaultQ) {
        
        operationQueue(queueType: queueType, cancel: false, suspend: false)
    }
    
    // MARK: - Notification
    
    @objc private func noAccessTokenAvailableHandler(notification: Notification) {
       
        updateAccessToken()
    }
    
    // MARK: - Private methods
    
    fileprivate final func updateAccessToken() {
        NSLog("Suspended default queue.")
        
        defaultOperationQueue.isSuspended = true
        
        let refreshTokenOperation = UpdateTokenOperation()
        refreshTokenOperation.operationCompletionBlock = { (success, updatedUserServerID, errors) in
            if success {
                self.defaultOperationQueue.isSuspended = false
            }
            
            NSLog("Unsuspended default queue.")
        }
        
        // Make sure that you'll add update token operation only once
        if authenticationOperationQueue.operations.count == 0 {
            authenticationOperationQueue.addOperation(refreshTokenOperation)
        }
    }

    fileprivate final func оperationSettings(queueType: OperationQueueType) -> (queue: BaseOperationQueue, context: NSManagedObjectContext?) {
        
        switch queueType {
        case .defaultQ:
            
            return (queue: оperationQueue(queueType: queueType), context: mainContext)
        case .authentication:
            
            return (queue: оperationQueue(queueType: queueType), context: backgroundContext)
        }
    }
    
    fileprivate final func baseOperationQueue(forOperation operation: BaseOperation) -> BaseOperationQueue? {
        
        if defaultOperationQueue.operations.contains(operation) {
            
            return defaultOperationQueue
        }
        
        if authenticationOperationQueue.operations.contains(operation) {
            
            return authenticationOperationQueue
        }
        
        return nil
    }
    
    fileprivate final func оperationQueue(queueType: OperationQueueType) -> BaseOperationQueue {
        
        switch queueType {
        case .defaultQ:
            
            return defaultOperationQueue
        case .authentication:
            
            return authenticationOperationQueue
        }
    }
    
    fileprivate final func operationQueue(queueType: OperationQueueType = .defaultQ, cancel: Bool, suspend: Bool) {
        
        let queue = оperationQueue(queueType: queueType)
        if cancel {
            queue.cancelAllOperations()
        } else {
            guard suspend && queue.isSuspended, !suspend && !queue.isSuspended else {
                
                return
            }
            queue.isSuspended = suspend
        }
    }
    
}

// MARK: - BaseOperationDelegate

extension OperationsManager: BaseOperationDelegate {
    
    func operationWillStart(_ operation: BaseOperation) {
        // TODO:
    }
    
    func operationWillFinish(_ operation: BaseOperation, withResult result: AnyObject?, withErrors errors: [NSError]?) {
       
        //If you have multiple queue
        guard let queue: BaseOperationQueue = baseOperationQueue(forOperation: operation) else {
            
            return
        }
        
        if let result = result {
            queue.aggregatedQueueResults[type(of: operation).key] = result
        }
        
        if let errors = errors {
            defaultOperationQueue.aggregatedQueueErrors += errors
        }
    }
    
    func operationDidFinish(_ operation: BaseOperation, withResult result: AnyObject?, withErrors errors: [NSError]?) {
        
        if defaultOperationQueue.operations.count == 0 {
            defaultOperationQueue.onFinishBlock?()
        }
        
        if authenticationOperationQueue.operations.count == 0 {
            authenticationOperationQueue.onFinishBlock?()
        }
    }
    
}


