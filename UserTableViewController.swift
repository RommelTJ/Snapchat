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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Get list of users.
        var query = PFUser.query()
        query.whereKey("username", notEqualTo:PFUser.currentUser().username)
        var users = query.findObjects()
        for user in users {
            userArray.append(user.username)
            tableView.reloadData()
        }
    }
    
    func pickImage(sender: AnyObject) {
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.Camera
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
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell

        cell.textLabel?.text = userArray[indexPath.row]

        return cell
    }

    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        //Upload to Parse Code goes here.
        var imageToSend = PFObject(className:"Image")
        //imageToSend["image"] = UIImageJPEGRepresentation(image, 0.1111)
        imageToSend["photo"] = PFFile(name: "Image", data: UIImageJPEGRepresentation(image, 0.5))
        imageToSend["senderUsername"] = PFUser.currentUser().username
        imageToSend["recipientUsername"] = userArray[activeRecipient]
        imageToSend.saveInBackgroundWithBlock {
            (success: Bool, error: NSError!) -> Void in
            if (success) {
                // The object has been saved.
                NSLog("Image sent succesfully!")
            } else {
                // There was a problem, check error.description
                NSLog("ERROR: \(error.description)")
            }
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        activeRecipient = indexPath.row
        pickImage(self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logout" {
            PFUser.logOut()
        }
    }
    

}
