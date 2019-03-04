//
//  SignInViewController.swift
//  Negatif
//
//  Created by Spencer  Pearlman on 9/5/18.
//  Copyright © 2018 Spencer.io. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class SignInViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        // Do any additional setup after loading the view.
    }
    @IBAction func didPressSignIn(_ sender: Any) {
        let email = emailTextField.text
        let password = passwordTextField.text
        
        Auth.auth().signIn(withEmail: email!, password: password!) {(authResult, error) in
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }else{
                self.performSegue(withIdentifier: "developMe", sender: self)
            }
        }
    }
}

