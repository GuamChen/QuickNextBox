//
//  LocationHandler 2.h
//  QuickNextBox
//
//  Created by lgc on 2025/11/15.
//


#import "LocationHandler.h"
static LocationHandler *DefaultManager = nil;

@interface LocationHandler()

-(void)initiate;

@end

@implementation LocationHandler

+(id)getSharedInstance{
   if (!DefaultManager) {
      DefaultManager = [[self allocWithZone:NULL]init];
      [DefaultManager initiate];
   }
   return DefaultManager;
}

-(void)initiate {
   locationManager = [[CLLocationManager alloc]init];
   locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    [locationManager requestWhenInUseAuthorization];
    // 或
//    [locationManager requestAlwaysAuthorization];

}

-(void)startUpdating{
   [locationManager startUpdatingLocation];
}

-(void) stopUpdating {
   [locationManager stopUpdatingLocation];
}


/// 被废弃了的方法
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:
   (CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
}

-(void)locationManager:(CLLocationManager *)manager
    didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation * newLocation = [locations lastObject];
    if ([self.delegate respondsToSelector:@selector
         (didUpdateToLocation:)]) {
        [self.delegate didUpdateToLocation:newLocation];
    }

}
@end
