//
//  LocationViewController.m
//  QuickNextBox
//
//  Created by lgc on 2025/11/15.
//

#import "LocationViewController.h"

@interface LocationViewController ()
@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[LocationHandler getSharedInstance]setDelegate:self];
    [[LocationHandler getSharedInstance]startUpdating];
    
    latitudeLabel = [[UILabel alloc] init];
    latitudeLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
    latitudeLabel.textAlignment = NSTextAlignmentCenter;
    latitudeLabel.textColor = [UIColor secondaryLabelColor];
    
    [self.view addSubview:latitudeLabel];
    
    [latitudeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(20);
    }];
    
    longitudeLabel = [[UILabel alloc] init];
    longitudeLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
    longitudeLabel.textAlignment = NSTextAlignmentCenter;
    longitudeLabel.textColor = [UIColor secondaryLabelColor];
    
    [self.view addSubview:longitudeLabel];
    
    [longitudeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(latitudeLabel.mas_bottom).offset(50);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didUpdateToLocation:(CLLocation *)newLocation {
    [latitudeLabel setText:[NSString stringWithFormat:
                            @"Latitude: %f",newLocation.coordinate.latitude]];
    [longitudeLabel setText:[NSString stringWithFormat:
                             @"Longitude: %f",newLocation.coordinate.longitude]];
}
@end
