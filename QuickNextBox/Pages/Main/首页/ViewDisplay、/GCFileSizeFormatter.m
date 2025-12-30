//
//  GCFileSizeFormatter.m
//  QuickNextBox
//
//  Created by lgc on 2025/12/17.
//


#import "GCFileSizeFormatter.h"

@implementation GCFileSizeFormatter

#pragma mark - Public

+ (NSString *)fileSizeStringFromBytes:(long long)bytes {
    return [[self fileFormatter] stringFromByteCount:bytes];
}

+ (NSString *)memorySizeStringFromBytes:(long long)bytes {
    return [[self memoryFormatter] stringFromByteCount:bytes];
}

+ (NSString *)binarySizeStringFromBytes:(long long)bytes {
    return [[self binaryFormatter] stringFromByteCount:bytes];
}

+ (NSString *)fileSizeStringFromBytes:(long long)bytes
                        decimalPlaces:(NSUInteger)places {
    if (bytes <= 0) {
        return @"0 B";
    }

    double value = (double)bytes;
    NSArray<NSString *> *units = @[@"B", @"KB", @"MB", @"GB", @"TB"];
    NSInteger index = 0;

    while (value >= 1024 && index < units.count - 1) {
        value /= 1024;
        index++;
    }

    NSString *format = [NSString stringWithFormat:@"%%.%luf %%@", (unsigned long)places];
    return [NSString stringWithFormat:format, value, units[index]];
}

#pragma mark - Formatter (Singleton)

+ (NSByteCountFormatter *)fileFormatter {
    static NSByteCountFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSByteCountFormatter alloc] init];
        formatter.countStyle = NSByteCountFormatterCountStyleFile;
        formatter.includesUnit = YES;
        formatter.includesCount = YES;
        formatter.adaptive = YES;
    });
    return formatter;
}

+ (NSByteCountFormatter *)memoryFormatter {
    static NSByteCountFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSByteCountFormatter alloc] init];
        formatter.countStyle = NSByteCountFormatterCountStyleMemory;
    });
    return formatter;
}

+ (NSByteCountFormatter *)binaryFormatter {
    static NSByteCountFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSByteCountFormatter alloc] init];
        formatter.countStyle = NSByteCountFormatterCountStyleBinary;
    });
    return formatter;
}

@end
