//
//  QRCodeGeneratorViewController.swift
//  TestEthereum
//
//  Created by Suryakant on 9/24/18.
//  Copyright © 2018 Suryakant. All rights reserved.
//

import Foundation
import UIKit
import web3swift

class QRCodeGeneratorViewController : UIViewController {
    
    var qrString : String?
    private let qrCodeImageView : UIImageView = {
        let imageView = UIImageView();
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView;
    }();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Signed String QR Code"
        //setup the view
        setupView();
        if qrString != nil, let data = signPersonalSignature(message: qrString!) {
            qrCodeImageView.image = generateQRCode(from: data);
        }
        else{
            
        }
    }
    func setupView(){
        self.view.backgroundColor = .white;
        //adding right bar buttom buton to present mapview
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(QRCodeGeneratorViewController.dismissView));
        
        //qrCodeImageView setup
        self.view.addSubview(qrCodeImageView)
        
        NSLayoutConstraint.activate([
            qrCodeImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            qrCodeImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            qrCodeImageView.heightAnchor.constraint(equalToConstant: 200),
            qrCodeImageView.widthAnchor.constraint(equalToConstant: 200),
            ])

    }
    let keyservice = KeysService()
    var web3Instance: web3 {
        let web3 = Web3.InfuraRinkebyWeb3()
        web3.addKeystoreManager(keyservice.keystoreManager())
        return web3
    }

    @objc func dismissView()  {
        self.dismiss(animated: true, completion: nil);
    }
    
    func generateQRCode(from string: String?) -> UIImage? {
        guard let string = string else {
            return nil
        }
        var code: String
        if let c = Web3.EIP67Code(address: string)?.toString() {
            code = c
        } else {
            code = string
        }
        
        let data = code.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    func generateQRCode(from data: Data?) -> UIImage? {
        guard let data = data else {
            return nil
        }
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }

    
    func signMessage(message: String) -> Data?{
        
        guard let address = EthereumAddress(GNManager.shared.privateKey!) else { return nil }
        guard  let messageData = message.data(using: .ascii) else {return nil}
        guard let messageHash = Web3.Utils.hashPersonalMessage(messageData) else {return nil}


        print("messageHash: 0x" + messageHash.toHexString())
        guard case .success(_) = web3Instance.personal.signPersonalMessage(message: messageHash, from: address) else {
            print("Failure")
            return nil }
        
////        print(result.error.debugDescription)
////        print(result.value?.description)
//
//        let result = web3Instance.personal.signPersonalMessage(message: data!, from: address)
//        print(result.error.debugDescription)
//        print(result.value?.description)
//
//
////        let result = web3Instance.personal.signPersonalMessage(message: messageHash, from: address);
////        print(result.error.debugDescription)
////        print(result.value?.description)
//        guard case .success(let signature) = web3Instance.personal.signPersonalMessage(message: messageHash, from: address) else {
//            print("Failure")
//            return nil }
//        return signature
        return messageHash;
    }
    
    
    
    //Sign personal message
    func signPersonalSignature(message: String) -> Data? {
        let web3 = Web3.InfuraRinkebyWeb3()
        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        web3.addKeystoreManager(keystoreManager)
        let expectedAddress = keystoreManager.addresses![0]
        print(expectedAddress)
        let signRes = web3.personal.signPersonalMessage(message: message.data(using: .utf8)!, from: expectedAddress, password: "")
        guard case .success(let signature) = signRes else {return nil}
        return signature;
    }
    
    //verify personal message
//    func verifyMessage(message: String,signature: Data) -> Bool{
//        
//        let web3 = Web3.InfuraRinkebyWeb3()
//        let tempKeystore = try! EthereumKeystoreV3(password: "")
//        let keystoreManager = KeystoreManager([tempKeystore!])
//        web3.addKeystoreManager(keystoreManager)
//        let expectedAddress = keystoreManager.addresses![0]
//        print(expectedAddress)
//        
//        let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: signature)!
//        print("V = " + String(unmarshalledSignature.v))
//        print("R = " + Data(unmarshalledSignature.r).toHexString())
//        print("S = " + Data(unmarshalledSignature.s).toHexString())
//        print("Personal hash = " + Web3.Utils.hashPersonalMessage(message.data(using: .utf8)!)!.toHexString())
//        let recoveredSigner = web3.personal.ecrecover(personalMessage: message.data(using: .utf8)!, signature: signature)
//        guard case .success(let signer) = recoveredSigner else {return false}
//        return (expectedAddress == signer);
//    }

}
