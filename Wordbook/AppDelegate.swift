//
//  AppDelegate.swift
//  Wordbook
//
//  Created by Jerry on 16/4/15.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//

import UIKit
import JWRefreshControl

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        self.initApprearance()
        self.window = UIWindow(frame:UIScreen.main.bounds)
        
        let naviController = UINavigationController(rootViewController: RootViewController())
        self.window?.rootViewController = naviController
        
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataManager.shared.saveContext()
    }
    
    func initApprearance() {
        let themeColor = UIColor(named: "theme")
        UINavigationBar.appearance().tintColor = themeColor
        DefaultRefreshHeaderContentView.appearance().tintColor = themeColor
    }
}

