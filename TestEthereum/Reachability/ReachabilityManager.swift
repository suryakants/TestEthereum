//
//  ReachabilityManager.swift
//  ****
//
//  Created by Suryakant Sharma on 03/08/15.
//  Copyright (c) 2015 ****. All rights reserved.
//

import Foundation

protocol updateNetworkReachibility{
    func updateNetworkAvilable()
    func updateNetworkNotAvilable()
}

class ReachabilityManager:NSObject {
    var isNetworkWorking = false
    var isOverCellular = false
    var reachability = Reachability()
    var delegateNetworkReachibility : updateNetworkReachibility?
    
    class var sharedInstance: ReachabilityManager {
        struct Singleton {
            static let networkOperations = ReachabilityManager()
        }
        return Singleton.networkOperations
    }
    
    override init() {
        super.init()
    }
    func allocRechability() {
        NotificationCenter.default.addObserver(self, selector: #selector(ReachabilityManager.reachabilityChanged(_:)), name: NSNotification.Name(rawValue: "ReachabilityNotification"), object: reachability)
        do {
            try reachability?.startNotifier()
        } catch {
            return
        }
        // Initial reachability check
        if let reach = reachability {
            if reach.isReachable {
                updateWhenReachable(reach)
            } else {
                updateWhenNotReachable(reach)
            }
        }
    }
    
    
    func updateWhenReachable(_ reachability: Reachability) {
        self.setCellularDataFlags(reachability)
        self.isNetworkWorking = true
        if let _ = delegateNetworkReachibility{
            delegateNetworkReachibility?.updateNetworkAvilable()
        }
    }
    
    func updateWhenNotReachable(_ reachability: Reachability) {
        self.isNetworkWorking = false
        // change me
        //the notification must be send from Reachability.swift to AuthenticationManager.swift
        // NSNotificationCenter.defaultCenter().postNotificationName(N_NetRechability, object:nil)
        if let _ = delegateNetworkReachibility{
            delegateNetworkReachibility?.updateNetworkNotAvilable()
        }
    }
    
    @objc func reachabilityChanged(_ note: Notification) {
        if let reachability = note.object as? Reachability{
            if reachability.isReachable {
                self.isNetworkWorking = true
            } else {
                self.isNetworkWorking = false
            }
            self.setCellularDataFlags(reachability)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ReachabilityConstant.kReachabilityChange), object:reachability)
        }
        
    }
    
    func setCellularDataFlags(_ reachability: Reachability){
        if reachability.isReachableViaWiFi{
            self.isOverCellular = false
        } else {
            self.isOverCellular = true
        }
    }
    func checkNetReachability() -> (error:NSError , isNetworkAvilable: Bool){
        let error = NSError(domain: ReachabilityConstant.kErrorDomain, code:ReachabilityConstant.kNetworkReachability, userInfo: [ NSLocalizedDescriptionKey : "Network unavailable!" ])
        return  (error, self.isNetworkWorking)
    }
}
