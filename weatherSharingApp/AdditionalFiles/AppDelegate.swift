//
//  AppDelegate.swift
//  weatherSharingApp
//
//  Created by user on 3/6/18.
//  Copyright © 2018 Toxa. All rights reserved.
//

import UIKit
import FacebookCore
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        return SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return SDKApplicationDelegate.shared.application(app, open: url, options: options)
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        do {
            try coreDataManager.saveMOC()
        } catch {
            let error = error as NSError
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
}






