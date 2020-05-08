//
//  AppDelegate.swift
//  MyArchitecture
//
//  Created by qufei on 2020/5/8.
//  Copyright © 2020 qufei. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        
        let rootViewController = ViewController()
        let navigationController = UINavigationController.init(rootViewController: rootViewController)
        self.window?.rootViewController = navigationController
//        self.window?.rootViewController = rootViewController
        
        self.window?.makeKeyAndVisible()
        
        // 显示引导视图
        self.showGuideImages()
        // 注册服务
        self.registerService()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}


//MARK: - 注册服务

fileprivate extension AppDelegate {
    /// 注册服务
    func registerService() {
        // 注册服务[推送]
        RemotePushNotificationsManager.share.registrationProcessWithAPNs()
        // 3DTouch
        ThreeDTouchService.register3DTouch()
    }
}

fileprivate extension AppDelegate {
    
    func showGuideImages() -> Void {
        let newVersion: String = AppInfo.appVersion
        let oldVersion: String? = UserDefaultManager.storeValue(forKey: GeneralStoreKey.appVersion.rawValue, type: .string) as? String
        if let anOldVersion = oldVersion, newVersion == anOldVersion {
            return
        }
        // 添加引导视图
        let guideView = GuideView.init(frame: UIScreen.main.bounds)
        self.window?.addSubview(guideView)
        UserDefaultManager.storeValue(newVersion, forKey: GeneralStoreKey.appVersion.rawValue, type: .string)
    }
}
