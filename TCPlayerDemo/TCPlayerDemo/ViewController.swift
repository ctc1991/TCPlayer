//
//  ViewController.swift
//  TCPlayerDemo
//
//  Created by Tech on 2017/10/10.
//  Copyright © 2017年 ctc. All rights reserved.
//

import UIKit

let url = "http://7xpk28.com1.z0.glb.clouddn.com/%5BONE%20PUNCH%20MAN%5D%5B720P%5D-10.mp4"
let url2 = "http://dl.weshineapp.com/gif/20170928/88e0a3126feedb6b11aa6e6385e76650.mp4"
let url3 = "http://pl-ali.youku.com/playlist/m3u8?vid=XMzA0MTcyMzAwNA==&sid=049077601582712e5c7c0&ctype=12&ts=1490776017&type=hd"
let url4 = "http://static.cheshipin.tv/lgKceJY6i9lmItgZH-h4jspX4wVA"
let url5 = "http://pl-hls8.live.panda.tv/live_panda/92d768563027d708b0cb81793d93b3bf_small.m3u8"
let xxx = "https://cdn2e-videos2.yjcontentdelivery.com/5/8/58d9aa188577cd0dbe0dde38691c08c31490671223-640-360-600-h264.mp4?validfrom=1507566733&validto=1507739533&rate=115200&hash=%2Fpsv10DpBYmclw0e0wDa7kJ8rUU%3D"

class ViewController: UIViewController,TCPlayerDelegate,UITextFieldDelegate {

    @IBOutlet weak var player: TCPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player.backgroundColor = UIColor.black
        player.play(url4)
        player.delegate = self
        let playerView = TCPlayerView()
        player.addSubview(playerView)
    }
    
    @IBAction func play(_ sender: UIButton) {
        player.play()
    }
    
    @IBAction func pause(_ sender: UIButton) {
        player.pause()
    }

    @IBAction func replay(_ sender: UIButton) {
        player.replay()
        player.frame = CGRect(x: 0, y: 0, width: 375, height: 375)
        player.layer.frame = CGRect(x: 0, y: 0, width: 200, height: 375)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    // MARK: TCPlayerDelegate
    func player(_ player: TCPlayer!, didBuffer buffer: CGFloat) {
        print("buffer:\(buffer)")
    }
    
    func player(_ player: TCPlayer!, didGetDuration duration: CGFloat) {
        print("duration:\(duration)")
    }
    
    func player(_ player: TCPlayer!, didPlay progress: CGFloat, current: CGFloat) {
        print("progress:\(progress) current:\(current)")
    }
    
    func player(_ player: TCPlayer!, willJumpProgress progress: CGFloat) {
        print("willJumpProgress:\(progress)")
    }
    
    func player(_ player: TCPlayer!, didJumpProgress progress: CGFloat) {
        print("didJumpProgress:\(progress)")
    }
    
    
}

