// 用于管理本地化/国际化切换

import Foundation

fileprivate let kUserLanguage: String = "kUserLanguage"

/// 本地化/国际化处理
class LocalizableManager: NSObject {
    
    static let share: LocalizableManager = LocalizableManager()
    
    fileprivate(set) var bundle: Bundle?
    var currentLanguage: String? {
        set {
            guard let currentLanguage = newValue else { return }
            
            let userDefault = UserDefaults.standard
            if let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj") {
                bundle = Bundle(path: path)
            }
            
            userDefault.setValue(currentLanguage, forKey: kUserLanguage)
            userDefault.synchronize()
        }
        
        get {
            // 用户使用的语言
            var userLanguage: String? = UserDefaults.standard.object(forKey: kUserLanguage) as? String
            // 用户未手动设置过语言
            if userLanguage?.isEmpty == true {
                let systemLanguage = Bundle.main.preferredLocalizations.first
                userLanguage = systemLanguage
            }
            
            return userLanguage
        }
    }
    
    private override init() {
        super.init()
        initData()
    }
    
    
    fileprivate func initData() {
        if bundle == nil {
            // 用户使用的语言
            var userLanguage: String? = UserDefaults.standard.object(forKey: kUserLanguage) as? String
             // 用户未手动设置过语言
            if userLanguage == nil || userLanguage?.isEmpty == true {
                let systemLanguage = Bundle.main.preferredLocalizations.first
                userLanguage = systemLanguage
            }
            
            // 应用暂不支持繁体
            if userLanguage == "zh-HK" || userLanguage == "zh-TW" {
                userLanguage = "zh-Hant"
            }
            
            if let path = Bundle.main.path(forResource: userLanguage, ofType: "lproj") {
                bundle = Bundle(path: path)
            }
        }
    }
    
    // MARK: - Public
    
    /// 获取本地化的文字
    ///
    /// - Parameters:
    ///   - key: 本地化的key
    ///   - value: 默认值
    ///   - comment: 对key的描述
    ///   - tbl: 本地化的文件(要使用自定义的strings文件需要设置bundle)
    /// - Returns: 本地化后的z文字
    public func string(withKey key: String, value: String = "", comment: String = "", tbl: String = "Localizable") -> String {
        if let bundle = bundle {
            return NSLocalizedString(key, tableName: tbl, bundle: bundle, value: value, comment: comment)
        } else {
            return NSLocalizedString(key, comment: comment)
        }
    }
    
}
