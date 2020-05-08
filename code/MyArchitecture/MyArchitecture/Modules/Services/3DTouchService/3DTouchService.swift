//
//  3DTouchService.swift
// MyArchitecture
//
//  Created by qufei on 2019/6/10.
//  Copyright © 2019 AppStudio. All rights reserved.
//

import Foundation
import UIKit

fileprivate let ModuleName: String = "3DTouch服务"

fileprivate let shortcutItemType_home: String = "com.shortcut.gohome"

enum ShortcutItemType: String {
    case home = "com.shortcut.gohome"
    case company = "com.shortcut.gocompany"
}

/// 3DTouch
class ThreeDTouchService: NSObject {
    
    /// 动态添加3DTouch服务
    static func register3DTouch() {
        let appDelegate = UIApplication.shared
        var shortcutItems: [UIApplicationShortcutItem] = []
        
        let shortcut_icon_home = UIApplicationShortcutIcon(type: .home)
        let shortcut_item_home = UIApplicationShortcutItem(type: ShortcutItemType.home.rawValue, localizedTitle: "回家",
                                                           localizedSubtitle: nil, icon: shortcut_icon_home, userInfo: nil)
        let shortcut_icon_company = UIApplicationShortcutIcon(type: .location)
        let shortcut_item_company = UIApplicationShortcutItem(type: ShortcutItemType.company.rawValue, localizedTitle: "去公司",
                                                              localizedSubtitle: nil, icon: shortcut_icon_company, userInfo: nil)
        shortcutItems.append(shortcut_item_home)
        shortcutItems.append(shortcut_item_company)
        appDelegate.shortcutItems = shortcutItems
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        KLog(shortcutItem, module: ModuleName)
        
        if shortcutItem.type == ShortcutItemType.home.rawValue {
            
        } else if shortcutItem.type == ShortcutItemType.home.rawValue {
            
        }
    }
}
