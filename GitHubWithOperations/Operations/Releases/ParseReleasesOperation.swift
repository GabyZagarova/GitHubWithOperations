//
//  ParseReleasesOperation.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import Foundation

class ParseReleasesOperation: BaseOperation {
    
    // MARK: - Properties
    
    var data: Data? {
        didSet {
            self.isReady = self.data != nil
        }
    }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        
        self.name = "Parse releases operation"
        self.isReady = false
    }
    
    override final func main() {
        do {
            if let data = data,
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                let releases = createReleases(jsonData: json)
                
                finishOperation(success: true, result: releases as AnyObject, errors: nil)                
            }
        } catch {
            debugPrint(error.localizedDescription)
            
            finishOperation(success: false, result: nil, errors: [error as NSError])
        }
    }
    
    // MARK: - Private
    
    private func createReleases(jsonData: [[String: Any]]) -> [Release]? {
        var releases = [Release]()
        
        for repoDictionary in jsonData {
            if let name = repoDictionary["name"] as? String,
                let body = repoDictionary["body"] as? String,
                let date = repoDictionary["published_at"]  as? String {
                let release = Release(date: date, name: name, body: body)
                releases.append(release)
            }
        }
        
        return releases
    }
    
}
