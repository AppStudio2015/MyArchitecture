//
//  StringExtensions.swift
// MyArchitecture
//
//  Created by qufei on 2019/6/24.
//  Copyright © 2019 AppStudio. All rights reserved.
//

import Foundation

// MARK: - LocalizableManager
extension String {
    /// 通用的本地化处理（读取记录在Localizable.strings文件的本地化值）
    var localizable: String {
        return LocalizableManager.share.string(withKey: self)
    }
    
    /// 个人本地化处理（读取记录在CustomString.strings文件的本地化值）
    var pmLocalizable: String {
        return LocalizableManager.share.string(withKey: self, tbl: "CustomString")
    }
}
