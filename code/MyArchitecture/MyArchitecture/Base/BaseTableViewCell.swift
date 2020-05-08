//
//  BaseTableViewCell.swift
// MyArchitecture
//
//  Created by QF on 2019/6/4.
//  Copyright © 2019 AppStudio. All rights reserved.
//

import UIKit

// MARK: - TableViewCellProtocl

/// UITableViewCell共通协议
protocol TableViewCellProtocl {
    /// 关联类型
    associatedtype CellData
    
    /// 更新Cell中的数据
    /// - Parameter data: 数据源
    func update(data: CellData) -> Void
}

extension TableViewCellProtocl {
    /// 更新
    /// - 此处实现相当于 Optional方法
    /// - Parameter data: 数据源
    func update(data: CellData) -> Void {
        print("This protocol func is optinal!")
    }
}

// MARK: - BaseTableViewCell
class BaseTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
