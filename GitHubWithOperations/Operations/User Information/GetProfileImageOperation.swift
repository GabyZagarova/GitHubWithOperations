//
//  GetProfileImageOperation.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import Foundation
import UIKit

class GetProfileImageOperation: BaseOperation {
    
    // MARK: - Properties
    
    fileprivate var imageURL: String?
    fileprivate var token: String?

    // MARK: - Initialization
    
    init(user: User) {
        super.init()
        self.name = "Fetch user avatar operation"
        
        self.requireAccessToken = true
        self.requireInternet = true
        self.imageURL = user.avatarURL
    }
    
    override final func main() {
        
        token = UserAuthenticationManager.shared.tokenValue
        guard token != nil, imageURL != nil,
            let request = self.urlRequest() else {
            let error = NSError.error(code: missingParameter, userMessage: "Error try again")

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
            let image = UIImage(data: data!)
            
            self.finishOperation(success: true, result: image as AnyObject, errors: nil)
        }
        
        task.resume()
    }

}

// MARK: - ServiceRequestOperation

extension GetProfileImageOperation: NetworkRequestable {
    
    public var requestURL: URL? {
        return URL(string: self.imageURL ?? "")
    }
    
    public var httpMethod: String {
        return "GET"
    }
    
    public var allHTTPHeaderFields: [String: String]? {
        guard let token = self.token else {
            
            return nil
        }
        
        return ["Authorization" : "token \(token)"]
    }
    
}
