//
//  DeviceUnaddedCell 2.h
//  QuickNextBox
//
//  Created by lgc on 2025/12/30.
//


#import "DeviceUnaddedCell.h"
#import <Masonry/Masonry.h>

@interface DeviceUnaddedCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *connectButton;

@end

@implementation DeviceUnaddedCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
        [self setupLayout];
    }
    return self;
}

- (void)setupUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.layer.cornerRadius = 12;
    self.clipsToBounds = YES;
    
    self.iconView = [[UIImageView alloc] init];
    self.iconView.backgroundColor = [UIColor lightGrayColor];
    self.iconView.layer.cornerRadius = 8;
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [UIFont systemFontOfSize:15];
    
    self.connectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.connectButton.backgroundColor = [UIColor blackColor];
    self.connectButton.layer.cornerRadius = 12.5;
    [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [self.connectButton setTitleColor:[UIColor whiteColor]
                             forState:UIControlStateNormal];
    self.connectButton.titleLabel.font = [UIFont systemFontOfSize:13];
    
    [self.contentView addSubview:self.iconView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.connectButton];
}

- (void)setupLayout {
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(16);
        make.centerY.equalTo(self.contentView);
        make.width.height.mas_equalTo(60);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.iconView.mas_right).offset(14);
        make.right.lessThanOrEqualTo(self.connectButton.mas_left).offset(-10);
    }];
    
    [self.connectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-16);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(25);
    }];
}

- (void)configWithName:(NSString *)name {
    self.nameLabel.text = name;
}

@end
