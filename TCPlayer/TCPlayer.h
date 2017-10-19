//
//  TCPlayer.h
//  TCPlayerDemo
//
//  Created by Tech on 2017/10/10.
//  Copyright © 2017年 ctc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class TCPlayer;

@protocol TCPlayerDelegate <NSObject>
@optional
/// 无法播放
- (void)playerDidPlayFailed:(TCPlayer *)player;
/// 缓冲进度
- (void)player:(TCPlayer *)player didBuffer:(CGFloat)buffer;
/// 当前播放的进度以及当前播放的秒数
- (void)player:(TCPlayer *)player didPlay:(CGFloat)progress current:(CGFloat)current;
/// 获取播放总时长
- (void)player:(TCPlayer *)player didGetDuration:(CGFloat)duration;
/// 横屏滑动将要跳动的进度 此处返回的是滑动距离与播放器宽度的比值的十分之一
- (void)player:(TCPlayer *)player willJumpProgress:(CGFloat)progress;
/// 横屏滑动跳动进度 此处返回的是滑动距离与播放器宽度的比值的十分之一
- (void)player:(TCPlayer *)player didJumpProgress:(CGFloat)progress;
/// 上下滑动改变音量 默认屏幕右边区域
- (void)player:(TCPlayer *)player didChangeVolume:(CGFloat)volume;
/// 上下滑动改变亮度 默认屏幕左边区域
- (void)player:(TCPlayer *)player didChangeBrightness:(CGFloat)brightness;
/// 播放器播放状态
- (void)player:(TCPlayer *)player isPlaying:(BOOL)isPlaying;
/// 播放结束
- (void)playerDidPlayToEndTime:(TCPlayer *)player;
@end

// notifications                                                                                description
/// 改变亮度
FOUNDATION_EXPORT NSString *const TCPlayerDidChangeBrightness;

/**
 播放器状态

 - TCPlayerStatusFailed: 无法播放
 - TCPlayerStatusReadyToPlay: 准备播放
 - TCPlayerStatusLoading: 加载中
 */
typedef NS_ENUM(NSInteger, TCPlayerStatus) {
    TCPlayerStatusLoading,
    TCPlayerStatusFailed,
    TCPlayerStatusReadyToPlay,
};

/**
 播放器类型
 
 - TCPlayerTypeLive: 直播
 - TCPlayerTypeVideo: 视频
 */
typedef NS_ENUM(NSInteger, TCPlayerType) {
    TCPlayerTypeLive,
    TCPlayerTypeVideo,
    TCPlayerTypeUnknown
};

/**
 滑屏手势类型
 
 - TCPlayerTypeLive: 直播
 - TCPlayerTypeVideo: 视频
 */
typedef NS_ENUM(NSInteger, TCPlayerTouchMode) {
    TCPlayerTouchModeNone,
    TCPlayerTouchModeBrightness,
    TCPlayerTouchModeVolume,
    TCPlayerTouchModeProgress
};

typedef void (^ScreenshotCompletion)(UIImage *image);

@interface TCPlayer : UIView

@property (nonatomic, assign) TCPlayerStatus status;
@property (nonatomic, assign) TCPlayerType type;
@property (nonatomic, assign) TCPlayerTouchMode touchMode;
@property (nonatomic, copy) NSString *currentUrl;
@property (nonatomic, weak) id<TCPlayerDelegate>delegate;
/** 上下滑动屏幕左半边区域改变音量大小 默认是在右边 NO */
@property (nonatomic, assign) BOOL slideVolumnOnTheLeft;
@property (nonatomic, assign, readonly) BOOL isPlaying;
/** 录制gif的每秒帧数 默认是8 */
@property (nonatomic, assign) NSInteger gifFps;

/**
 播放在线视频

 @param url 视频地址
 */
- (void)play:(NSString *)url;

/** 播放 */
- (void)play;
/** 暂停 */
- (void)pause;
/** 重放 */
- (void)replay;
/** 刷新 */
- (void)refresh;
/** 定位播放 */
- (void)playAtPercent:(CGFloat)percent;
/** 屏幕转向 */
- (void)turnOrientation:(UIInterfaceOrientation)orientation;
/** 添加一个撑满的视图 */
- (void)addFillSubview:(UIView *)subview;
/** 截图 */
- (void)screenshotWithCompletion:(ScreenshotCompletion)completion;

// 暂时不支持GIF录制
///** 开始录制Gif 请记得用stop或者cancel来关闭录制 不然会造成内存泄漏*/
//- (void)startRecordingGif;
///** 停止录制Gif */
//- (void)stopRecordingGif;
//- (void)stopRecordingGifWithCompletion:(ScreenshotCompletion)completion;
///** 取消录制Gif */
//- (void)cancelRecordingGif;

@end

@interface TCPlayerContentView : UIView
@property (nonatomic, weak) id<TCPlayerDelegate>delegate;
@end
