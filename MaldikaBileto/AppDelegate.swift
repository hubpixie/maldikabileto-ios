//
//  AppDelegate.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/06/27.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //
        // Firebase Setting
        //
        self.configureFirebaseApp()
        //self.registerFirebseMessaging(for: application)
        
        //
        //Google signin
        //
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        //
        // Facebook
        //
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //タブバーの初期設定
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor(displayP3Red: 0x29/0xFF, green: 0x29/0xFF, blue: 0x29/0xFF, alpha: 1.0),
                                                          NSAttributedStringKey.font : UIFont(name: "SFProText-Bold", size: 13) as Any], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor(displayP3Red: 0x29/0xFF, green: 0x29/0xFF, blue: 0x29/0xFF, alpha: 1.0),NSAttributedStringKey.font : UIFont(name: "SFProText-Regular", size: 13) as Any], for: .normal)
        UITabBar.appearance().tintColor = UIColor.cmyMainColor()
        
        // ナビゲーションバーの初期設定
        UINavigationBar.appearance().barTintColor = UIColor.cmyMainColor()
        UINavigationBar.appearance().tintColor = UIColor.white

        UINavigationBar.appearance().backIndicatorImage = UIImage(named: "ico_back_white")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "ico_back_white")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)

        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont(name: "SFProText-Semibold", size: 17)!]
        
        //ステータスバー・ナビゲーションバーの色設定
        UINavigationBar.appearance().barStyle = .blackOpaque
        UIApplication.shared.statusBarStyle = .lightContent
        
        //全体ラベルの色設定
        //UILabel.appearance().textColor = UIColor.cmyTextColor()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Messaging.messaging().shouldEstablishDirectChannel = false
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
//        //パスコード入力を聞くようにする
//        CmyViewController.mainViewController?.checkPasscodeSetting(checkedHandler: {
            //お知らせ一覧取得
            CmyAPIClient.fetchInquireList(completionHander: nil)
//        })
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        self.connectToFcm()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // [START openurl]
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    // [END openurl]
    
    //
    // this is avaible on iOS 9.0+
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        //for Facebook auth
        var handled: Bool = true
        if CmyViewController.currentLoginProvider == .facebook {
            handled = FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                                  open: url,
                                                                                  sourceApplication: options[.sourceApplication] as? String,
                                                                                  annotation: options[.annotation])
            return handled
        }
        //for Google auth
        if CmyViewController.currentLoginProvider == .google {
            handled =  (GIDSignIn.sharedInstance().handle(url,
                                                          sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                          annotation: options[UIApplicationOpenURLOptionsKey.annotation]))
            // Add any custom logic here.
            return handled
        }
        return handled
    }
    
    // mark: - remote notification
    //
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        //        Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("[application didReceiveRemoteNotification] Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        completionHandler(.newData)
    }
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        Messaging.messaging().apnsToken = deviceToken
        
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("[userNotificationCenter willPresent]Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("[userNotificationCenter didReceive] Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        /*
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        self.connectToFcm()
         */
    }
    // [END refresh_token]
    
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
        
        Messaging.messaging().shouldEstablishDirectChannel = true
    }
    // [END ios_10_data_message]
}

extension AppDelegate {
    
    // Firebse configuration
    //
    func configureFirebaseApp() {
        // Firebase config
        #if STAGING
        let filePath = Bundle.main.path(forResource: "GoogleService-Info-staging", ofType: "plist")!
        #else
        let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")!
        #endif
        
        let options = FirebaseOptions(contentsOfFile: filePath)
        FirebaseApp.configure(options: options!)
        
        
        // Add notification for recieving / sending firebase cloud messages
        NotificationCenter.default.addObserver(self, selector:
            #selector(self.tokenRefreshNotification), name:
            NSNotification.Name.InstanceIDTokenRefresh, object: nil)
//        NotificationCenter.default.addObserver(self, selector:
//            #selector(self.fcmConnectionStateChange), name:
//            NSNotification.Name.MessagingConnectionStateChanged, object: nil)
        
    }
    // firebase cloud message
    //
    @objc func tokenRefreshNotification(_ notification: Notification) {
        // Connect to FCM since connection may have failed when attempted before having a token.
        self.connectToFcm()
    }
    
 
    func connectToFcm() {
        // Won't connect since there is no token
        InstanceID.instanceID().instanceID(handler: { (idToken, error) in
            if let _ = error {return}
            guard let idToken = idToken else {return}
            print("connectToFcm: fcmToken = \(idToken.token)")
            Messaging.messaging().shouldEstablishDirectChannel = true
            
            // send fcmToken to web api
            let dataDict:[String: String] = ["token": idToken.token]
            NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        })
    }
    
    // register firebase messaging setting for this app.
    //
    func registerFirebseMessaging(for application: UIApplication, completionHandler: (()->())?) {
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().delegate = self
            
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in
                    completionHandler?()
            })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            completionHandler?()
        }
        
        application.registerForRemoteNotifications()
        
        // [END register_for_notifications]
    }
    
    // Sign out firebse app authentication from this app
    //
    func signOutFirebseAuth() {
        // unsetup setting of MaldikaBileto API Client
        CmyAPIClient.unsetup()
        
        // sign out Firebase authentication
        try! Auth.auth().signOut()
    }
}
extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selectedVC = tabController.selectedViewController {
                if let nav = selectedVC as? UINavigationController {
                    return nav.visibleViewController
                } else {
                    return topViewController(controller: selectedVC)
                }
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}


