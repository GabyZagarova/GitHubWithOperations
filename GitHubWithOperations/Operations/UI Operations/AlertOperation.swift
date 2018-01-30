//
//  AlertOperation.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import UIKit

class AlertOperation: BaseOperation {
    
    // MARK: - Properties

    private let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
    private let presentationContext: UIViewController?
    
    var title: String? {
        get {
            return alertController.title
        }
        set {
            alertController.title = newValue
            name = (name ?? "") + " " + (newValue ?? "")
        }
    }
    
    var message: String? {
        get {
            return alertController.message
        }
        set {
            alertController.message = newValue
            name = (name ?? "") + " " + (newValue ?? "")
        }
    }
    
    // MARK: - Initialization
    
    init(presentationContext: UIViewController? = nil) {
       
        self.presentationContext = presentationContext ?? UIApplication.shared.keyWindow?.rootViewController
        
        super.init()
        self.name = "Alert operation"
        
        self.requireAccessToken = false
        self.requireInternet = false
    }
    
    func addAction(title: String, style: UIAlertActionStyle = .default, handler: @escaping (AlertOperation) -> Void = {_ in} ) {
       
        let action = UIAlertAction(title: title, style: style) { [weak self] _ in
            if let strongSelf = self {
                handler(strongSelf)
            }
            
            self?.finishOperation()
        }
        alertController.addAction(action)
    }
    
    override func main() {
     
        guard let presentationContext = presentationContext else {
            
            self.finishOperation()
            return
        }
    
        DispatchQueue.main.async {
            if self.alertController.actions.isEmpty {
                self.addAction(title: "OK")
            }
            
            presentationContext.present(self.alertController, animated: true, completion: nil)
        }
    }
    
}
