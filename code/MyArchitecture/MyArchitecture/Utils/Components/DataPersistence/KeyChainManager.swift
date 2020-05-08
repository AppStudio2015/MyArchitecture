//
//  KeyChainManager.swift
// MyArchitecture
//
//  Created by admin on 2020/3/16.
//  Copyright © 2020 AppStudio. All rights reserved.
//

import UIKit
import Foundation

// MARK: - KeychainPasswordItem

/// 钥匙串密码项
/// - 将密码保存到钥匙串中
struct KeychainPasswordItem {
    
    // MARK: Types
    
    /// KeychainError
    enum KeychainError: Error {
        case noPassword // 无密码
        case unexpectedPasswordData // 密码错误
        case unexpectedItemData // 数据错误
        case unhandledError(status: OSStatus) // 未知密码
    }
    
    // MARK: Properties
    
    /// 服务
    let service: String
    
    /// 账号（对外只读）
    private(set) var account: String
    
    /// 访问组
    let accessGroup: String?

    // MARK: Intialization
    
    init(service: String, account: String, accessGroup: String? = nil) {
        self.service = service
        self.account = account
        self.accessGroup = accessGroup
    }
    
    // MARK: Keychain access
    
    /// 读取密码
    /// - Throws: 异常
    /// - Returns: 密码
    func readPassword() throws -> String  {
        /*
            Build a query to find the item that matches the service, account and
            access group.
        */
        var query = KeychainPasswordItem.keychainQuery(withService: self.service, account: self.account, accessGroup: self.accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        
        // Try to fetch the existing keychain item that matches the query.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
//        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &queryResult)
        
        // Check the return status and throw an error if appropriate.
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        
        // Parse the password string from the query result.
        guard let existingItem = queryResult as? [String : AnyObject],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8)
        else {
            throw KeychainError.unexpectedPasswordData
        }
        
        return password
    }
    
    /// 保存密码
    /// - Parameter password: 密码串
    /// - Throws: 异常
    func savePassword(_ password: String) throws {
        // Encode the password into an Data object.
        let encodedPassword = password.data(using: String.Encoding.utf8)!
        
        do {
            // Check for an existing item in the keychain.
            try _ = readPassword()

            // Update the existing item with the new password.
            var attributesToUpdate = [String : AnyObject]()
            attributesToUpdate[kSecValueData as String] = encodedPassword as AnyObject?

            let query = KeychainPasswordItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            
            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        } catch KeychainError.noPassword {
            /*
                No password was found in the keychain. Create a dictionary to save
                as a new keychain item.
            */
            var newItem = KeychainPasswordItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            newItem[kSecValueData as String] = encodedPassword as AnyObject?
            
            // Add a the new item to the keychain.
            let status = SecItemAdd(newItem as CFDictionary, nil)
            
            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        }
    }
    
    /// 重命名账号
    /// - Parameter newAccountName: 新账号
    /// - Throws: 异常
    mutating func renameAccount(_ newAccountName: String) throws {
        // Try to update an existing item with the new account name.
        var attributesToUpdate = [String : AnyObject]()
        attributesToUpdate[kSecAttrAccount as String] = newAccountName as AnyObject?
        
        let query = KeychainPasswordItem.keychainQuery(withService: service, account: self.account, accessGroup: accessGroup)
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        
        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
        
        self.account = newAccountName
    }
    
    /// 删除
    /// - Throws: 异常
    func deleteItem() throws {
        // Delete the existing item from the keychain.
        let query = KeychainPasswordItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        let status = SecItemDelete(query as CFDictionary)
        
        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
    }
    
    /// 生成密码项
    /// - Parameters:
    ///   - service: 服务
    ///   - accessGroup: 访问组
    /// - Throws: 异常
    /// - Returns: 密码项
    static func passwordItems(forService service: String, accessGroup: String? = nil) throws -> [KeychainPasswordItem] {
        // Build a query for all items that match the service and access group.
        var query = KeychainPasswordItem.keychainQuery(withService: service, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitAll
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanFalse
        
        // Fetch matching items from the keychain.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        // If no items were found, return an empty array.
        guard status != errSecItemNotFound else { return [] }

        // Throw an error if an unexpected status was returned.
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        
        // Cast the query result to an array of dictionaries.
        guard let resultData = queryResult as? [[String : AnyObject]] else { throw KeychainError.unexpectedItemData }
        
        // Create a `KeychainPasswordItem` for each dictionary in the query result.
        var passwordItems = [KeychainPasswordItem]()
        for result in resultData {
            guard let account  = result[kSecAttrAccount as String] as? String else { throw KeychainError.unexpectedItemData }
            
            let passwordItem = KeychainPasswordItem(service: service, account: account, accessGroup: accessGroup)
            passwordItems.append(passwordItem)
        }
        
        return passwordItems
    }

    // MARK: Convenience
    
    /// 钥匙串查询
    /// - Parameters:
    ///   - service: 服务
    ///   - account: 账号
    ///   - accessGroup: 访问组
    /// - Returns: 查询字典
    private static func keychainQuery(withService service: String, account: String? = nil, accessGroup: String? = nil) -> [String : AnyObject] {
        var query = [String : AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?

        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject?
        }

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        return query
    }
}

// MARK: - KeyChainManager
class KeyChainManager: NSObject {
    let service: String = "TomTomMap"
    let account: String = "TomTomAccount"
    let password: String = "TomTomPassword"
    let accountGroup: String? = nil// "TomTomAccountGroup"
}

extension KeyChainManager {
    
    func testReadPassword() -> Void {
        let item = KeychainPasswordItem.init(service: self.service, account: self.account, accessGroup: self.accountGroup)
        do {
            let pass: String = try item.readPassword()
            if pass == password {
                print("Had password:\(pass)!")
            }
        } catch let error {
            fatalError("No password:\(error.localizedDescription)!")
        }
    }
    
    func testSavePassword() -> Void {
        let item = KeychainPasswordItem.init(service: self.service, account: self.account, accessGroup: self.accountGroup)
        do {
            try item.savePassword(self.password)
        } catch let error {
            fatalError("Save password failed:\(error.localizedDescription)!")
        }
    }
    
    func testDeletePassword() -> Void {
        let item = KeychainPasswordItem.init(service: self.service, account: self.account, accessGroup: self.accountGroup)
        do {
            try item.deleteItem()
        } catch let error {
            fatalError("Delete password failed:\(error.localizedDescription)!")
        }
    }
}
