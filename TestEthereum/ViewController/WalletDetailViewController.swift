//
//  WalletDetailViewController.swift
//  TestEthereum
//
//  Created by Suryakant on 9/23/18.
//  Copyright © 2018 Suryakant. All rights reserved.
//

import UIKit
import QRCodeReader
import web3swift
import secp256k1


class WalletDetailViewController: UIViewController {
    
    //QR Code scan
    private lazy var qrCodeReaderViewController: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()

    var balance : String?
    private let containerView : UIView = {
        let aView = UIView();
        aView.translatesAutoresizingMaskIntoConstraints = false
        aView.backgroundColor = .blue;
        aView.layer.cornerRadius = 10.0;
        return aView;
    }();
    
    private let balanceLbl: UILabel = {
        let label = UILabel();
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white;
        label.text = "$0.0";
        return label;
    }();
    
    private let signBtn : UIButton = {
        let button = UIButton();
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white;
        button.backgroundColor = .blue
        button.layer.cornerRadius = 5.0;
        button.setTitle("Sign", for: .normal)
        button.addTarget(self, action:#selector(WalletDetailViewController.sign(_:)), for: .touchUpInside)
        return button;
    }();
    
    private let verifyBtn : UIButton = {
        let button = UIButton();
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white;
        button.backgroundColor = .blue
        button.layer.cornerRadius = 5.0;
        button.setTitle("Verify", for: .normal)
        button.addTarget(self, action:#selector(WalletDetailViewController.verify(_:)), for: .touchUpInside)
        return button;
    }();



    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Wallet"
        self.balanceLbl.attributedText = formBalanceString();
        setupView()
    }
    
    private func setupView(){
        self.view.backgroundColor = .white;
        
        self.view.addSubview(containerView);
        self.view.addSubview(signBtn);
        self.view.addSubview(verifyBtn);

        //balance label to containerView.
        self.containerView.addSubview(balanceLbl);
        
        //containerView setup
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                containerView.heightAnchor.constraint(equalToConstant: 150.0),
                containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant:10),
                containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant:-10),
                ])
        } else {
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: view.topAnchor),
                containerView.heightAnchor.constraint(equalToConstant: 150.0),
                containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:10),
                containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:-10),
                ])
        }
        //contraints to balance lbl
        NSLayoutConstraint.activate([
            balanceLbl.topAnchor.constraint(equalTo: containerView.topAnchor, constant:15),
            balanceLbl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant:10),
            balanceLbl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant:-10),
            ])

        NSLayoutConstraint.activate([
            signBtn.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant:15),
            signBtn.widthAnchor.constraint(equalToConstant: 100),
            signBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:(self.view.frame.size.width-215)/2),
            ])
        
        NSLayoutConstraint.activate([
            verifyBtn.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant:15),
            verifyBtn.widthAnchor.constraint(equalToConstant: 100),
            verifyBtn.leadingAnchor.constraint(equalTo: signBtn.trailingAnchor, constant:10),
            ])


    }
    
    private func formBalanceString() -> NSAttributedString {
        let balanceStr = NSMutableAttributedString()
        balanceStr.append(NSMutableAttributedString(string: "Balance: ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: FontSizeContant.detaiFontSize), NSAttributedStringKey.foregroundColor: UIColor.white]))
        balanceStr.append(NSAttributedString(string:(balance ?? ""), attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: FontSizeContant.titleFontSize), NSAttributedStringKey.foregroundColor: UIColor.white]))
        balanceStr.append(NSMutableAttributedString(string: " Ether", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: FontSizeContant.detaiFontSize), NSAttributedStringKey.foregroundColor: UIColor.white]))

        return balanceStr
    }
    
    private func generateQRCode(from string: String?) -> UIImage? {
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

    func setupNavigationController(rootVC : UIViewController) -> UINavigationController{
        let navigationController = UINavigationController(rootViewController: rootVC)
        return navigationController;
    }
    
    //MARK:- Button Action methods
    @objc func sign(_ sender: UIButton?)  {
        presetAlertView()
    }
    
    @objc func verify(_ sender: UIButton?)  {
        print("Button Clicked")
        qrCodeReaderViewController.delegate = self

        // Or by using the closure pattern
        qrCodeReaderViewController.completionBlock = { (result: QRCodeReaderResult?) in        }

        // Presents the readerVC as modal form sheet
        qrCodeReaderViewController.modalPresentationStyle = .formSheet
        present(qrCodeReaderViewController, animated: true, completion: nil)
    }
    
    func presetAlertView(){
        let title = NSLocalizedString("sign.message.alert.title", comment: "TITLE")
        let alertController = UIAlertController(title: title, message: "", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = NSLocalizedString("sign.message.alert.placeholder.text", comment: "TITLE")
        }
        let signTitle = NSLocalizedString("sign.message.alert.sign.button.text", comment: "Positive Button title")
        let cancelTitle = NSLocalizedString("sign.message.alert.cancel.button.text", comment: "Cancel Button title")

        let saveAction = UIAlertAction(title: signTitle, style: UIAlertActionStyle.default, handler: { alert -> Void in
            if let firstTextField = alertController.textFields?[0], let str = firstTextField.text {
                self.signMessage(message: str);
            }
        })
        let cancelAction = UIAlertAction(title: cancelTitle, style: UIAlertActionStyle.default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func signMessage(message : String) {
        
//        let web3Rinkeby = Web3.InfuraRinkebyWeb3()
//        let keystore = try! EthereumKeystoreV3(password: "")
//        let keystoreManager = KeystoreManager([keystore!])
//        web3Rinkeby.addKeystoreManager(keystoreManager)
//        let address = keystoreManager.addresses![0]
//        let data = messageStr.data(using: .utf8)
//        let signMsg = web3Rinkeby.wallet.signPersonalMessage(data!, account: address);
//        print(signMsg.debugDescription)
        
        
        let web3 = Web3.InfuraRinkebyWeb3()
        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        web3.addKeystoreManager(keystoreManager)
        let expectedAddress = keystoreManager.addresses![0]
        print(expectedAddress)
        guard case .success(let signature) = web3.personal.signPersonalMessage(message: message.data(using: .utf8)!, from: expectedAddress, password: "")
            else {
                //show some errror.
                return;
        }
        let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: signature)!
        print("V = " + String(unmarshalledSignature.v))
        print("R = " + Data(unmarshalledSignature.r).toHexString())
        print("S = " + Data(unmarshalledSignature.s).toHexString())
        print("Personal hash = " + Web3.Utils.hashPersonalMessage(message.data(using: .utf8)!)!.toHexString())
        let signer = web3.personal.ecrecover(personalMessage: message.data(using: .utf8)!, signature: signature)

        //gererateQRCodeFor(message: signMsg);
    }
    
    func gererateQRCodeFor(message: String) {
        let qrCodeGenerator = QRCodeGeneratorViewController();
        qrCodeGenerator.qrString = message;
        self.present(self.setupNavigationController(rootVC: qrCodeGenerator), animated: true, completion: nil);

    }
}
