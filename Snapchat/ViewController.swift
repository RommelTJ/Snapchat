//
//  ViewController.swift
//  Snapchat
//
//  Created by Rommel Rico on 3/18/15.
//  Copyright (c) 2015 Rommel Rico. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBAction func doLogin(sender: AnyObject) {
        //Try to log them in. If fail, sign them up.
        PFUser.logInWithUsernameInBackground(usernameTextField.text, password:"mypass") {
            (user: PFUser!, error: NSError!) -> Void in
            if user != nil {
                // Do stuff after successful login.
                NSLog("Successful login!")
                self.performSegueWithIdentifier("showUsers", sender: self)
            } else {
                // The login failed. Check error to see why.
                NSLog("error in login")
                
                var user = PFUser()
                user.username = self.usernameTextField.text
                user.password = "mypass"
                
                user.signUpInBackgroundWithBlock {
                    (succeeded: Bool!, error: NSError!) -> Void in
                    if error == nil {
                        // Hooray! Let them use the app now.
                        NSLog("Sign up successful!")
                        self.performSegueWithIdentifier("showUsers", sender: self)
                    } else {
                        NSLog("Error in Sign Up")
                        // Show the errorString somewhere and let the user try again.
                    }
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() != nil {
            NSLog("User is already logged in. Perform segue.")
            self.performSegueWithIdentifier("showUsers", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

