//
//  AddedDeviceCell 2.h
//  QuickNextBox
//
//  Created by lgc on 2025/12/30.
//


#import "AddedDeviceCell.h"
#import <Masonry/Masonry.h>

@interface AddedDeviceCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *connectButton;

@end

@implementation AddedDeviceCell

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

    self.editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.editButton setTitle:@"✎" forState:UIControlStateNormal];

    self.deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.deleteButton.layer.cornerRadius = 12.5;
    self.deleteButton.layer.borderWidth = 1;
    self.deleteButton.layer.borderColor = [UIColor blackColor].CGColor;
    [self.deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:[UIColor redColor]
                            forState:UIControlStateNormal];
    self.deleteButton.titleLabel.font = [UIFont systemFontOfSize:13];

    self.connectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.connectButton.layer.cornerRadius = 12.5;
    self.connectButton.titleLabel.font = [UIFont systemFontOfSize:13];

    [self.contentView addSubview:self.iconView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.editButton];
    [self.contentView addSubview:self.deleteButton];
    [self.contentView addSubview:self.connectButton];
}

- (void)setupLayout {

    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(16);
        make.centerY.equalTo(self.contentView);
        make.width.height.mas_equalTo(60);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconView.mas_top);
        make.left.equalTo(self.iconView.mas_right).offset(14);
    }];

    [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel);
        make.left.equalTo(self.nameLabel.mas_right).offset(6);
        make.width.height.mas_equalTo(20);
    }];

    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel);
        make.bottom.equalTo(self.iconView.mas_bottom);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(25);
    }];

    [self.connectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.deleteButton);
        make.right.equalTo(self.contentView).offset(-16);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(25);
    }];
}


- (void)configWithName:(NSString *)name connected:(BOOL)connected {
    self.nameLabel.text = name;

    if (connected) {
        self.connectButton.backgroundColor = [UIColor systemBlueColor];
        [self.connectButton setTitle:@"Connected" forState:UIControlStateNormal];
    } else {
        self.connectButton.backgroundColor = [UIColor blackColor];
        [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    }
    [self.connectButton setTitleColor:[UIColor whiteColor]
                             forState:UIControlStateNormal];
}

@end
