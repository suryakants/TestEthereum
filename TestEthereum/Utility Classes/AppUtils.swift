//
//  AppUtils.swift
//  TestEthereum
//
//  Created by Suryakant on 3/31/19.
//  Copyright © 2019 Suryakant. All rights reserved.
//

import UIKit


func showMessage(message : String, title: String , onViewController: UIViewController) {
    
    let title = NSLocalizedString(title, comment: "TITLE")
    let message = NSLocalizedString(message, comment: "MESSAGE")

    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)

    let okButtonTitle = NSLocalizedString("sign.message.alert.button.ok", comment: "Positive Button title")
    let okBtn = UIAlertAction(title: okButtonTitle, style: UIAlertActionStyle.default)

    alertController.addAction(okBtn)
    
    onViewController.present(alertController, animated: true, completion: nil)
}
