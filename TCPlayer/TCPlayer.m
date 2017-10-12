//
//  TCPlayer.m
//  TCPlayerDemo
//
//  Created by Tech on 2017/10/10.
//  Copyright © 2017年 ctc. All rights reserved.
//

#import "TCPlayer.h"
#import <MediaPlayer/MediaPlayer.h>

#ifndef __OPTIMIZE__
#define log(...) NSLog(__VA_ARGS__)
#else
#define log(...) {}
#endif

NSString *const TCPlayerDidChangeBrightness = @"TCPlayerDidChangeBrightness";

@interface TCPlayer ()

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong, readonly) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) NSArray *keyPaths;

@property (nonatomic, strong) NSObject *playerTimeObserver;

@property (nonatomic, assign) CGFloat total;

@property (nonatomic, strong) TCPlayerContentView *contentView;

@end

@implementation TCPlayer

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.contentView.backgroundColor = UIColor.clearColor;
}

- (TCPlayerContentView *)contentView {
    if (!_contentView) {
        _contentView = [TCPlayerContentView new];
        [self addSubview:_contentView];
        [_contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_contentView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_contentView)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_contentView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_contentView)]];
    }
    return _contentView;
}

- (void)setDelegate:(id<TCPlayerDelegate>)delegate {
    _delegate = delegate;
    self.contentView.delegate = delegate;
}

- (void)addSubview:(UIView *)view {
    if (![view isEqual:self.contentView]) {
        [self.contentView addSubview:view];
    } else {
        [super addSubview:view];
    }
}

+ (Class)layerClass {
    return AVPlayerLayer.class;
}

- (void)setPlayer:(AVPlayer *)player {
    ((AVPlayerLayer *)self.layer).player = player;
}

- (AVPlayer *)player {
    return ((AVPlayerLayer *)self.layer).player;
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer * )self.layer;
}

- (NSArray *)keyPaths {
    if (!_keyPaths) {
        _keyPaths = @[
                      @"status",
                      @"loadedTimeRanges",
                      @"playbackBufferEmpty",
                      @"playbackLikelyToKeepUp",
                      //                      @"rate"
                      ];
    }
    return _keyPaths;
}

- (void)play:(NSString *)url {
    [self removeObservers];
    [self removeNotifications];
    _currentUrl = url;
    NSURL *URL = [NSURL URLWithString:url];
    self.player = [AVPlayer playerWithURL:URL];
    self.status = TCPlayerStatusLoading;
    self.type = TCPlayerTypeUnknown;
    [self addObservers];
    [self addNotifications];
}

- (void)dealloc {
    [self removeObservers];
    [self removeNotifications];
    log(@"%@ dealloc.",self.class);
}

- (void)play {
    [self.player play];
}

- (void)pause {
    [self.player pause];
}

- (void)replay {
    if (self.player.currentItem.status != AVPlayerItemStatusReadyToPlay) {
        // AVPlayerItem cannot service a seek request with a completion handler until its status is AVPlayerItemStatusReadyToPlay.
        return;
    }
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) {
            [self play];
        }
    }];
}

- (BOOL)isPlaying {
    return @(self.player.rate).boolValue;
}

- (void)refresh {
    [self play:self.currentUrl];
    [self play];
}

- (void)playAtPercent:(CGFloat)percent {
    if (self.player.currentItem.status != AVPlayerItemStatusReadyToPlay) {
        // AVPlayerItem cannot service a seek request with a completion handler until its status is AVPlayerItemStatusReadyToPlay.
        return;
    }
    [self.player seekToTime:CMTimeMakeWithSeconds(percent*self.total, 24) completionHandler:^(BOOL finished) {
        if (finished) {
        }
    }];
}

- (void)turnOrientation:(UIInterfaceOrientation)orientation {
    [UIDevice.currentDevice setValue:@(orientation) forKey:@"orientation"];
}

- (void)addFillSubview:(UIView *)subview {
    [self addSubview:subview];
    [subview setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[subview]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(subview)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[subview]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(subview)]];
}

