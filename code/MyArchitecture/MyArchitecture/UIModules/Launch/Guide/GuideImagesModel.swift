//
//  GuideImagesModel.swift
// MyArchitecture
//
//  Created by admin on 2020/4/8.
//  Copyright © 2020 AppStudio. All rights reserved.
//

import UIKit

// MARK: - GuideImagesProtocol
fileprivate protocol GuideImagesProtocol {
    
    /// 引导页面数量
    var numberOfPages: Int {get}
    
    /// 屏幕分辨率
    var screenResolution: CGSize {get}
    
    /// 引导图片资源路径
    var bundlePath: String? {get}
    
    /// 引导图片集合
    var images: [UIImage] {get}
}

// MARK: - GuideImagesModel
public struct GuideImagesModel: GuideImagesProtocol {
    
    /// 引导页面数量：4
    var numberOfPages: Int {
        return 4
    }
    
    /// 当前屏幕分辨率
    var screenResolution: CGSize {
        let scale: CGFloat = UIScreen.main.scale
        let ratio: CGSize = CGSize.init(width: Int(UIScreen.width() * scale), height: Int(UIScreen.height() * scale))
        return ratio
    }
    
    /// 引导图资源路径：GuideImages.bundle
    var bundlePath: String? {
        return AppInfo.applicationBundle.path(forResource: "GuideImages", ofType: "bundle")
    }
    
    /// 引导图片集合
    var images: [UIImage] {
        var images: [UIImage] = [UIImage]()
        for index in 0..<self.numberOfPages {
            let image = self.guideImage(at: index)
            images.append(image)
        }
        
        return images
    }
    
    /// 生成引导图片
    /// - Parameter index: 索引
    /// - Returns: 引导图片
    private func guideImage(at index: Int) -> UIImage {
        guard let bundlePath = self.bundlePath else {
            return UIImage()
        }
        
        let imageFileName: String = "\(bundlePath)/\(Int(self.screenResolution.width))_\(Int(self.screenResolution.height))/guide_0\(index + 1)"
        
        guard let image: UIImage = UIImage.init(contentsOfFile: imageFileName) else {
            return UIImage()
        }
        
        return image
    }
}
