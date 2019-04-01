//
//  SignInViewController.swift
//  TestEthereum
//
//  Created by Suryakant on 9/23/18.
//  Copyright © 2018 Suryakant. All rights reserved.
//

import UIKit
import web3swift

class SignInViewController: UIViewController {

    private var alertController : UIAlertController?
    private let containerView : UIView = {
        let aView = UIView();
        aView.translatesAutoresizingMaskIntoConstraints = false
        aView.backgroundColor = .blue;
        aView.layer.cornerRadius = 10.0;
        return aView;
    }();

    private let signInBtn : UIButton = {
        let button = UIButton();
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white;
        button.backgroundColor = .clear
        button.setTitle("Sign In", for: .normal)
        button.addTarget(self, action:#selector(SignInViewController.signIn(_:)), for: .touchUpInside)

        return button;
    }();
    

    private let privateKeyTextField: UITextField = {
        let textField = UITextField();
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.systemFont(ofSize: FontSizeContant.detaiFontSize);
        textField.backgroundColor = .white
        textField.textAlignment = .center
        textField.layer.cornerRadius = 6.0;
        textField.attributedPlaceholder = NSAttributedString(string: "Enter your private key",
                                                             attributes: [NSAttributedStringKey.foregroundColor: UIColor.black])
        textField.textColor = .black;
        return textField;
    }();
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup the view
        setUpView();
        //TODO:- For test, remove this
        self.privateKeyTextField.text = "0xFDD8e4b01C3cF231FE833421982A32A0B34777D6";
    }
    func setUpView(){
        self.view.backgroundColor = .white
        self.view.addSubview(containerView);
        self.containerView.addSubview(privateKeyTextField)
        self.containerView.addSubview(signInBtn)

        //containerView setup
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                containerView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                containerView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                containerView.heightAnchor.constraint(equalToConstant: 150.0),
                containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant:10),
                containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant:-10),
                ])
        } else {
            NSLayoutConstraint.activate([
                containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                containerView.heightAnchor.constraint(equalToConstant: 150.0),
                containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:10),
                containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:-10),
                ])
        }
        
        //privateKeyTextField setup
        NSLayoutConstraint.activate([
            privateKeyTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
            privateKeyTextField.heightAnchor.constraint(equalToConstant: 31.0),
            privateKeyTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
            privateKeyTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5),
            ])
        
        //signInBtn setup
        NSLayoutConstraint.activate([
            signInBtn.topAnchor.constraint(equalTo: privateKeyTextField.bottomAnchor, constant: 15),
            signInBtn.heightAnchor.constraint(equalToConstant: 21.0),
            signInBtn.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
            signInBtn.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5),
            ])
    }
    
    @objc func signIn(_ sender: UIButton?)  {
        //check network reachablity and return if device is not connected with network.
        if(!ReachabilityManager.sharedInstance.isNetworkWorking){
            self.showErrorMessage(at: self, title: "No Network", messase: "Device not in Network, please connect to network & try.")
            return;
        }
        if let enteresAddress = privateKeyTextField.text, enteresAddress != "" {
            ActivityIndicator.shared.activityIndicatorStart(to: self.view);
            let walletDetailViewController = WalletDetailViewController();
            guard let balance = self.fetchBalance(address: enteresAddress) else {
                self.showErrorMessage(at: self, title: "Error", messase: "Something went wrong!")
                ActivityIndicator.shared.activityIndicatorStop();
                return
            };
            walletDetailViewController.balance = balance;
            GNManager.shared.privateKey = enteresAddress;
            self.present(setupNavigationController(rootVC: walletDetailViewController), animated: true, completion: nil);
        }
        else{
            ActivityIndicator.shared.activityIndicatorStop();
            self.showErrorMessage(at: self, title: "Error", messase: "Enter your private key!")
        }
    }
        
    func fetchBalance(address: String) -> String?{
        guard let address = EthereumAddress(address) else { return nil };//("0xFDD8e4b01C3cF231FE833421982A32A0B34777D6")!
        let web3Rinkeby = Web3.InfuraRinkebyWeb3()
        let balanceResult = web3Rinkeby.eth.getBalance(address: address)
        guard case .success(let balance) = balanceResult else { return nil}
        print("Balance of " + address.address + " = " + String(balance))
        return String(balance);
    }
    //Navigation bar setup
    func setupNavigationController(rootVC : UIViewController) -> UINavigationController{
        let navigationController = UINavigationController(rootViewController: rootVC)
        return navigationController;
    }
    
    func showErrorMessage(at viewController:UIViewController, title: String, messase:String){
        if (alertController != nil) && alertController?.isBeingPresented == true{
            alertController?.dismiss(animated: true, completion: nil);
            alertController = nil;
        }
        alertController = UIAlertController(title: title, message: messase, preferredStyle: .alert)
        alertController?.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        DispatchQueue.main.async(execute: {
            if self.presentedViewController != nil{
                self.presentedViewController?.dismiss(animated: false, completion: nil);
            }
            viewController.present(self.alertController!, animated: true, completion: nil)
        })
    }

}
