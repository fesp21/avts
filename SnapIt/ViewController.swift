//
//  ViewController.swift
//  SnapIt
//
//  Created by Frank Staine-Pyne on 6/2/15.
//  Copyright (c) 2015 Nseatads. All rights reserved.
//



import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    @IBAction func signup(sender: AnyObject) {
        
        PFUser.logInWithUsernameInBackground("myname", password:"mypass") {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                println("loggedIn")
                
                self.performSegueWithIdentifier("showUsers", sender: self)
            } else {
                
                
                var user = PFUser()
                user.username =  self.username.text
                user.password = "mypass"
                user.email = self.email.text
                // other fields can be set just like with PFObject
                //user["phone"] = "415-392-0202"
                
                user.signUpInBackgroundWithBlock {
                    (succeeded: Bool, error: NSError?) -> Void in
                    if let error = error {
                        let errorString = error.userInfo?["error"] as? NSString //{
                        
                        //error = errorString
                        
                        
                        //                    } else {
                        //                        error = "Please try again later"
                        //                    }
                        //
                        // Show the errorString somewhere and let the user try again.
                    } else {
                        // Hooray! Let them use the app now.
                    }
                }

            }
        }
        
        var error = ""
        if username.text == "" || password.text == ""
        {
            error = "Please enter a username and password"
//        } //else {
//            
//            if username.length < 5 || password.length < 8 {
//            var alert = UIAlertController(title: "Check username or password length", message: error
//                , preferredStyle: UIAlertControllerStyle.Alert)
//            }
        }
        if error != "" {
            var alert = UIAlertController(title: "Error in form", message: error, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { actoin in
                
                self.dismissViewControllerAnimated(true, completion: nil)
                
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser() != nil {
            self.performSegueWithIdentifier("showUsers", sender: nil)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

