//
//  LoginViewController.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//

import UIKit

class LoginViewController: BaseViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var usernameTextFiled: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    // MARK: - Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Login"
        usernameTextFiled.text = username
        passwordTextField.text = password
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destination = segue.destination as? ListViewController {
            destination.operationsManager = operationsManager
        }
    }
    
    // MARK: - Actions
    
    @IBAction func singInButtonAction(_ sender: Any) {
        
        usernameTextFiled.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        guard validate() else {
            
            return
        }
        
        /* 
         Example of Group Operation
         Login user is a complicated action made up of several actions depending on one another
         At the edna of the group operation the app will have access token for the user and all the user information that is needed.
         */
        startAnimatingLoadingIndicator(message: NSLocalizedString("Logging in...", comment: ""))

        let loginGroupOperation = LoginUserGroupOperation(username: usernameTextFiled.text!, password: passwordTextField.text!)
        
        operationsManager?.startOperation(operation: loginGroupOperation) { (success, result, errors) in
            
            self.stopAnimatingLoadingIndicator(message: nil)
            if success == false, let errors = errors {
                for error in errors {
                    let alert = AlertOperation(presentationContext: self)
                    alert.title = "Something went wrong"
                    alert.message = error.userInfo["userMessage"] as? String ?? "Please try again."
                    self.operationsManager?.startOperation(operation: alert, completion: nil)
                }
            } else {
                self.performSegue(withIdentifier: "ShowListSegueIdentifier", sender: nil)
            }
            
        }
    }
    
    // МАРК: - Validation

    private func validate() -> Bool {
        
        /*
         Example of Mutual Exclusivity
         By using dependency - Second alert operation depends on the 1st one
         This is just an example validation and maybe it doesn't make much sense
        */
        var alerts: [AlertOperation] = []
        var result = true

        if usernameTextFiled.text == nil, passwordTextField.text == nil {
            let alert = AlertOperation(presentationContext: self)
            alert.title = "Validation warning"
            alert.message = "Username and password are required."
            result = false
            alerts.append(alert)
        }
        
        if let username = usernameTextFiled.text, username.contains("") {
            let alert = AlertOperation(presentationContext: self)
            alert.title = "Validation warning"
            alert.message = "Username is incorrect."
            result = false
            alerts.append(alert)
        }
        
        if let password = passwordTextField.text, password.count <= 2 {
            let alert = AlertOperation(presentationContext: self)
            alert.title = "Validation warning"
            alert.message = "Password is too short."
            result = false
            alerts.append(alert)
        }
        
        operationsManager?.startOperationSequence(queueType: .defaultQ, operations: alerts, withDependency: true, completion: nil)
       
        return result
    }
    
}


