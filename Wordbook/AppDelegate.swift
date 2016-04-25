//
//  AppDelegate.swift
//  Wordbook
//
//  Created by Jerry on 16/4/15.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        self.initApprearance()
        self.window = UIWindow(frame:UIScreen.mainScreen().bounds)
        
        let naviController = UINavigationController(rootViewController: RootViewController())
        self.window?.rootViewController = naviController
        
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        
    }

    func applicationWillEnterForeground(application: UIApplication) {
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        
    }

    func applicationWillTerminate(application: UIApplication) {
        CoreDataManager.sharedInstance().saveContext()
    }
    
    func initApprearance() {
        UINavigationBar.appearance().tintColor = AppConst.themeColor
    }
}

