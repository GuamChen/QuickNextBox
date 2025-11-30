#import "LRVideoPlayerManager.h"
#import "LRVideoPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface LRVideoPlayerViewController ()
@property (nonatomic, strong) LRVideoPlayerManager *playerManager;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

// 控件
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UIProgressView *bufferProgress;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *fullScreenButton;

// 状态
@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, strong) id timeObserver;
@end

@implementation LRVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    NSURL *url = [NSURL URLWithString:
                  @"https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear1/prog_index.m3u8"];
    self.playerManager = [[LRVideoPlayerManager alloc] initWithURL:url];
    
    // 创建播放图层
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.playerManager.player];
    self.playerLayer.frame = CGRectMake(0, 100, self.view.bounds.size.width, 220);
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:self.playerLayer];
    
    // 控制按钮
    [self setupControls];
    [self addPlayerObservers];
}

#pragma mark - UI 构建
- (void)setupControls {
    CGFloat bottomY = CGRectGetMaxY(self.playerLayer.frame) + 20;
    
    // 播放按钮
    self.playButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.playButton.frame = CGRectMake(20, bottomY, 60, 40);
    [self.playButton setTitle:@"▶️" forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(togglePlay)
              forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playButton];
    
    // 全屏按钮
    self.fullScreenButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.fullScreenButton.frame = CGRectMake(self.view.bounds.size.width - 60, bottomY, 40, 40);
    [self.fullScreenButton setTitle:@"🔳" forState:UIControlStateNormal];
    [self.fullScreenButton addTarget:self
                              action:@selector(toggleFullScreen)
                    forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.fullScreenButton];
    
    // 缓冲进度条
    self.bufferProgress = [[UIProgressView alloc] initWithFrame:
                           CGRectMake(20, bottomY + 45, self.view.bounds.size.width - 40, 2)];
    self.bufferProgress.progressTintColor = [UIColor lightGrayColor];
    self.bufferProgress.trackTintColor = [UIColor darkGrayColor];
    [self.view addSubview:self.bufferProgress];
    
    // 播放进度条
    self.progressSlider = [[UISlider alloc] initWithFrame:
                           CGRectMake(20, bottomY + 35, self.view.bounds.size.width - 40, 20)];
    [self.progressSlider addTarget:self
                            action:@selector(progressChanged:)
                  forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.progressSlider];
    
    // 时间标签
    self.timeLabel = [[UILabel alloc] initWithFrame:
                      CGRectMake(20, bottomY + 60, self.view.bounds.size.width - 40, 20)];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.font = [UIFont systemFontOfSize:14];
    self.timeLabel.text = @"00:00 / 00:00";
    [self.view addSubview:self.timeLabel];
}

#pragma mark - 播放控制
- (void)togglePlay {
    if (self.playerManager.player.rate == 0) {
        [self.playerManager play];
        [self.playButton setTitle:@"⏸" forState:UIControlStateNormal];
    } else {
        [self.playerManager pause];
        [self.playButton setTitle:@"▶️" forState:UIControlStateNormal];
    }
}

#pragma mark - 播放进度
- (void)addPlayerObservers {
    AVPlayerItem *item = self.playerManager.playerItem;
    
    // 播放进度监听
    __weak typeof(self) weakSelf = self;
    self.timeObserver = [self.playerManager.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1)
                                                                                queue:dispatch_get_main_queue()
                                                                           usingBlock:^(CMTime time) {
        float current = CMTimeGetSeconds(time);
        float total = CMTimeGetSeconds(item.duration);
        if (isfinite(total) && total > 0) {
            weakSelf.progressSlider.value = current / total;
            weakSelf.timeLabel.text = [NSString stringWithFormat:@"%@ / %@",
                                       [weakSelf formatTime:current],
                                       [weakSelf formatTime:total]];
        }
    }];
    
    // 缓冲进度监听（KVO）
    [item addObserver:self forKeyPath:@"loadedTimeRanges"
              options:NSKeyValueObservingOptionNew context:nil];
    
    // 播放结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playDidEnd)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:item];
}

#pragma mark - 缓冲监听
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSArray *ranges = self.playerManager.playerItem.loadedTimeRanges;
        if (ranges.count > 0) {
            CMTimeRange range = [ranges.firstObject CMTimeRangeValue];
            float bufferStart = CMTimeGetSeconds(range.start);
            float bufferDuration = CMTimeGetSeconds(range.duration);
            float total = CMTimeGetSeconds(self.playerManager.playerItem.duration);
            float progress = (bufferStart + bufferDuration) / total;
            [self.bufferProgress setProgress:progress animated:YES];
        }
    }
}

#pragma mark - 全屏切换（自动横屏）
- (void)toggleFullScreen {
    self.isFullScreen = !self.isFullScreen;
    
    [UIView animateWithDuration:0.4 animations:^{
        if (self.isFullScreen) {
            // 强制横屏
            [self forceDeviceOrientation:UIInterfaceOrientationLandscapeRight];
            [self.fullScreenButton setTitle:@"🟥" forState:UIControlStateNormal];
        } else {
            [self forceDeviceOrientation:UIInterfaceOrientationPortrait];
            [self.fullScreenButton setTitle:@"🔳" forState:UIControlStateNormal];
        }
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.playerLayer.frame = self.isFullScreen
            ? self.view.bounds
            : CGRectMake(0, 100, self.view.bounds.size.width, 220);
        }];
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

- (void)forceDeviceOrientation:(UIInterfaceOrientation)orientation {
    // 非公开API调用方式（安全写法）
    NSNumber *value = [NSNumber numberWithInt:(int)orientation];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

#pragma mark - 状态栏控制
- (BOOL)prefersStatusBarHidden {
    return self.isFullScreen;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.isFullScreen ? UIInterfaceOrientationMaskLandscape : UIInterfaceOrientationMaskPortrait;
}
- (BOOL)shouldAutorotate{
    return  YES;
}
#pragma mark - 进度条拖动
- (void)progressChanged:(UISlider *)slider {
    CGFloat duration = CMTimeGetSeconds(self.playerManager.playerItem.duration);
    CGFloat target = duration * slider.value;
    [self.playerManager seekToTime:target];
}

#pragma mark - 播放结束
- (void)playDidEnd {
    [self.playerManager stop];
    [self.playButton setTitle:@"▶️" forState:UIControlStateNormal];
}

#pragma mark - 时间格式化
- (NSString *)formatTime:(float)seconds {
    int m = seconds / 60;
    int s = (int)seconds % 60;
    return [NSString stringWithFormat:@"%02d:%02d", m, s];
}

#pragma mark - 生命周期清理
- (void)dealloc {
    if (self.timeObserver) {
        [self.playerManager.player removeTimeObserver:self.timeObserver];
    }
    [self.playerManager.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
