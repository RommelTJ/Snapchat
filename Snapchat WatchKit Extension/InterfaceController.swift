//
//  InterfaceController.swift
//  Snapchat WatchKit Extension
//
//  Created by Rommel Rico on 4/21/15.
//  Copyright (c) 2015 Rommel Rico. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var loginMessage: WKInterfaceLabel!
    @IBOutlet weak var table: WKInterfaceTable!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        WKInterfaceController.openParentApplication(["content": "isLoggedIn"], reply: { (reply, error) -> Void in
            if let response = reply as? [String:String] {
                if let loggedIn = response["loggedIn"] {
                    if loggedIn == "true" {
                        WKInterfaceController.openParentApplication(["content": "getMessages"], reply: { (reply, error) -> Void in
                            if let response = reply as? [String:[String]] {
                                if let messages = response["messages"] {
                                    self.table.setHidden(false)
                                    self.table.setNumberOfRows(messages.count, withRowType: "TableRowController")
                                    //Dispatching on main Queue due to Apple bug.
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        for (index, message) in enumerate(messages) {
                                            let row = self.table.rowControllerAtIndex(index) as! TableRowController
                                            row.tableRowLabel.setText(message)
                                        }
                                    })
                                }
                            }
                        })
                    } else {
                        self.loginMessage.setHidden(false)
                    }
                }
            }
        })
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
