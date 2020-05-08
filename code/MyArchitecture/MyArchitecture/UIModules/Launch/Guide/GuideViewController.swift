//
//  GuideViewController.swift
// MyArchitecture
//
//  Created by QF on 2019/6/4.
//  Copyright © 2019 AppStudio. All rights reserved.
//

import UIKit

/// 引导视图控制器
class GuideViewController: BaseViewController {
    // MARK: - Private Properties
    private lazy var guideView: GuideView = {
        let view = GuideView.init(frame: UIScreen.main.bounds)
        
        return view
    }()
    
    // MARK: - Public Properties
    
    // MARK: - Initialization
    
    // MARK: - Override Methods
    
    override func loadView() {
        super.loadView()
        self.view = self.guideView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
