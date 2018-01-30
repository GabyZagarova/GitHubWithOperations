//
//  DataExtension.swift
//  GitHubWithOperationsTests
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import Foundation

extension Data {
    
    static func testDataFromFile(name: String, type: String) -> Data? {
       
        let bundle = Bundle(for: GitHubWithOperationsTests.self)
        guard let url = bundle.url(forResource: name, withExtension: type) else {
            print("Missing file: \(name)")
           
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
//            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            return data
        } catch {
            print(error)
        }
        
        return nil
    }
}
