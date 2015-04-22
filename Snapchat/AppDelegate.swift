//
//  AppDelegate.swift
//  Snapchat
//
//  Created by Rommel Rico on 3/18/15.
//  Copyright (c) 2015 Rommel Rico. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Parse.enableLocalDatastore()
        Parse.setApplicationId("REDACTED", clientKey: "REDACTED")
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]!) -> Void)!) {
        //Called every time we send an openParentApplication request from the Watch Extension.
        if let message = userInfo as? [String:String] {
            if let content = message["content"] {
                if content == "isLoggedIn" {
                    //RUN PARSE CODE for Apple Watch
                    if PFUser.currentUser() != nil {
                        //User is logged in
                        reply(["loggedIn": "true"])
                    } else {
                        reply(["loggedIn": "false"])
                    }
                } else if content == "getMessages" {
                    //RUN PARSE CODE for Apple Watch
                    //Get list of users.
                    var userArray = [String]()
                    var query = PFUser.query()
                    query!.whereKey("username", notEqualTo:PFUser.currentUser()!.username!)
                    var users = query!.findObjects()
                    for user in users! {
                        userArray.append((user.username)!!)
                    }
                    reply(["messages": userArray])
                } else {
                    reply(["content": "What do you want?"])
                }
            }
        }
    }

}

