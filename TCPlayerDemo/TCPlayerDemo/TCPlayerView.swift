//
//  TCPlayerView.swift
//  TCPlayer_swift
//
//  Created by ctc on 2017/5/31.
//  Copyright © 2017年 ctc. All rights reserved.
//

import UIKit

enum TCGradientDirection {
    case toDown, toUp
}

class TCPlayerView: UIView, TCPlayerDelegate {
    
    lazy var tapGr: UITapGestureRecognizer = {
        let gr = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        gr.require(toFail: self.doubleTapGr)
        return gr
    }()
    
    lazy var doubleTapGr: UITapGestureRecognizer = {
        let gr = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction))
        gr.numberOfTapsRequired = 2
        return gr
    }()
    
    func tapAction() {
        isShow ? hide() : show()
    }
    
    func doubleTapAction() {
        if player.isPlaying {
            player.pause()
        } else {
            player.play()
            hide(3)
        }
    }
    
    weak var player: TCPlayer! {
        didSet {
            player.delegate = self
        }
    }
    
    var top: UIView!
    var topBg: UIView!
    var topBgLayer: CALayer!
    
    
    
    var bot: UIView!
    var botBg: UIView!
    var botBgLayer: CALayer!
    
    var side: UIView!
    
    
    var coverMaskView: UIVisualEffectView!
    var coverIv: UIImageView!
    
    var backBtn: UIButton!
    var moreBtn: UIButton!
    var titleLbl: UILabel!
    var bigPlayBtn: UIButton!
    var playBtn: UIButton!
    var zoomBtn: UIButton!
    var currentLbl: UILabel!
    var totalLbl: UILabel!
    
    var hasFirstTapped = false
    var isShow: Bool {
        get {
            return bot.alpha == 1
        }
    }
    var progressView: UIProgressView!
    var botProgressView: UIProgressView!
    var progressSlider: UISlider!
    
    
    init() {
        super.init(frame: CGRect())
        UIApplication.shared.statusBarStyle = .lightContent
        backgroundColor = UIColor.clear
        clipsToBounds = true
        
        addGestureRecognizer(doubleTapGr)
        addGestureRecognizer(tapGr)
        
        top = UIView()
        addSubview(top)
        
        topBg = UIView()
        top.addSubview(topBg)
        
        topBgLayer = gradientLayer(direction: .toDown, fromColor: UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.5), toColor: UIColor.clear)
        topBg.layer.addSublayer(topBgLayer)
        
        bot = UIView()
        addSubview(bot)
        
        botBg = UIView()
        bot.addSubview(botBg)
        
        botBgLayer = gradientLayer(direction: .toUp, fromColor: UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.5), toColor: UIColor.clear)
        botBg.layer.addSublayer(botBgLayer)
        
        
        
        
        
        //        NotificationCenter.default.addObserver(forName: NSNotification.Name.TCPlayerDidPlay, object: nil, queue: nil, using: { [weak self] notification in
        //            self?.updatePlayBtn()
        //        })
        //        NotificationCenter.default.addObserver(forName: NSNotification.Name.TCPlayerDidPause, object: nil, queue: nil, using: { [weak self] notification in
        //            self?.updatePlayBtn()
        //        })
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIDeviceOrientationDidChange, object: nil, queue: nil, using: { [weak self] notification in
            debugPrint(UIDevice.current.orientation.rawValue)
            self?.player.setNeedsDisplay()
        })
        
        coverIv = UIImageView()
        coverIv.image = UIImage(named: "IMG_4629")
        coverIv.contentMode = .scaleAspectFill
        coverIv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playVideo)))
        coverIv.isUserInteractionEnabled = true
        addSubview(coverIv)
        
        
        coverMaskView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        coverMaskView.alpha = 0.9
        coverIv.addSubview(coverMaskView)
        
        backBtn = UIButton()
        backBtn.setImage(UIImage(named: "common_backShadow"), for: .normal)
        backBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backAction)))
        top.addSubview(backBtn)
        
        moreBtn = UIButton()
        moreBtn.setImage(UIImage(named: "misc_more_btn"), for: .normal)
        top.addSubview(moreBtn)
        
        titleLbl = UILabel()
        titleLbl.text = "dsadasd"
        titleLbl.textAlignment = .center
        titleLbl.font = UIFont.systemFont(ofSize: 16)
        titleLbl.textColor = UIColor.white
        top.addSubview(titleLbl)
        
        bigPlayBtn = UIButton(type: .custom)
        bigPlayBtn.setImage(UIImage(named: "player_bili_play_ico"), for: .normal)
        //        bigPlay.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
        bigPlayBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playVideo)))
        addSubview(bigPlayBtn)
        
        playBtn = UIButton()
        playBtn.setImage(UIImage(named: "player_play_bottom_window"), for: .normal)
        //        play.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
        playBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playVideo)))
        bot.addSubview(playBtn)
        
        zoomBtn = UIButton()
        zoomBtn.setImage(UIImage(named: "player_fullScreen_iphone"), for: .normal)
        zoomBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomAction)))
        bot.addSubview(zoomBtn)
        
        currentLbl = UILabel()
        currentLbl.text = "00:00"
        currentLbl.textAlignment = .center
        currentLbl.font = UIFont.systemFont(ofSize: 14)
        currentLbl.textColor = UIColor.white
        bot.addSubview(currentLbl)
        
        totalLbl = UILabel()
        totalLbl.text = "00:00"
        totalLbl.textAlignment = .center
        totalLbl.font = UIFont.systemFont(ofSize: 14)
        totalLbl.textColor = UIColor.white
        bot.addSubview(totalLbl)
        
        botProgressView = UIProgressView()
        botProgressView.progressTintColor = UIColor(colorLiteralRed: 247/255, green: 112/255, blue: 151/255, alpha: 1.0)
        botProgressView.setProgress(0, animated: false)
        botProgressView.alpha = 0
        addSubview(botProgressView)
        
        progressView = UIProgressView()
        progressView.progressTintColor = UIColor(colorLiteralRed: 247/255, green: 112/255, blue: 151/255, alpha: 1.0)
        progressView.setProgress(0, animated: false)
        bot.addSubview(progressView)
        
        progressSlider = UISlider()
        progressSlider.maximumTrackTintColor = UIColor.clear
        progressSlider.minimumTrackTintColor = UIColor(colorLiteralRed: 247/255, green: 112/255, blue: 151/255, alpha: 1.0)
        progressSlider.isContinuous          = false
        progressSlider.addTarget(self, action: #selector(videoSliderChangeValue), for: .valueChanged)
        progressSlider.setThumbImage(UIImage(named: "player_img_slider"), for: .normal)
        bot.addSubview(progressSlider)
        
        addSubview(top)
        
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        top.frame = CGRect(x: 0, y: 0, width: rect.width, height: 60)
        topBg.frame = top.bounds
        topBgLayer.frame = topBg.bounds
        
        bot.frame = CGRect(x: 0, y: rect.height-40, width: rect.width, height: 40)
        botBg.frame = bot.bounds
        botBgLayer.frame = botBg.bounds
        
        
        
        
        coverIv.frame = rect
        coverMaskView.frame = rect
        botProgressView.frame = CGRect(x: 0, y: rect.height-2, width: rect.width, height: 2)
        botProgressView.isHidden = UIDevice.current.orientation != .portrait
        bigPlayBtn.frame = CGRect(x: rect.width - 100, y: rect.height - 80 - (hasFirstTapped ? 30 : 0), width: 80, height: 80)
        bigPlayBtn.sizeToFit()
        // top
        backBtn.frame = CGRect(x: 0, y: 20, width: 60, height: 40)
        moreBtn.frame = CGRect(x: rect.width - 60, y: 20, width: 60, height: 40)
        titleLbl.frame = CGRect(x: 60, y: 20, width: rect.width - 120, height: 40)
        titleLbl.textAlignment = hasFirstTapped ? .left : .center
        // bot
        playBtn.frame = CGRect(x: 0, y: 0, width: 50, height: 40)
        zoomBtn.frame = CGRect(x: rect.width - 50, y: 0, width: 50, height: 40)
        currentLbl.frame = CGRect(x: 50 - 8, y: 0, width: 50, height: 40)
        totalLbl.frame = CGRect(x: rect.width - 100 + 8, y: 0, width: 50, height: 40)
        progressView.frame = CGRect(x: 100, y: 19, width: rect.width - 200, height: 2)
        progressSlider.frame = CGRect(x: 100-2, y: 19, width: rect.width - 200+4, height: 2)
        
    }
    
    func gradientLayer(direction: TCGradientDirection, fromColor: UIColor, toColor: UIColor) -> CALayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [fromColor.cgColor, toColor.cgColor]
        var sp = CGPoint()
        var ep = CGPoint()
        switch direction {
        case .toDown:
            sp = CGPoint(x: 0, y: 0)
            ep = CGPoint(x: 0, y: 1.0)
        case .toUp:
            sp = CGPoint(x: 0, y: 1.0)
            ep = CGPoint(x: 0, y: 0)
        }
        gradientLayer.startPoint = sp
        gradientLayer.endPoint = ep
        return gradientLayer
    }
    
    func backAction() {
        if UIDevice.current.orientation == .portrait {
            let vc = UIApplication.shared.keyWindow?.rootViewController
            if vc == nil {
                return
            } else if vc is UITabBarController {
                let navi = (vc as! UITabBarController).viewControllers?[(vc as! UITabBarController).selectedIndex]
                if navi is UINavigationController {
                    (navi as! UINavigationController).popViewController(animated: true)
                }
            } else if vc is UINavigationController {
                (vc as! UINavigationController).popViewController(animated: true)
            }
        } else {
            zoomAction()
        }
    }
    
    func videoSliderChangeValue(_ sender: UISlider) {
        player.play(atPercent: CGFloat(sender.value))
    }
    
    func zoomAction() {
        if UIDevice.current.orientation == .portrait {
            player.turn(.landscapeRight)
        } else {
            player.turn(.portrait)
        }
    }
    
    
    func firstTap() {
        if !hasFirstTapped {
            hasFirstTapped = true
            coverIv.isHidden = true
            playVideo()
            setNeedsDisplay()
        }
    }
    
    func playVideo() {
        if !hasFirstTapped {
            coverIv.isHidden = true
            setNeedsDisplay()
        }
        if player.isPlaying {
            player.pause()
        } else {
            player.play()
            if hasFirstTapped && isShow {
                hide()
            }
        }
        hasFirstTapped = true
    }
    
    func updatePlayBtn() {
        
    }
    
    func hide(_ delay: TimeInterval = 0) {
        UIView.animate(withDuration: 0.25, delay: delay, options: .allowUserInteraction, animations: {
            UIApplication.shared.setStatusBarHidden(true, with: .fade)
            self.bigPlayBtn.alpha = 0
            self.bot.alpha = 0
            self.top.alpha = 0
            self.botProgressView.alpha = 1
        }, completion: nil)
    }
    
    func show(_ delay: TimeInterval = 0) {
        UIView.animate(withDuration: 0.25, delay: delay, options: .allowUserInteraction, animations: {
            
            UIApplication.shared.setStatusBarHidden(false, with: .fade)
            self.bigPlayBtn.alpha = 1
            self.bot.alpha = 1
            self.top.alpha = 1
            self.botProgressView.alpha = 0
        }, completion: nil)
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
        progressView.setProgress(Float(buffer), animated: true)
    }
    
    func player(_ player: TCPlayer!, didGetDuration duration: CGFloat) {
        totalLbl.text = timeFormatter(duration)
    }
    
    func player(_ player: TCPlayer!, didPlay progress: CGFloat, current: CGFloat) {
        progressSlider.setValue(Float(progress), animated: true)
        botProgressView.setProgress(Float(progress), animated: true)
        currentLbl.text = timeFormatter(current)
    }
    
    func player(_ player: TCPlayer!, isPlaying: Bool) {
        if isPlaying {
            bigPlayBtn.setImage(UIImage(named:"player_bili_pause_ico"), for: .normal)
            playBtn.setImage(UIImage(named:"player_pause_bottom_window"), for: .normal)
        } else {
            bigPlayBtn.setImage(UIImage(named:"player_bili_play_ico"), for: .normal)
            playBtn.setImage(UIImage(named:"player_play_bottom_window"), for: .normal)
        }
    }

    
    deinit {
        debugPrint(self.classForCoder, "deinit")
    }
    
}
