//
//  AuthorizationOperation.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import Foundation
import UIKit

class AuthorizationOperation: BaseOperation {
   
    // MARK: - Properties

    fileprivate var username: String
    fileprivate var password: String
    var request: URLRequest? {
        return  self.urlRequest()
    }
    
    // MARK: - Initialization

    init(username: String, password: String) {
       
        self.username = username
        self.password = password
        
        super.init()
        self.name = "Authorization operation"
        
        self.requireAccessToken = false
        self.requireInternet = true
    }
    
    override final func main() {
        
        guard let request = request else {
            let error = NSError.error(code: missingParameter, userMessage: "Unauthorized or missing URL request parameter")
            
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
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                    let token = json["token"] as? String
                    UserAuthenticationManager.shared.tokenValue = token
                    UserAuthenticationManager.shared.username = self.username
                    UserAuthenticationManager.shared.password = self.password
                    
                    self.finishOperation()
                } else {
                    
                    debugPrint("Error in JSON serialization.")
                    let error = NSError.error(code: jsonSerialization, userMessage: "Error try again")
                    self.finishOperation(success: false, result: nil, errors: [error])
                }
            } catch {
                
                debugPrint(error.localizedDescription)
                self.finishOperation(success: false, result: nil, errors: [error as NSError])
            }
        }
        
        task.resume()
    }
    
}

// MARK: - ServiceRequestOperation

extension AuthorizationOperation: NetworkRequestable {

    public var requestURL: URL? {
        return URL(string: "\(GitHubConfiguration().baseURL)/authorizations")
    }
    
    public var httpMethod: String {
        return "POST"
    }
    
    public var allHTTPHeaderFields: [String: String]? {
        guard let authorization = authorization(username: self.username, password: self.password) else {
            
            return nil
        }
        return ["Authorization" : authorization]
    }
    
    public var bodyJSON: AnyObject? {
        let parameters = ["client_id" : GitHubConfiguration().clientId,
                          "client_secret" : GitHubConfiguration().clientSecret,
                          "scopes" : ["repo","user"],
                          "note" : "dev"] as [String : Any]
       
        return parameters as AnyObject
    }
    
    private func authorization(username: String, password: String) -> String? {
        guard let data = "\(username):\(password)".data(using: .utf8) else {
           
            return nil
        }
        
        var basicAuth = data.base64EncodedString(options: .lineLength64Characters)
        basicAuth = "Basic \(basicAuth)"
       
        return basicAuth
    }
    
}
