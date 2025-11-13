//
//  LRVideoPlayerManager 2.h
//  QuickNextBox
//
//  Created by lgc on 2025/11/11.
//


#import "LRVideoPlayerManager.h"

@interface LRVideoPlayerManager ()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) id timeObserver;
@end

@implementation LRVideoPlayerManager

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.playerItem = [AVPlayerItem playerItemWithURL:url];
        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        
        // 添加时间观察者（进度更新）
        __weak typeof(self) weakSelf = self;
        self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1)
                                                                      queue:dispatch_get_main_queue()
                                                                 usingBlock:^(CMTime time) {
            float current = CMTimeGetSeconds(time);
            float total = CMTimeGetSeconds(weakSelf.playerItem.duration);
            if (current && total) {
                NSLog(@"播放进度: %.2f%%", (current/total)*100);
            }
        }];
    }
    return self;
}

- (void)play {
    [self.player play];
}

- (void)pause {
    [self.player pause];
}

- (void)stop {
    [self.player pause];
    [self.player seekToTime:kCMTimeZero];
}

- (void)seekToTime:(CGFloat)seconds {
    CMTime target = CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC);
    [self.player seekToTime:target];
}

- (void)dealloc {
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
    }
}

@end
