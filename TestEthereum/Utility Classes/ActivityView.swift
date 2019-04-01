//
//  GTActivityView.swift
//  TestEthereum
//
//  Created by Suryakant on 9/23/18.
//  Copyright © 2018 Suryakant. All rights reserved.
//

import Foundation
import UIKit

class ActivityIndicator: NSObject {
    
    static let shared = ActivityIndicator()
    
    //Initializer access level change now
    private override init(){}
    
    var activityIndicator : UIActivityIndicatorView?
    //Activity indicator
    func activityIndicatorStart(to view: UIView){
        // Create the Activity Indicator
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        DispatchQueue.main.async(execute: {
            // Add it to the view where you want it to appear
            view.addSubview(self.activityIndicator!)
            
            // Set up its size (the super view bounds usually)
            self.activityIndicator?.center = view.center
            self.activityIndicator?.backgroundColor = .white;
            
            // Start the loading animation
            self.activityIndicator?.startAnimating()
        });
    }
    
    func activityIndicatorStop(){
        // To remove it, just call removeFromSuperview()
        DispatchQueue.main.async(execute: {
            self.activityIndicator?.removeFromSuperview()
            self.activityIndicator = nil;
        })
    }
    
}