- (void)addObservers {
    for (NSString *keyPath in self.keyPaths) {
        [self.player.currentItem addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
    }
    [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObservers {
    for (NSString *keyPath in self.keyPaths) {
        [self.player.currentItem removeObserver:self forKeyPath:keyPath];
    }
    [self.player removeObserver:self forKeyPath:@"rate"];
}

- (void)addNotifications {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(AVPlayerItemTimeJumpedNotificationAction:) name:AVPlayerItemTimeJumpedNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(AVPlayerItemDidPlayToEndTimeNotificationAction:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(AVPlayerItemFailedToPlayToEndTimeNotificationAction:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(AVPlayerItemPlaybackStalledNotificationAction:) name:AVPlayerItemPlaybackStalledNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(AVPlayerItemNewAccessLogEntryNotificationAction:) name:AVPlayerItemNewAccessLogEntryNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(AVPlayerItemNewErrorLogEntryNotificationAction:) name:AVPlayerItemNewErrorLogEntryNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(AVPlayerItemFailedToPlayToEndTimeErrorKeyAction:) name:AVPlayerItemFailedToPlayToEndTimeErrorKey object:nil];
}

- (void)removeNotifications {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        switch (self.player.currentItem.status) {
            case AVPlayerItemStatusReadyToPlay:
                self.status = TCPlayerStatusReadyToPlay;
                log(@"准备播放");
                self.total = CMTimeGetSeconds(self.player.currentItem.duration);
                if ([_delegate respondsToSelector:@selector(player:didGetDuration:)]) {
                    [_delegate player:self didGetDuration:self.total];
                }
                if (isnan(self.total)) {
                    self.type = TCPlayerTypeLive;
                } else {
                    self.type = TCPlayerTypeVideo;
                    [self observePlayback:self.player.currentItem];
                }
                break;
            default:
                log(@"无法播放：%@",object);
                self.status = TCPlayerStatusFailed;
                break;
        }
    }
    if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        log(@"缓冲不足暂停了");
    }
    if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        log(@"缓冲达到可播放程度了");
    }
    if ([keyPath isEqualToString:@"rate"]) {
        if ([_delegate respondsToSelector:@selector(player:isPlaying:)]) {
            [_delegate player:self isPlaying:[@(self.player.rate) boolValue]];
        }
    }
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        if (self.type == TCPlayerTypeVideo) {
            CGFloat timerInterval = [self videoBuffer];
            if ([_delegate respondsToSelector:@selector(player:didBuffer:)]) {
                [_delegate player:self didBuffer:timerInterval/self.total];
            }
        }
    }
}

- (CGFloat)videoBuffer {
    if (self.player.currentItem.status != AVPlayerStatusReadyToPlay) {
        return 0;
    }
    if (self.player.currentItem.loadedTimeRanges.count == 0) {
        return 0;
    }
    NSArray <NSValue *>*loadedTimeRanges = self.player.currentItem.loadedTimeRanges;
    CMTimeRange timerRange = loadedTimeRanges.firstObject.CMTimeRangeValue;
    CGFloat startSeconds = CMTimeGetSeconds(timerRange.start);
    CGFloat durationSeconds = CMTimeGetSeconds(timerRange.duration);
    return startSeconds + durationSeconds;
}

- (void)observePlayback:(AVPlayerItem *)playerItem {
    __weak typeof(self) weakSelf = self;
    self.playerTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:nil usingBlock:^(CMTime time) {
        if (weakSelf == nil) {
            return;
        }
        float currentSecond = playerItem.currentTime.value / playerItem.currentTime.timescale;
        currentSecond = currentSecond < 0 ? 0 : currentSecond;
        if ([weakSelf.delegate respondsToSelector:@selector(player:didPlay:current:)]) {
            [weakSelf.delegate player:weakSelf didPlay:currentSecond/weakSelf.total current:currentSecond];
        }
    }];
}


#pragma mark - NotificationActions - Method

- (void)AVPlayerItemTimeJumpedNotificationAction:(NSNotification *)note {
    //    log(@"播放时间跳跃：%@",note.object);
}

- (void)AVPlayerItemDidPlayToEndTimeNotificationAction:(NSNotification *)note {
    if ([_delegate respondsToSelector:@selector(playerDidPlayToEndTime:)]) {
        [_delegate playerDidPlayToEndTime:self];
    }
}

