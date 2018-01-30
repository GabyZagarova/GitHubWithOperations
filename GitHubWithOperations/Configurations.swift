//
//  Configurations.swift
//  OperationsExample
//
//  Created by Gabriela Zagarova on 7/27/17.
//  Copyright © 2017 Gabriela Zagarova. All rights reserved.
//

import Foundation

let username = ""
let password = ""

struct GitHubConfiguration {
    
    public let baseURL = "https:/api.github.com"
    public let clientId = "39a0e0c24c6c3b53e217"
    public let clientSecret = "ad0b16a350824a39da1e1a0ab7bb1d073bf9e5f5"
    
}

class NetworkManager {
    
    // MARK: Shared Instance
    
    static let shared = NetworkManager()
    
    var isReachable: Bool {
        return true
    }
    
}

final class UserAuthenticationManager {
    
    // MARK: Shared Instance
    
    static let shared = UserAuthenticationManager()
    
    var tokenValue: String? {
        get {
            let defaults = UserDefaults.standard
            if let tokenValue = defaults.object(forKey: "Token") as? String {
                return tokenValue
            }
            return nil
        }
        set {
            // Important never use UserDefaults for storing tokens or any sensitive user data
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "Token")
        }
    }
    var username: String? {
        get {
            let defaults = UserDefaults.standard
            if let usernameValue = defaults.object(forKey: "Username") as? String {
                return usernameValue
            }
            return nil
        }
        set {
            // Important never use UserDefaults for storing sensitive data or any sensitive user data
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "Username")
        }
    }
    var password: String?
    var expireDate: Date?
    
}

extension Notification.Name {
    static let NoAccessTokenNotificationIdentifier = Notification.Name("NoAccessTokenNotificationIdentifier")
}
