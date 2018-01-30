//
//  GitHubWithOperationsTests.swift
//  GitHubWithOperationsTests
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import XCTest
import CoreData

@testable import GitHubWithOperations

class GitHubWithOperationsTests: XCTestCase {
    
    lazy var mockPersistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: dataModelName)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            // Check if the data store is in memory
            precondition( description.type == NSInMemoryStoreType )
            
            // Check if creating container wrong
            if let error = error {
                fatalError("Create an in-mem coordinator failed \(error)")
            }
        }
        
        return container
    }()

    func testParseUserInfoOperation() {
       
        // Create test data for parsing operation
        let testReposData = Data.testDataFromFile(name: "Repos", type: "json")
        let parseUserReposOperation = ParseUserReposOperation()
        
        // Validate at the beginning operations is not ready
        XCTAssertFalse(parseUserReposOperation.isReady)

        parseUserReposOperation.data = testReposData
        parseUserReposOperation.context = mockPersistantContainer.viewContext
        
        // Validate when the data property is set the operating become ready
        XCTAssertTrue(parseUserReposOperation.isReady)
        
        // Create expectation and start pasrsing asyc operation
        let exp = expectation(description: "Parse User Repos Operation Expectation")
       
        let queue = BaseOperationQueue()
        parseUserReposOperation.operationCompletionBlock = { (status, result, errors) in
            exp.fulfill()
        }
        queue.addOperation(parseUserReposOperation)
        
        waitForExpectations(timeout: 5, handler: nil)

        // Check the result
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Repo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let repos = try mockPersistantContainer.viewContext.fetch(fetchRequest) as! [Repo]
            XCTAssertEqual(repos.count, 4, "Incorrect repos count after parsing")
        } catch {
            print("Test fetching user repos objects failed")
        }
    }

}
