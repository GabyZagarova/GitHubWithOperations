//
//  FetchCommitsOperation.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import Foundation

class FetchCommitsOperation: BaseOperation {
    
    // MARK: - Properties
        
    fileprivate var repoName: String
    fileprivate var token: String?
    var request: URLRequest? {
        return  self.urlRequest()
    }
    
    // MARK: - Initialization
    
    init(repo: Repo) {
        self.repoName = repo.name!

        super.init()
        self.name = "Fetch commits for repo operation"

        self.requireAccessToken = true
        self.requireInternet = true
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

// MARK: - NetworkRequestable

extension FetchCommitsOperation: NetworkRequestable {
    
    public var requestURL: URL? {
        guard token != nil else {
            return nil
        }
        return URL(string: "\(GitHubConfiguration().baseURL)/repos/\(UserAuthenticationManager.shared.username ?? "")/\(self.repoName)/commits")
    }
    
    public var httpMethod: String {
        return "GET"
    }
    
    public var allHTTPHeaderFields: [String: String]? {
        return ["Authorization" : "token \(token ?? "")"]
    }
    
}
