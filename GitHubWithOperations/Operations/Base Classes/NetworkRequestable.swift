//
//  NetworkRequestable.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import UIKit

public protocol NetworkRequestable where Self: BaseOperation {
    
    // MARK: - Properties
        
    var requestURL: URL? { get }
    var httpMethod: String { get }
    var allHTTPHeaderFields: [String: String]? { get }
    var bodyJSON: AnyObject? { get }
}

extension NetworkRequestable {
    
    func urlSession() -> URLSession {
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        let session = URLSession(configuration: config)
        return session
    }
    
    func urlRequest() -> URLRequest? {
        
        guard let requestURL = requestURL else {
            return nil
        }
        
        let request = NSMutableURLRequest(url: requestURL)
        request.allHTTPHeaderFields = allHTTPHeaderFields
        request.httpMethod = httpMethod
        
        if let body = bodyJSON {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
        
        return request as URLRequest
    }
    
    public var bodyJSON: AnyObject? {
        return nil
    }
    
}
