//
//  ActivityIndicatorViewЕxtension.swift
//  GitHubWithOperations
//
//  Created by Gabriela Zagarova on 30.01.18.
//  Copyright © 2018 Gabriela Zagarova. All rights reserved.
//


import Foundation
import UIKit
private let LoadingIndicatorTag = 101
private let LoadingLabelTag = 102

extension UIViewController {
    
    fileprivate var loadingIndicator: UIActivityIndicatorView {
        get {
            var indicator = view.viewWithTag(LoadingIndicatorTag) as? UIActivityIndicatorView
            
            if indicator == nil {
                indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                indicator?.translatesAutoresizingMaskIntoConstraints = false
                
                indicator?.tag = LoadingIndicatorTag
                view.addSubview(indicator!)
                
                indicator?.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 10).isActive = true
                indicator?.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -10).isActive = true
                
            }
            
            return indicator!
        }
    }
    
    fileprivate var loadingLabel: UILabel {
        get {
            var label = view.viewWithTag(LoadingLabelTag) as? UILabel
            
            if label == nil {
                label = UILabel()
                label?.translatesAutoresizingMaskIntoConstraints = false
                label?.textAlignment = .center
                label?.isHidden = true
                
                label?.tag = LoadingLabelTag
                view.addSubview(label!)
                
                label?.topAnchor.constraint(equalTo: loadingIndicator.layoutMarginsGuide.bottomAnchor, constant: 10).isActive = true
                label?.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor).isActive = true
                label?.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor).isActive = true
            }
            
            return label!
        }
    }
    
    func startAnimatingLoadingIndicator(message: String?) {
        
        // hide all views
        for subview in view.subviews {
            subview.isHidden = true
        }
        
        // show activity indicator
        loadingIndicator.isHidden = false
        
        if let text = message {
            loadingLabel.isHidden = false
            loadingLabel.text = text
        }
        
        // start animating activity indicator
        loadingIndicator.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func stopAnimatingLoadingIndicator(message: String?, shouldShowSubviews: Bool = true) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
        
        if let text = message {
            loadingLabel.text = text
            return
        }
        
        loadingLabel.isHidden = true
        
        if shouldShowSubviews {
            showSubviews()
        }
    }
    
    func hideLoadingLabel() {
        loadingLabel.isHidden = true
        showSubviews()
    }
    
    // MARK: Private
    
    fileprivate func showSubviews() {
        for subview in view.subviews {
            if subview == loadingIndicator || subview == loadingLabel {
                continue
            }
            subview.isHidden = false
        }
    }
}



