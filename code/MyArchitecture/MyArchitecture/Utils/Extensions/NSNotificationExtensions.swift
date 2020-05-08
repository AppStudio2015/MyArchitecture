//
//  NSNotificationExtensions.swift
//  MyApp
//
//  Created by QF on 2018/11/4.
//  Copyright © 2018 AppStudio. All rights reserved.
//

import UIKit

extension NSNotification.Name {
    public static let UserInfoKeyHasSyncableAccount = Notification.Name("UserInfoKeyHasSyncableAccount")
    
    /// 拖动面板移动到顶部
    public static let PannelContainerMoveToTop = Notification.Name("PannelContainerMoveToTop")
    
    /// 拖动面板移动到中间
    public static let PannelContainerMoveToMiddle = Notification.Name("PannelContainerMoveToMiddle")
    
    /// 拖动面板移动到底部
    public static let PannelContainerMoveToBottom = Notification.Name("PannelContainerMoveToBottom")
}
