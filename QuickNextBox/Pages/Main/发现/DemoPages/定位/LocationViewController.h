//
//  LocationViewController.h
//  QuickNextBox
//
//  Created by lgc on 2025/11/15.
//

#import <UIKit/UIKit.h>
#import "LocationHandler.h"
NS_ASSUME_NONNULL_BEGIN



@interface LocationViewController : UIViewController<LocationHandlerDelegate> {
    IBOutlet UILabel *latitudeLabel;
    IBOutlet UILabel *longitudeLabel;
}
@end

NS_ASSUME_NONNULL_END
