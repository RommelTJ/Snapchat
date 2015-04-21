//
//  UserTableViewController.swift
//  Snapchat
//
//  Created by Rommel Rico on 3/18/15.
//  Copyright (c) 2015 Rommel Rico. All rights reserved.
//

import UIKit

class UserTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var userArray: [String] = []
    var activeRecipient = 0
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Get list of users.
        var query = PFUser.query()
        query!.whereKey("username", notEqualTo:PFUser.currentUser()!.username!)
        var users = query!.findObjects()
        for user in users! {
            userArray.append((user.username)!!)
            tableView.reloadData()
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("checkMessages"), userInfo: nil, repeats: true)
    }
    
    func checkMessages() {
        var query = PFQuery(className: "Image")
        query.whereKey("recipientUsername", equalTo:PFUser.currentUser()!.username!)
        var images = query.findObjects()
        
        var done = false
        for image in images! {
            if done == false {
                var imageView:PFImageView = PFImageView()
                imageView.file = image["photo"] as! PFFile
                //Download image
                imageView.loadInBackground({ (photo, error) -> Void in
                    if error == nil {
                        var senderUsername = ""
                        if image["senderUsername"] != nil {
                            senderUsername = image["senderUsername"]! as! String
                        }

                        var alert = UIAlertController(title: "You have a message!", message: "Message from \(senderUsername)", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                            var backgroundImage = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                            backgroundImage.backgroundColor = UIColor.blackColor()
                            backgroundImage.alpha = 0.9
                            backgroundImage.tag = 3
                            self.view.addSubview(backgroundImage)
                            
                            var displayedImage = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                            displayedImage.image = photo
                            displayedImage.contentMode = UIViewContentMode.ScaleAspectFit
                            displayedImage.tag = 3
                            self.view.addSubview(displayedImage)
                            
                            //delete the image
                            image.delete()
                            
                            self.timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("hideMessage"), userInfo: nil, repeats: false)
                        }))
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                })
                done = true
            }
        }
    }
    
    func hideMessage() {
        //UIApplication.sharedApplication().endIgnoringInteractionEvents()
        for subview in self.view.subviews {
            if subview.tag == 3 {
                subview.removeFromSuperview()
            }
        }
    }
    
    func pickImage(sender: AnyObject) {
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = true
        NSLog("About to present the image.")
        self.presentViewController(image, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return userArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell

        cell.textLabel?.text = userArray[indexPath.row]

        return cell
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        //Upload to Parse Code goes here.
        var imageToSend = PFObject(className:"Image")
        //imageToSend["image"] = UIImageJPEGRepresentation(image, 0.1111)
        imageToSend["photo"] = PFFile(name: "Image", data: UIImageJPEGRepresentation(image, 0.5))
        imageToSend["senderUsername"] = PFUser.currentUser()!.username
        imageToSend["recipientUsername"] = userArray[activeRecipient]
        imageToSend.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
                NSLog("Image sent succesfully!")
            } else {
                // There was a problem, check error.description
                NSLog("ERROR: \(error!.description)")
            }
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        activeRecipient = indexPath.row
        pickImage(self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logout" {
            timer.invalidate()
            PFUser.logOut()
        }
    }
    

}
