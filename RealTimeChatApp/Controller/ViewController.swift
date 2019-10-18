//
//  ViewController.swift
//  RealTimeChatApp
//
//  Created by Mohamed Samir on 9/30/19.
//  Copyright © 2019 Mohamed Samir. All rights reserved.
//

import UIKit
import  Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionViewOutlet.delegate = self
        collectionViewOutlet.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if Auth.auth().currentUser != nil  && UserDefaults.standard.value(forKey: "api_token") != nil {
            self.goToRooms()
        }else{}
        
    }
}

extension ViewController : UICollectionViewDataSource , UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoginAndRegisterCell", for: indexPath) as! LoginAndRegisterCell
        
        if indexPath.row == 0 {
            cell.usernameContainerView.isHidden = true
            cell.actionButton1.setTitle("Log In", for: .normal)
            cell.actionButton2.setTitle(" Sign Up👉", for: .normal)
            cell.actionButton2.addTarget(self, action: #selector (slideToSignUp(_:)), for: .touchUpInside)
            cell.actionButton1.addTarget(self, action: #selector (didPressSignIn(_:)), for: .touchUpInside)
        }else if indexPath.row == 1 {
            cell.usernameContainerView.isHidden = false
            cell.actionButton1.setTitle(" Sign Up", for: .normal)
            cell.actionButton2.setTitle("👈 Sign In", for: .normal)
            cell.actionButton2.addTarget(self, action: #selector (slideToSignIn(_:)), for: .touchUpInside)
            cell.actionButton1.addTarget(self, action: #selector (didPressSignUp(_:)), for: .touchUpInside)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionViewOutlet.frame.size
    }
    @ objc func slideToSignIn(_ sender : UIButton){
        let indexPath = IndexPath(row: 0, section: 0)
        collectionViewOutlet.scrollToItem(at: indexPath, at: [.centeredHorizontally], animated: true)
    }
    @ objc func slideToSignUp(_ sender : UIButton){
        let indexPath = IndexPath(row: 1, section: 0)
        collectionViewOutlet.scrollToItem(at: indexPath, at: [.centeredHorizontally], animated: true)
    }
    
    ///sign in
    @ objc func didPressSignIn(_ sender : UIButton){
        
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = collectionViewOutlet.cellForItem(at: indexPath) as! LoginAndRegisterCell
        let emailAddress = cell.emailTF.text ?? "", password = cell.passwordTF.text ?? ""
        if !emailAddress.isEmpty && !password.isEmpty{
                Auth.auth().signIn(withEmail: emailAddress, password: password) { (Result, error) in
                    if error == nil {
                        guard let result = Result else {return}
                        print("User ID ==========>"+result.user.uid)
                        self.goToRooms()
                        
                    }else {
                        print(error ?? "======>Error")
                    }
            }
        }else {
            displayEroor()
        }
    }
    ////sign Up
    @ objc func didPressSignUp(_ sender : UIButton){
        
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = collectionViewOutlet.cellForItem(at: indexPath) as! LoginAndRegisterCell
        let username = cell.usernameTF.text ?? "", emailAddress = cell.emailTF.text ?? "", password = cell.passwordTF.text ?? ""
        if !emailAddress.isEmpty && !password.isEmpty && !username.isEmpty{
        
                Auth.auth().createUser(withEmail: emailAddress, password: password) { (Result, error) in
                    if error == nil {
                        guard let result = Result else {return}
                        let reference = Database.database().reference()
                        let user = reference.child("Users").child(result.user.uid)
                        //data may be more than username so , we will create it in array
                        let dataArray : [String:Any] = ["username":username]
                        user.setValue(dataArray)
                        UserDefaults.standard.setValue(result.user.uid, forKey: "api_token")
                        UserDefaults.standard.synchronize()
                        print("User ID ==========>"+result.user.uid)
                        
                        self.goToRooms()
                    }else {
                        print(error ?? "======>Error")
                    }
            }
        }else {
            displayEroor()
        }
    }
    
    func displayEroor(){
        let alert = UIAlertController(title: "Error", message: "empty username or password", preferredStyle: .alert)
        let action = UIAlertAction(title: "ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        print("empty username or password")
    }
    // in case of login or sign up
    func goToRooms(){
        let vc = storyboard?.instantiateViewController(withIdentifier: "NavigationController") as! NavigationController
        present(vc, animated: true, completion: nil)
    }
}
