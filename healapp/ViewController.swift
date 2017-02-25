//
//  ViewController.swift
//  healapp
//
//  Created by Admin on 2/25/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var caretaker: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if isUserPresent() == true{
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "caretakersegue", sender: self)
            }
        }
        
        caretaker.addTarget(self, action: #selector(ViewController.caretakerr), for: UIControlEvents.valueChanged)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func signup(_ sender: Any) {

        FIRAuth.auth()?.createUser(withEmail: email.text!, password: password.text!, completion: { (user, error) in
            if error != nil{
                print(error)
                if error!._code == ACCOUNT_EXIST{
                    self.showErrorAlert("Email already in use", msg: "Please use a different email")
                }
            }
            else{
                let userData = self.email.text!
                DataService.ds.createUser(user!.uid, user: userData ) // Create and store userdata on Firebase.
                print("signed up")
                self.performSegue(withIdentifier: "clientsegue", sender: self)
                
            }
        })
    }
    @IBAction func login(_ sender: Any) {
        print("login")
        FIRAuth.auth()?.signIn(withEmail: email.text!, password: password.text!, completion: { (user, error) in
            if error != nil{
                
                if self.email.text! == ""{
                    self.showErrorAlert("No email entered", msg: "Please enter a valid email address")
                }
                else if self.password.text! == ""{
                    self.showErrorAlert("No password entered", msg: "Please enter a valid password")
                }
                if error!._code == USER_NOT_FOUND{
                    self.showErrorAlert("Account does not exist", msg: "Please create an account")
                }
                
                if error!._code == WRONG_PASSWORD{
                    self.showErrorAlert("Password incorrect", msg: "Please enter a valid email/pass combination")
                }
                
            } else {
                DataService.ds.REF_USERS.child(user!.uid).observe(.value, with: { (snapshot) in
                    if let details = snapshot.value as? AnyObject{
                        print(details)
                        //self.STORE_IN_PHONE(user_key: "user_data", userData: details as! String)
                    }
                    self.performSegue(withIdentifier: "caretakersegue", sender: self)
                })
                
                
            }
        })
        
        

    }
    
    func isUserPresent()-> Bool{
        let preferences = UserDefaults.standard
        let user_key = "user_data"
        if preferences.object(forKey: user_key) == nil {
            return false //  Doesn't exist
        } else {
            /*
            let user_data = preferences.dictionary(forKey: user_key)!
            user_info(user_data as Dictionary<String, AnyObject>)
            let user_searches = "user_searches"
            if let arr = preferences.array(forKey: user_searches) as? [[String:Any]] {
                searches = arr
            }
            */
            return true
        }
    }

    
    func STORE_IN_PHONE(user_key: String, userData: String){
        let preferences = UserDefaults.standard
        preferences.removeObject(forKey: user_key)
        preferences.set(userData, forKey: user_key)
        //  Save to disk
        let didSave = preferences.synchronize()
        if !didSave {
            //  Couldn't save
        }
        
    }
    
    func caretakerr(){
        if caretaker.isOn{
            print("on")
        }
        else{
            print("off")
        }
    }
    
    func showErrorAlert(_ title:String, msg:String) {
        
        let errorAlert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(errorAlert, animated: true, completion: nil)
        
    }
}

