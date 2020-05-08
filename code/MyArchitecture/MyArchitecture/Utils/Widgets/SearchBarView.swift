//
//  SearchBarView.swift
// MyArchitecture
//
//  Created by admin on 2020/3/23.
//  Copyright © 2020 AppStudio. All rights reserved.
//

import UIKit

class SearchBarView: BaseView {

    fileprivate lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar.init()
        if #available(iOS 13.0, *) {
            searchBar.overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = UIColor.clear
        searchBar.showsScopeBar = false
        searchBar.isTranslucent = true
        searchBar.tintColor = UIColor.white
        searchBar.placeholder = NSLocalizedString("searchBarPlacehoder", comment: "")
        return searchBar
    }()
    
    fileprivate lazy var userButton: UIButton = {
        let button: UIButton = UIButton.init(type: .custom)
        button.setImage(UIImage(named: "user"), for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        self.addSubview(self.userButton)
        self.addSubview(self.searchBar)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        let margin: CGFloat = 4
        let userBtnH: CGFloat = self.frame.height - margin * 2
        let userBtnW: CGFloat = userBtnH
        self.userButton.frame = CGRect(x: margin, y: margin, width: userBtnW, height: userBtnH)
        
        let searhcBarX: CGFloat = self.userButton.frame.maxX + margin
        let searchBarW: CGFloat = self.frame.width - searhcBarX - margin;
        let searchBarH: CGFloat = userBtnH
        self.searchBar.frame = CGRect(x: searhcBarX, y: margin, width: searchBarW, height: searchBarH)
    }
}

// MARK: - Private Methods
extension SearchBarView {
    
}

// MARK: - Public Methods
extension SearchBarView {
    
}

// MARK: - Target Actions
extension SearchBarView {
    
    fileprivate func handleUserButton(_ button: UIButton) -> Void {
        
    }
}

// MARK: - Delegates
extension SearchBarView: UISearchBarDelegate {
    
}
