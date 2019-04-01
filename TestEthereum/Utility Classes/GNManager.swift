//
//  GNManager.swift
//  TestEthereum
//
//  Created by Suryakant on 9/24/18.
//  Copyright © 2018 Suryakant. All rights reserved.
//

import Foundation

class GNManager : NSObject {
    
    static let shared = GNManager()
    //Initializer access level change now
    private override init(){}
    
    var privateKey : String?
}
