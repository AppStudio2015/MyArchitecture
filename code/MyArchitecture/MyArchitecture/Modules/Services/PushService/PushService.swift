//
//  PushService.swift
// MyArchitecture
//
//  Created by qufei on 2019/6/5.
//  Copyright © 2019 AppStudio. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

//MARK: - 推送

fileprivate let ModuleName: String = "通知服务"

/// 推送
class RemotePushNotificationsManager: NSObject {
    
    static let share: RemotePushNotificationsManager = RemotePushNotificationsManager()
    
    private(set) var authorizationOptions: UNAuthorizationOptions = [UNAuthorizationOptions.alert, .badge, .sound, .carPlay]
    
    private override init() {
        super.init()
    }
    
    // MARK: - Public
    
    /// 注册推送
    public func registrationProcessWithAPNs() {
        let notifiCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
        notifiCenter.delegate = self
        
        // 查看设置
        notifiCenter.getNotificationSettings { (setting) in
            KLog(setting, module: ModuleName)
            if setting.authorizationStatus == .denied {
                // 可以让用户上上设置里设置推送
            }
        }
        
        // 申请授权
        var options: UNAuthorizationOptions = [UNAuthorizationOptions.alert, .badge, .sound, .carPlay]
        if #available(iOS 12.0, *) {
            options = [UNAuthorizationOptions.alert, .badge, .sound, .carPlay, .criticalAlert, .providesAppNotificationSettings/*, .provisional*/]
        }
        authorizationOptions = options
        
        notifiCenter.requestAuthorization(options: options) { (granted, error) in
            // 用户同意授权
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    /// 清空角标
    public func clearUpAllBadges() {
        assert(Thread.current == Thread.main, "Error:线程不正确")
        assert(authorizationOptions.contains(.badge), "Error:使用此功能需要设置badge")
        
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    /// 清除指定数量的角标
    ///
    /// - Parameter num: 指定数量
    public func clearUpBadges(_ num: Int) {
        assert(Thread.current == Thread.main, "Error:线程不正确")
        assert(authorizationOptions.contains(.badge), "Error:使用此功能需要设置badge")
        
        let originnum: Int = UIApplication.shared.applicationIconBadgeNumber
        let finalNum: Int = num <= originnum && num > 0 ? originnum - num : 0
        UIApplication.shared.applicationIconBadgeNumber = finalNum
    }
}

/// 本地通知
class LocalNotificationsManager: NSObject {
    
}

//MARK: - 扩展推送相关服务(AppDelegate相关)
extension AppDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceTokenString = deviceToken.hexString
        KLog(deviceTokenString, module: ModuleName)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        KLog(error, module: ModuleName)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        KLog(userInfo, module: ModuleName)
        completionHandler(.newData)
    }
}

//MARK: - UNUserNotificationCenterDelegate

extension RemotePushNotificationsManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        KLog(response, module: ModuleName)
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        KLog(notification, module: ModuleName)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        KLog(notification, module: ModuleName)
    }
}
