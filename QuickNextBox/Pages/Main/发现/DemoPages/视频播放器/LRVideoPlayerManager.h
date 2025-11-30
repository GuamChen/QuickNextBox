//
//  LRVideoPlayerManager.h
//  QuickNextBox
//
//  Created by lgc on 2025/11/11.
//


#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LRVideoPlayerManager : NSObject

@property (nonatomic, strong, readonly) AVPlayer *player;
@property (nonatomic, strong, readonly) AVPlayerItem *playerItem;

- (instancetype)initWithURL:(NSURL *)url;
- (void)play;
- (void)pause;
- (void)stop;
- (void)seekToTime:(CGFloat)seconds;

@end

NS_ASSUME_NONNULL_END
