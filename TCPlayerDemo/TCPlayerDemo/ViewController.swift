//
//  ViewController.swift
//  TCPlayer_swift
//
//  Created by Tech on 2017/5/26.
//  Copyright © 2017年 ctc. All rights reserved.
//

import UIKit
import AVFoundation

let test_live = "http://pl-hls11.live.panda.tv/live_panda/d773d6c71b8310e68a4d4c45c66c0b4d_small.m3u8"
let test_url1 =  "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"
let test_url2 = "http://pl-ali.youku.com/playlist/m3u8?vid=XMjc4MTYwODI2OA==&sid=049077601582712e5c7c0&ctype=12&ts=1490776017&type=hd3"
let test_url3 = "http://101.227.216.142/vcloud1026.tc.qq.com/1026_028e3447c219459087df0064e29751bd.f0.mp4?vkey=BC8597116B9A2A491A785B3CAAD337F224B23EE5DADD9910B4544451EF8DAE27040330626D21C06BB2AAEF7A3B2BA271CDED1AC6746DCECF6A2D433BBE4140674CA4A8920C6E82522ABFAE69CA5A67F6AA2A9750E1BFCB65&sha=1b9225451824f7492aeb80316abfec0c78c12728"
let test_url4 = "http://ac-i6ivdmqk.clouddn.com/2aab83d40181512112a4.mp3"
let test_url5 = "http://pl-ali.youku.com/playlist/m3u8?vid=XMjQ4MTMxNjk4MA==&sid=049077601582712e5c7c0&ctype=12&ts=1490776017&type=mp4"

class ViewController: UIViewController,TCPlayerDelegate {
    
    @IBOutlet weak var iv: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playPercentLbl: UILabel!
    @IBOutlet weak var bufferedPercentLbl: UILabel!
    @IBOutlet weak var playLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var pv: UIProgressView!
    @IBOutlet weak var player: TCPlayer!
    
    var gif = [UIImage]()
    
    @IBOutlet weak var pv2: UIProgressView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        player.delegate = self
        player.play(test_url1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(player.constraints)
    }
    
    func reset() {
        pv.setProgress(0, animated: false)
        pv2.setProgress(0, animated: false)
        slider.setValue(0, animated: false)
        playPercentLbl.text = "0.00%"
        bufferedPercentLbl.text = "0.00%"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        player.stopRecordingGif()
    }
    
    @IBAction func changeA(_ sender: Any) {
        reset()
        player.play(test_url1)
    }
    
    @IBAction func changeB(_ sender: Any) {
        reset()
        player.play(test_url2)
    }
    
    @IBAction func replay(_ sender: Any) {
        player.replay()
    }
    
    @IBAction func refresh(_ sender: Any) {
        reset()
        player.refresh()
    }
    
    @IBAction func play(_ sender: UIButton) {
        player.play()
    }
    
    @IBAction func getImg(_ sender: Any) {
        player.screenshot { (image) in
            if image != nil {
                self.iv.image = image
            }
        }
    }
    
    @IBAction func gifMaker(_ sender: UIButton) {
        
        //        if sender.isSelected {
        //            return
        //        }
        //        sender.isSelected = true
        //        gif.removeAll()
        //
        //        player.screenshots({ (imgs) in
        //            self.iv.animationImages = imgs
        //            self.iv.animationDuration = 3
        //            self.iv.startAnimating()
        //            sender.isSelected = false
        //        })
        
        
        
        //        Timer.scheduledTimer(withTimeInterval: 1/24, repeats: true, block: { [weak self] timer in
        //            debugPrint("get a new gif")
        //            let img = self?.player.screenshot()
        //
        //
        //
        //
        //
        //            self?.gif.append(img!)
        //            if self?.gif.count == 24*3 {
        //                self?.iv.animationImages = self?.gif
        //                self?.iv.animationDuration = 3
        //                self?.iv.startAnimating()
        //                sender.isSelected = false
        //                timer.invalidate()
        //            }
        //            if self == nil {
        //                timer.invalidate()
        //            }
        //        }).fire()
    }
    
    @IBAction func startGif(_ sender: UIButton) {
//        player.startRecordingGif()
    }
    
    @IBAction func cancelGif(_ sender: UIButton) {
//        player.cancelRecordingGif()
    }
    
    @IBAction func stopGif(_ sender: UIButton) {
//        player.stopRecordingGif { (image) in
//            if image != nil {
//                self.iv.image = image
//            }
//        }
    }
    
    var index = 0
    
    @IBAction func pause(_ sender: UIButton) {
        player.pause()
    }
    
    @IBAction func videoSliderChangeValue(_ sender: UISlider) {
        print(sender.value)
        player.play(atPercent: CGFloat(sender.value))
        //        iv.image = player.screenshot(sender.value)
    }
    
    @IBAction func zoom(_ sender: Any) {
        if UIDevice.current.orientation == .portrait {
            player.turn(.landscapeRight)
        } else {
            player.turn(.portrait)
        }
    }
    
    @IBAction func pop(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    deinit {
        debugPrint(self.classForCoder)
    }
    
    func timeFormatter(_ second: CGFloat) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(second))
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: +0)
        if second/3600 >= 1 {
            formatter.dateFormat = "HH:mm:ss"
        } else {
            formatter.dateFormat = "mm:ss"
        }
        return formatter.string(from: date)
    }
    
    
    // MARK: TCPlayerDelegate
    func player(_ player: TCPlayer!, didBuffer buffer: CGFloat) {
        pv.setProgress(Float(buffer), animated: true)
        bufferedPercentLbl.text = String(format: "%.2f%%", buffer*100)
    }
    
    func player(_ player: TCPlayer!, didGetDuration duration: CGFloat) {
        totalLbl.text = timeFormatter(duration)
    }
    
    func player(_ player: TCPlayer!, didPlay progress: CGFloat, current: CGFloat) {
        playLbl.text = timeFormatter(current)
        pv2.setProgress(Float(progress), animated: true)
        playPercentLbl.text = String(format: "%.2f%%", progress*100)
        slider.setValue(Float(progress), animated: true)
    }
    
}

