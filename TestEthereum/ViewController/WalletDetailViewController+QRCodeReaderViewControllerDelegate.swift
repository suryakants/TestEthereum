//
//  WalletDetailViewController+QRCodeReaderViewControllerDelegate.swift
//  TestEthereum
//
//  Created by Suryakant on 9/24/18.
//  Copyright © 2018 Suryakant. All rights reserved.
//

import Foundation
import QRCodeReader
import web3swift

extension WalletDetailViewController : QRCodeReaderViewControllerDelegate{
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        dismiss(animated: true) {
            
        }
    }
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
    
    
}