- (void)AVPlayerItemFailedToPlayToEndTimeNotificationAction:(NSNotification *)note {
    log(@"没能播放到最后：%@",note.object);
}

- (void)AVPlayerItemPlaybackStalledNotificationAction:(NSNotification *)note {
    log(@"媒体资源没有及时加载，无法继续播放。：%@",note.object);
}

- (void)AVPlayerItemNewAccessLogEntryNotificationAction:(NSNotification *)note {
    //    log(@"添加新的访问日志条目：%@",note.object);
}

- (void)AVPlayerItemNewErrorLogEntryNotificationAction:(NSNotification *)note {
    //    log(@"添加新的错误日志条目：%@",note.object);
}

- (void)AVPlayerItemFailedToPlayToEndTimeErrorKeyAction:(NSNotification *)note {
    log(@"没能播放到最后的错误key：%@",note.object);
}

@end

@interface TCPlayerContentView ()

@property (nonatomic, assign) TCPlayerTouchMode touchMode;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint endPoint;
@property (nonatomic, assign) BOOL isTouching;
@property (nonatomic, strong) UISlider *volumeViewSlider;
@property (nonatomic, assign) CGFloat startBrightness;
@property (nonatomic, assign) CGFloat startVolume;
@property (nonatomic, assign) CGFloat stratProgress;
@end

@implementation TCPlayerContentView

- (__kindof TCPlayer *)player {
    if ([self.superview isKindOfClass:[TCPlayer class]]) {
        return (__kindof TCPlayer *)self.superview;
    }
    return nil;
}

- (UISlider *)volumeViewSlider {
    if (!_volumeViewSlider) {
        MPVolumeView *view = [MPVolumeView new];
        for (UIView *v in view.subviews) {
            if ([v isKindOfClass:[UISlider class]]) {
                _volumeViewSlider = (UISlider *)v;
            }
        }
    }
    return _volumeViewSlider;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    _startPoint = [touch locationInView:self];
    _isTouching = YES;
    _startBrightness = UIScreen.mainScreen.brightness;
    _startVolume = self.volumeViewSlider.value;
    _touchMode = TCPlayerTouchModeNone;
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    self.endPoint = [touch locationInView:self];
    CGFloat offsetX = _endPoint.x - _startPoint.x;
    CGFloat offsetY = _endPoint.y - _startPoint.y;
    if (_touchMode == TCPlayerTouchModeNone) {
        if ((fabs(offsetX) < fabs(offsetY)) && fabs(offsetY)>20) {
            if (_startPoint.x <= self.bounds.size.width*0.5) {
                _touchMode = self.player.slideVolumnOnTheLeft ? TCPlayerTouchModeVolume : TCPlayerTouchModeBrightness;
            } else {
                _touchMode = self.player.slideVolumnOnTheLeft ? TCPlayerTouchModeBrightness : TCPlayerTouchModeVolume;
            }
        }
        if ((fabs(offsetX) >= fabs(offsetY)) && fabs(offsetX)>20) {
            _touchMode = TCPlayerTouchModeProgress;
        }
    }
    
    if (_touchMode == TCPlayerTouchModeVolume) {
        self.volumeViewSlider.value = _startVolume - offsetY/self.bounds.size.height;
    }
    if (_touchMode == TCPlayerTouchModeBrightness) {
        UIScreen.mainScreen.brightness = _startBrightness - offsetY/self.bounds.size.height;
    }
    if (_touchMode == TCPlayerTouchModeProgress) {
        if ([_delegate respondsToSelector:@selector(player:willJumpProgress:)] && [self.superview isKindOfClass:[TCPlayer class]]) {
            [_delegate player:(TCPlayer *)self.superview willJumpProgress:offsetX/self.bounds.size.width*0.1];
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    CGFloat offsetX = _endPoint.x - _startPoint.x;
    if (_touchMode == TCPlayerTouchModeProgress && [_delegate respondsToSelector:@selector(player:didJumpProgress:)] && [self.superview isKindOfClass:[TCPlayer class]]) {
        [_delegate player:(TCPlayer *)self.superview didJumpProgress:offsetX/self.bounds.size.width*0.1];
    }
    _isTouching = NO;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    _isTouching = NO;
}

@end

