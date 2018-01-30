//
//  BaseGroupOperation.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import Foundation
import CoreData
import UIKit


/* Subclass of Base Operation that execute one or more operations as one.
   You can use this class for abstracting more then one smaller operations 
   and defining specific relationship between the operation within the
   group operation.
   See LoginUserGroupOperation for example */

class BaseGroupOperation: BaseOperation {
    
    // MARK: - Properties
    
    let internalQueue = BaseOperationQueue()
    fileprivate var listOfOperations: [BaseOperation] = []
    
    override var context: NSManagedObjectContext? {
        willSet {
            for operation in self.listOfOperations {
                operation.context = newValue
            }
        }
    }
    
    // MARK: - Initialization
    
    init(operations: [BaseOperation], maxConcurrentOperationCount: Int = 1) {
        super.init()
       
        self.listOfOperations = operations
        self.requireAccessToken = false
        self.requireInternet = false
        self.internalQueue.maxConcurrentOperationCount = maxConcurrentOperationCount
    }
    
    override func main() {

        for operation in listOfOperations {
            operation.delegate = self
        }
        internalQueue.addOperations(listOfOperations, waitUntilFinished: false)
        internalQueue.onFinishBlock = {
            self.finishOperation(success: self.internalQueue.aggregatedQueueErrors.isEmpty, result: self.internalQueue.aggregatedQueueResults as AnyObject, errors: self.internalQueue.aggregatedQueueErrors)
        }
    }

    final override func cancel() {
        super.cancel()
        
        for operatio in listOfOperations {
            operatio.cancel()
            
        }
        
        self.finishOperation(success: self.internalQueue.aggregatedQueueErrors.isEmpty, result: self.internalQueue.aggregatedQueueResults as AnyObject, errors: self.internalQueue.aggregatedQueueErrors)
    }
}

// MARK: - BaseOperationDelegate

extension BaseGroupOperation: BaseOperationDelegate {
    
    func operationWillStart(_ operation: BaseOperation) {
  
    }
    
    func operationWillFinish(_ operation: BaseOperation, withResult result: AnyObject?, withErrors errors: [NSError]?) {
      
        if let result = result {
            internalQueue.aggregatedQueueResults[type(of: operation).key] = result
        }
        
        if let errors = errors {
            internalQueue.aggregatedQueueErrors += errors
        }
    }
    
    func operationDidFinish(_ operation: BaseOperation, withResult result: AnyObject?, withErrors errors: [NSError]?) {
        
        if internalQueue.operations.count == 0 {
            internalQueue.onFinishBlock?()
        }
    }
    
}


