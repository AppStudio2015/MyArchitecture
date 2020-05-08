//
//  GlobalFunction.swift
// MyArchitecture
//
//  Created by qufei on 2019/6/5.
//  Copyright © 2019 AppStudio. All rights reserved.
//

import Foundation

//MARK: - LocalizableManager（本地化/国际化）
// 此部分参见String

//MARK: - NSLog

/// 打印
///
/// - Parameters:
///   - message: 要打印的信息
///   - module: 模块名称
///   - subModule: 子模块
func KLog<T>(_ message: T, module: String? = nil, subModule: String? = nil,
             file: String = #file, function: String = #function, lineNumber: Int = #line) {
    #if DEBUG
    let fileName = (file as NSString).lastPathComponent
    
    var moduleName: String = "\(module ?? "")"
    if !moduleName.isEmpty {
        moduleName = "【" + moduleName + "】"
    }
    
    var subModuleName: String = "\(subModule ?? "")"
    if !subModuleName.isEmpty {
        subModuleName = "【" + subModuleName + "】"
    }
    
    print("【\(fileName)-\(function)-\(lineNumber)】\n\(moduleName)\(subModuleName)\(message)\n")
    #endif
}

/// 打印数据调用处
///
/// - Parameters:
///   - module: 模块名称
///   - subModule: 子模块名称
func KLogCallPlace(_ module: String? = nil, subModule: String? = nil,
                   file: String = #file, function: String = #function, lineNumber: Int = #line) {
    #if DEBUG
    let fileName = (file as NSString).lastPathComponent
    var moduleName: String = "\(module ?? "")"
    if !moduleName.isEmpty {
        moduleName = "【" + moduleName + "】"
    }
    
    var subModuleName: String = "\(subModule ?? "")"
    if !subModuleName.isEmpty {
        subModuleName = "【" + subModuleName + "】"
    }
    print("【\(fileName)-\(function)-\(lineNumber)】\n\(moduleName)\(subModuleName)\n")
    #endif
}

/// 比较版本
///
/// - Parameters:
///   - localVersion: 本地版本
///   - storeVersion: 商店版本
/// - Returns: 是否需要更新
func compareVersion(localVersion: String?, storeVersion: String?) -> Bool {
    guard let _localVersion = localVersion else {  return false }
    guard let _storeVersion = storeVersion else {  return false }
    
    // 比较版本
    let lv = _localVersion.components(separatedBy: ".")
    let sv = _storeVersion.components(separatedBy: ".")
    
    var result: Bool = false
    let smallCount = lv.count > sv.count ? sv.count : lv.count
    for index in 0 ..< smallCount {
        let lv_str = lv[index]
        let sv_str = sv[index]
        
        let lv_int: Int = Int(lv_str) ?? 0
        let sv_int: Int = Int(sv_str) ?? 0
        if sv_int > lv_int { // 服务器提示版本 大于 本地版本
            result = true
            break
        } else if lv_int > sv_int {// 本地版本 大于 服务器提示版本
            result = false
            break
        } else {// 版本相同，继续比较下一位
            continue
        }
    }
    
    // 有一方字段少
    if result == false, sv.count > lv.count {
        result = true
    }
    
    return result
}
