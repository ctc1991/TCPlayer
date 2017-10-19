//
//  VcWithUI.swift
//  TCPlayer_swift
//
//  Created by Tech on 2017/5/31.
//  Copyright © 2017年 ctc. All rights reserved.
//

import UIKit

class VcWithUI: UIViewController {

    @IBOutlet weak var player: TCPlayer!

    
    var playerView: TCPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        player.play(test_url1)
        
        
        playerView = TCPlayerView()
        playerView.player = player
        player.addFillSubview(playerView)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    deinit {
        debugPrint(self.classForCoder, "从内存中移除")
    }

}
