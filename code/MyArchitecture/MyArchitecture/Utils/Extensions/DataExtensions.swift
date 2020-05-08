//
//  DataExtensions.swift
// MyArchitecture
//
//  Created by qufei on 2019/6/5.
//  Copyright © 2019 AppStudio. All rights reserved.
//

import Foundation

//MARK: - 对Data类型进行扩展
extension Data {
    /// 将Data转换为String（小写字符）
    var hexString: String {
        return self.map { String(format: "%02hhx", $0) } .reduce("", {$0 + $1})
    }
    
    /// 将Data转换为String（大写字符）
    var hexCapitalString: String {
        return self.map { String(format: "%02hhX", $0) } .reduce("", {$0 + $1})
    }
}
