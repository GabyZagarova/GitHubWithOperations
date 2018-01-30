//
//  BaseOperation.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol BaseOperationDelegate: NSObjectProtocol {
    
    func operationWillStart(_ operation: BaseOperation)
    func operationWillFinish(_ operation: BaseOperation, withResult: AnyObject?, withErrors errors: [NSError]?)
    func operationDidFinish(_ operation: BaseOperation, withResult: AnyObject?, withErrors errors: [NSError]?)
}

/* Our subclass of Operation is designed as non-concurrent, but notice that:
    Operations are always executed on a separate thread, regardless of whether
    they are designated as asynchronous or synchronous operations. */

class BaseOperation: Operation {
    
    // MARK: - Properties
    
    class var key: String {
        return String(describing: self)
    }
    var context: NSManagedObjectContext?
    var delegate: BaseOperationDelegate?
    var operationCompletionBlock: OperationCompletionBlock?
    
    /* Conditions - Networking Operation
     Set up operation with other values if needed */
    
    public var requireAccessToken: Bool = true
    public var requireInternet: Bool = false
    
    /* Check whether the current operation is
    ready and all conditions are fulfilled */
    
    fileprivate var internalReady: Bool = true
    override var isReady: Bool {
        get {
            return super.isReady && internalReady && evaluateConditions()
        }
        set {
            willChangeValue(forKey: "isReady")
            internalReady = newValue
            didChangeValue(forKey: "isReady")
        }
    }
    
    /* Private property to ensure that we make operation finish only once.
     Also wait until service call return response or timeout. */
    
    fileprivate var internalFinished: Bool = false
    override var isFinished: Bool {
        get {
            return internalFinished
        }
        set {
            willChangeValue(forKey: "isFinished")
            internalFinished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
    
    fileprivate var аggregatedЕrrors: [NSError] = []
    
    // MARK: - Super class methods
    
    override init() {
        super.init()

        self.addObserver(self, forKeyPath: "isExecuting", options: .new, context: nil)
        self.addObserver(self, forKeyPath: "isFinished", options: .new, context: nil)
        self.addObserver(self, forKeyPath: "isCancelled", options: .new, context: nil)
    }
    
    deinit {
        
        self.removeObserver(self, forKeyPath: "isExecuting")
        self.removeObserver(self, forKeyPath: "isFinished")
        self.removeObserver(self, forKeyPath: "isCancelled")
    }
    
    // MARK: - Public methods
    
    /* Common method all of the operations calls this method as to finish.
     Use to do common work before each operation finish*/
    final func finishOperation(success: Bool = true, result: AnyObject? = nil, errors: [NSError]? = nil) {

        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        delegate?.operationWillFinish(self, withResult: result, withErrors: errors)

        if let operationCompletionBlock = operationCompletionBlock {
            operationCompletionBlock(success, result, errors)
        }
        
        if !internalFinished {
            isFinished = true
            delegate?.operationDidFinish(self, withResult: result, withErrors: errors)
        }
        
        return
    }
    
    // MARK: - Private methods
   
    @discardableResult private func evaluateConditions() -> Bool {
        
        // Always check if the operation is cancelled first
        if isCancelled {
            finishOperation(success: false)
            
            return true
        }
        
        // Validate the conditions
        if requireAccessToken && UserAuthenticationManager.shared.tokenValue == nil && !(self.dependencies.last is AuthorizationOperation) {

            let notAccessToken = NSError(domain: "com.OperationsExample", code: incorrectAuthorization, userInfo: ["userMessage": "No access token"])
            NotificationCenter.default.post(name: Notification.Name.NoAccessTokenNotificationIdentifier, object: nil)
            finishOperation(success: false, result: nil, errors: [notAccessToken])

            return false
        }
        
        if requireInternet && NetworkManager.shared.isReachable == false {
           
            let notInternetError = NSError(domain: "com.OperationsExample", code: 101, userInfo: ["userMessage": "No internet"])
            finishOperation(success: false, result: nil, errors: [notInternetError])
           
            return false
        }
        
        return true
    }
    
    // MARK - Observing
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
      
        if object as? Operation == self && keyPath == "isExecuting" {
           
            if ((change?[.newKey] as? Bool))! {
                NSLog("%@ is Executing 🔜", self.name ?? "")
                
                delegate?.operationWillStart(self)
                
                if requireInternet && self is NetworkRequestable  {
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    }
                }
                
            }
        } else if object as? Operation == self && keyPath == "isFinished" {
           
            if ((change?[.newKey] as? Bool))! {
                NSLog("%@ is Finished 🔚", self.name ?? "")
            }
        } else if object as? Operation == self && keyPath == "isCancelled" {
         
            if ((change?[.newKey] as? Bool))! {
                NSLog("%@ is Cancelled ❌", self.name ?? "")
            }
        } else {
            
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
