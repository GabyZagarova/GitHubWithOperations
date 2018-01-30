//
//  ErrorExtension.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//


import Foundation

let domainKey = "com.OperationsExample"

// MARK: - Error codes:
let unauthorized = 101
let incorrectAuthorization = 102
let jsonSerialization = 103
let missingParameter = 104

extension NSError {

    class func error(code: Int, userMessage: String?) -> NSError {
        return NSError(domain: domainKey, code: code, userInfo: ["userMessage": userMessage ?? ""])
    }
}
