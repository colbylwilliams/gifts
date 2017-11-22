//
//  AppDelegate.swift
//  gifts
//
//  Created by Colby L Williams on 11/19/17.
//  Copyright © 2017 Colby L Williams. All rights reserved.
//

import UIKit
import AzureData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var hubInfo: (name: String, connection: String)?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if !AzureData.isSetup() {
            if let accountName = Bundle.main.infoDictionary?["ADDatabaseAccountName"] as? String, accountName != "AZURE_COSMOS_DB_ACCOUNT_NAME",
                let accountKey = Bundle.main.infoDictionary?["ADDatabaseAccountKey"]  as? String, accountKey  != "AZURE_COSMOS_DB_ACCOUNT_Key" {
                
                AzureData.setup(forAccountNamed: accountName, withKey: accountKey, ofType: .master)
            }
        }
        
        AzureData.verboseLogging = true

        
        if let hubName = Bundle.main.infoDictionary?["AMNotificationHubName"] as? String, hubName != "AZURE_NOTIFICATIONHUB_NAME",
            let hunConn = Bundle.main.infoDictionary?["AMNotificationHubConnection"]  as? String, hunConn != "AZURE_NOTIFICATIONHUB_CONNECTION" {
            
            hubInfo = (hubName, hunConn)
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization.
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }

        return true
    }

    // Handle remote notification registration.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        // Forward the token to your provider, using a custom method.
        
        let hub: SBNotificationHub = SBNotificationHub.init(connectionString: hubInfo!.connection, notificationHubPath: hubInfo!.name)
        
        do {
            try hub.registerNative(withDeviceToken: deviceToken, tags: Set())
            print("registering for remote notifications")
        } catch {
            print(error.localizedDescription)
        }
        
        //self.enableRemoteNotificationFeatures()
        //self.forwardTokenToServer(token: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // The token is not currently available.
        print("Remote notification support is unavailable due to error: \(error.localizedDescription)")
        //self.disableRemoteNotificationFeatures()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print(userInfo)
        
        completionHandler(.newData)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

