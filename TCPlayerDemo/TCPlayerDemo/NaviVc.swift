//
//  NaviVc.swift
//  TCPlayerDemo
//
//  Created by Tech on 2017/10/17.
//  Copyright © 2017年 ctc. All rights reserved.
//

import UIKit

class NaviVc: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return viewControllers.last?.supportedInterfaceOrientations ?? .portrait
    }

}
