//
//  LocationHandler.h
//  QuickNextBox
//
//  Created by lgc on 2025/11/15.
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationHandlerDelegate <NSObject>

@required
-(void) didUpdateToLocation:(CLLocation*)newLocation;
@end

@interface LocationHandler : NSObject<CLLocationManagerDelegate> {
   CLLocationManager *locationManager;
}
@property(nonatomic,strong) id<LocationHandlerDelegate> delegate;

+(id)getSharedInstance;
-(void)startUpdating;
-(void) stopUpdating;

@end
