//
//  TakePhoteController.m
//  QuickNextBox
//
//  Created by lgc on 2025/11/10.
//

#import "TakePhoteController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>
//#import <UIKit/UIKitDefines.h>
//#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@interface TakePhoteController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate> {
    UIImagePickerController *imagePicker;
    UIImageView *imageView;
}
@end

@implementation TakePhoteController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    [self setupUI];
}

#pragma mark - UI Setup
- (void)setupUI {
    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = NSLocalizedString(@"单击文本，打开相机", nil);
    subtitleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    subtitleLabel.textColor = [UIColor secondaryLabelColor];
    subtitleLabel.userInteractionEnabled = YES;
    [self.view addSubview:subtitleLabel];
    
    [subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(30);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showCamera)];
    [subtitleLabel addGestureRecognizer:tap];
    
    // 图片预览区
    imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor systemGray6Color];
    imageView.layer.cornerRadius = 12;
    imageView.layer.masksToBounds = YES;
    [self.view addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(subtitleLabel.mas_bottom).offset(30);
        make.width.equalTo(self.view).multipliedBy(0.8);
        make.height.equalTo(imageView.mas_width); // 正方形
    }];
    
    // 下方按钮
    UIButton *photoButton = [self createButtonWithTitle:@"从相册选取" action:@selector(showPhotoLibrary)];
    UIButton *fileButton = [self createButtonWithTitle:@"从文件中选取" action:@selector(showFilePicker)];
    
    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[photoButton, fileButton]];
    stack.axis = UILayoutConstraintAxisHorizontal;
    stack.spacing = 20;
    stack.distribution = UIStackViewDistributionFillEqually;
    [self.view addSubview:stack];
    
    [stack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).offset(40);
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(0.8);
        make.height.mas_equalTo(44);
    }];
}



#pragma mark - Camera Logic
- (void)showCamera {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        [self showAlertWithTitle:@"相机访问受限"
                         message:@"请前往设置中允许应用访问相机。"];
        return;
    }
    
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    [self presentCamera];
                } else {
                    [self showAlertWithTitle:@"相机权限未授予"
                                     message:@"请在系统设置中开启相机权限。"];
                }
            });
        }];
    } else {
        [self presentCamera];
    }
}

- (void)presentCamera {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self showAlertWithTitle:@"错误" message:@"此设备不支持相机功能。"];
        return;
    }
    
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - Photo Library
- (void)showPhotoLibrary {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
        [self showAlertWithTitle:@"无法访问相册" message:@"请前往设置中允许访问相册。"];
        return;
    }
    
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus newStatus) {
            if (newStatus == PHAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentPhotoLibrary];
                });
            }
        }];
    } else {
        [self presentPhotoLibrary];
    }
}

- (void)presentPhotoLibrary {
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - File Picker
- (void)showFilePicker {
    NSArray *types = @[(NSString *)kUTTypeImage];

    UIDocumentPickerViewController *docPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:types
                                                           inMode:UIDocumentPickerModeImport];
    docPicker.delegate = self;
    docPicker.allowsMultipleSelection = NO;
    [self presentViewController:docPicker animated:YES completion:nil];
}


- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *url = urls.firstObject;
    if (!url) return;
    
    // 尝试 startAccessingSecurityScopedResource，但不失败就停止
    BOOL didAccess = [url startAccessingSecurityScopedResource];
    
    
    /**  直接用
     NSData *data = [NSData dataWithContentsOfURL:url];
     UIImage *image = [UIImage imageWithData:data];
     imageView.image = image;
     [url stopAccessingSecurityScopedResource];
     */
    
    // 复制tmp目录先
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:url.lastPathComponent];
    NSURL *tempURL = [NSURL fileURLWithPath:tempPath];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] copyItemAtURL:url toURL:tempURL error:&error];
    
    if (!error) {
        NSData *data = [NSData dataWithContentsOfURL:tempURL];
        UIImage *image = [UIImage imageWithData:data];
        if (image) self->imageView.image = image;
        else [self showAlertWithTitle:@"提示" message:@"无法读取图片内容"];
    } else {
        [self showAlertWithTitle:@"复制失败" message:error.localizedDescription];
    }
    
    // 如果之前调用过 startAccessingSecurityScopedResource，就停止访问
    if (didAccess) [url stopAccessingSecurityScopedResource];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    imageView.image = image;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helpers
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    [GCAlertManager showAlertInView:self WithTitle:title message:message];
}

- (UIButton *)createButtonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    button.backgroundColor = [UIColor systemBlueColor];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.layer.cornerRadius = 8;
    button.layer.masksToBounds = YES;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}
@end
