//
//  NetworkingUtils.swift
// MyArchitecture
//
//  Created by QF on 2020/1/15.
//  Copyright © 2020 AppStudio. All rights reserved.
//

import UIKit

class NetworkingUtils {
    /// 拼接请求参数
    /// - Parameter dictionary: 参数字典
    /// - Returns: 请求参数
    @objc class func buildRequestParameters(with dictionary: [String: Any]) -> String? {
        var paramStr: String? = nil
        if dictionary.isEmpty { return nil }
        for (key, value) in dictionary {
            if paramStr == nil {
                paramStr = "\(key)=\(value)"
            } else {
                paramStr = paramStr! + "&" + "\(key)=\(value)"
            }
        }
        return paramStr
    }
    
    /// 创建HTTPBODY
    ///
    /// - Parameter dictionary: 参数字典
    /// - Returns: Body数据
    @objc class func buildHttpBody(with dictionary: [String: Any]) -> Data? {
        guard let paramStr: String = NetworkingUtils.buildRequestParameters(with: dictionary) else {
            return nil
        }
        
        print("parameters:\(paramStr)")
        return paramStr.data(using: String.Encoding.utf8, allowLossyConversion: true)!
    }
}

extension JSONEncoder {
    /// 将模型转换成json类型的data
    ///
    /// - Parameters:
    ///   - value: The value to encode as JSON.
    ///   - outputFormatting: 输出的JSON格式
    /// - Returns: Returns a JSON-encoded representation of the value you supply.
    static func encode<T>(_ value: T,
                          outputFormatting: JSONEncoder.OutputFormatting? = nil) -> Data? where T : Encodable {
        
        let encoder = JSONEncoder()
        if let outputFormatting = outputFormatting {
            encoder.outputFormatting = outputFormatting
        }
        
        var data: Data
        
        do {
            data = try encoder.encode(value)
        } catch let error {
            NSLog("error :\(error)")
            return nil
        }
        
        return data
    }
    
    /// 模型 转 字典
    ///
    /// - Parameter model: 遵守Encodable协议的模型
    /// - Returns: 字典
    static func encoder<T>(toDictionary model : T) -> [String : Any]? where T: Encodable {
        
        guard let data = JSONEncoder.encode(model) else { return nil }
        
        guard let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String:Any] else {
            
            return nil
        }
        
        return dict
    }
}

extension JSONDecoder {
    /// 将符合json形式的data解码成模型
    ///
    /// - Parameters:
    ///   - type: The type of the value to decode from the supplied JSON object.
    ///   - data: The JSON object to decode.
    /// - Returns: Returns a value of the type you specify, decoded from a JSON object. If the data is not valid JSON, this method throws the dataCorrupted error. If a value within the JSON fails to decode, this method throws the corresponding error.
    static func decode<T>(_ type: T.Type, from data: Data)  -> T? where T : Decodable {
        let decoder = JSONDecoder()
        
        var decodedModel: T
        
        do {
            decodedModel = try decoder.decode(T.self, from: data)
        } catch let error {
            NSLog("error :\(error)")
            return nil
        }
        return decodedModel
    }
    
    static func decode<T>(_ type: T.Type, param: [String:Any]) ->T? where T: Decodable {
        
        guard let jsonData = self.getJsonData(with: param) else { return nil }
        
        guard let model = JSONDecoder.decode(type, from: jsonData) else { return nil }
        
        return model
    }
    
    //多个
    public static func decode<T>(_type: T.Type, array: [[String:Any]]) -> [T]? where T: Decodable {
        
        if let data = self.getJsonData(with: array) {
            if let models = JSONDecoder.decode([T].self, from: data) { return models }
        } else {
            NSLog("模型转换->转换data失败")
        }
        
        return nil
    }
    
    private static func getJsonData(with param:Any) -> Data? {
        
        if !JSONSerialization.isValidJSONObject(param) { return nil }
        
        guard let data = try?JSONSerialization.data(withJSONObject: param, options: []) else {
            return nil
        }
        
        return data
    }
}

extension JSONSerialization {
    
    /// 将符合json格式的数据转换成json字符串
    ///
    /// - Parameters:
    ///   - obj: The object from which to generate JSON data. Must not be nil
    ///   - opt: Options for creating the JSON data. @See JSONSerialization.WritingOptions for possible values.
    /// - Returns: json字符串
    @objc class func jsonString(withJSONObject obj: Any, options opt: JSONSerialization.WritingOptions = [],
                    file: String = #file, fuction: String = #function, line: Int = #line) -> String? {
        do {
            let data = try JSONSerialization.data(withJSONObject: obj, options: opt)
            let string = String(data: data, encoding: String.Encoding.utf8)
            return string
        } catch let error {
            NSLog("\(file)--\(fuction)---\(line) \n 【error1: \(error)】")
            return nil
        }
    }
    
    class func jsonObject<T>(with data: Data, type: T.Type, options opt: JSONSerialization.ReadingOptions = [],
                             file: String = #file, fuction: String = #function, line: Int = #line) -> T? {
        do {
            if let jsonObj: T = try JSONSerialization.jsonObject(with: data, options: opt) as? T {
                return jsonObj
            }
            
            NSLog("\(file)--\(fuction)---\(line) \n 【error: 转换失败】")
            return nil
        } catch let error {
            NSLog("\(file)--\(fuction)---\(line) \n 【error2: \(error)】")
            return nil
        }
    }
    
    class func myJsonObject(with data: Data, options opt: JSONSerialization.ReadingOptions = [],
                             file: String = #file, fuction: String = #function, line: Int = #line) -> NSDictionary? {
        do {
            let jsonObj = try JSONSerialization.jsonObject(with: data, options: opt)
            
            if let _jsonObj: NSDictionary = jsonObj as? NSDictionary {
                NSLog("_jsonObj = \(_jsonObj)")
                return _jsonObj
            }
            
            NSLog("\(file)--\(fuction)---\(line) \n 【error: 转换失败】")
            return nil
        } catch let error {
            NSLog("\(file)--\(fuction)---\(line) \n 【error2: \(error)】")
            return nil
        }
    }
}
