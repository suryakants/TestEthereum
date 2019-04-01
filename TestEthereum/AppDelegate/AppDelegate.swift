//
//  AppDelegate.swift
//  TestEthereum
//
//  Created by Suryakant on 9/23/18.
//  Copyright © 2018 Suryakant. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow();
        window?.makeKeyAndVisible();
        window?.rootViewController = SignInViewController();
       
        //start reachbility  test
        ReachabilityManager.sharedInstance.allocRechability();
        return true
    }
}

