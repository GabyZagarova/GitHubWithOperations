//
//  FetchUserInfoOperation.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import Foundation

class FetchUserInfoOperation: BaseOperation {
    
    // MARK: - Properties
        
    fileprivate var token: String?
    var request: URLRequest? {
        return  self.urlRequest()
    }
    
    // MARK: - Initialization

    override init() {
        super.init()
        self.name = "Fetch user info operation"
       
        self.requireInternet = true
        self.requireAccessToken = true
    }
    
    override final func main() {
        
        token = UserAuthenticationManager.shared.tokenValue
        guard let request = request else {
            let error = NSError.error(code: unauthorized, userMessage: "Unauthorized or missing URL request parameter")
           
            finishOperation(success: false, result: nil, errors: [error])
            return
        }
        
        let task = urlSession().dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode >= 200 && httpResponse.statusCode < 300,
                data != nil else {
                    let error = NSError.error(code: incorrectAuthorization, userMessage: "Incorrect username or password.")
                    
                    self.finishOperation(success: false, result: nil, errors: [error])
                    return
            }

            self.finishOperation(success: true, result: data as AnyObject, errors: nil)
        }
        
        task.resume()
    }
    
}

// MARK: - ServiceRequestOperation

extension FetchUserInfoOperation: NetworkRequestable {
    
    public var requestURL: URL? {
        guard token != nil else {
            return nil
        }
        return URL(string: "\(GitHubConfiguration().baseURL)/user")
    }
    
    public var httpMethod: String {
        return "GET"
    }
    
    public var allHTTPHeaderFields: [String: String]? {
        return ["Authorization" : "token \(token ?? "")"]
    }
    
}
