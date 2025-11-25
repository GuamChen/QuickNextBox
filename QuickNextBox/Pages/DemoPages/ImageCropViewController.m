//
//  ImageCropViewController 2.h
//  QuickNextBox
//
//  Created by lgc on 2025/11/18.
//

#import <Photos/Photos.h>

#import "ImageCropViewController.h"

@interface ImageCropViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *cropAreaView;
@property (nonatomic, strong) UIImagePickerController *imagePicker;


@property (nonatomic, strong) UIImage *image;
@end

@implementation ImageCropViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    
    // ---- 4. 裁剪按钮 ----
    UIButton *photoButton = [self createButtonWithTitle:@"从相册选取" action:@selector(showPhotoLibrary)];
    UIButton *fileButton = [self createButtonWithTitle:@"裁剪" action:@selector(cropButtonPressed)];
    
    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[photoButton, fileButton]];
    stack.axis = UILayoutConstraintAxisHorizontal;
    stack.spacing = 20;
    stack.distribution = UIStackViewDistributionFillEqually;
    [self.view addSubview:stack];
    
    [stack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(20);
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(0.8);
        make.height.mas_equalTo(44);
    }];
    
   

   
}

- (void)showPhotoLibrary {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
//        [self showAlertWithTitle:@"无法访问相册" message:@"请前往设置中允许访问相册。"];
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
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.allowsEditing = YES;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    self.image = image;

    [picker dismissViewControllerAnimated:YES completion:^{
        [self insertImage];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void) insertImage {
    // ---- 1. 修正方向 ----
    self.image = [self fixOrientation:self.image];
    
    // ---- 2. 显示图片 ----
    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.frame = self.view.bounds;
    [self.view addSubview:self.imageView];
    
    // ---- 3. 裁剪框（可拖动）----
    CGFloat boxSize = 200;
    self.cropAreaView = [[UIView alloc] initWithFrame:CGRectMake(
                                                                 (self.view.bounds.size.width - boxSize) / 2,
                                                                 (self.view.bounds.size.height - boxSize) / 2,
                                                                 boxSize,
                                                                 boxSize
                                                                 )];
    self.cropAreaView.layer.borderColor = [UIColor yellowColor].CGColor;
    self.cropAreaView.layer.borderWidth = 2;
    [self.view addSubview:self.cropAreaView];
    
    // 拖动手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.cropAreaView addGestureRecognizer:pan];

}


#pragma mark - 拖动裁剪框
- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.view]; /// 在指定视图的坐标系中进行转换
    gesture.view.center = CGPointMake(gesture.view.center.x + translation.x,
                                      gesture.view.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:self.view];  /// 把当前手势的“移动偏移量”归零，避免累计叠加
}

#pragma mark - 点击裁剪按钮
/**
 UIImageView：AspectFit 显示图片（比例不变，通常有黑边）
 cropAreaView：一个在屏幕坐标系下的裁剪框
 需要把“屏幕坐标系的裁剪框”转换成“图片坐标系的裁剪区域”
 最终执行 CGImageCreateWithImageInRect 裁剪
 视觉上 -> 图片坐标系 -> 真实像素裁剪
 */
- (void)cropButtonPressed {
    if(!self.image) {
        [GCAlertManager showTemporaryMessage:@"image is nil"];
        return;
    }
    
    UIImage *croppedImage = [self cropImage:self.image withCropRect:self.cropAreaView.frame];
    
    // 展示结果
    UIImageView *iv = [[UIImageView alloc] initWithImage:croppedImage];
    iv.frame = CGRectMake(20, 100, 150, 150);
    iv.contentMode = UIViewContentModeScaleAspectFit;
    iv.backgroundColor = [UIColor blackColor];
    [self.view addSubview:iv];
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(self.view.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(150, 150));
    }];
}

#pragma mark - 核心逻辑：裁剪图片（保持方向）
- (UIImage *)cropImage:(UIImage *)image withCropRect:(CGRect)cropRectInView {

    // 1. 计算 UIImageView 实际展示区域
    CGRect imageFrame = [self imageFrameInImageView:self.imageView];

    // 2. 将裁剪框从 view 坐标系转换到 image 坐标系
    CGFloat scaleX = image.size.width / imageFrame.size.width;
    CGFloat scaleY = image.size.height / imageFrame.size.height;

    CGRect cropRectInImage;
    cropRectInImage.origin.x = (cropRectInView.origin.x - imageFrame.origin.x) * scaleX;
    cropRectInImage.origin.y = (cropRectInView.origin.y - imageFrame.origin.y) * scaleY;
    cropRectInImage.size.width = cropRectInView.size.width * scaleX;
    cropRectInImage.size.height = cropRectInView.size.height * scaleY;

    // 3. CGImage 裁剪
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, cropRectInImage);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);

    return result;
}

#pragma mark - UIImageView 实际内容 frame（AspectFit）
- (CGRect)imageFrameInImageView:(UIImageView *)imageView {
    CGSize imageSize = imageView.image.size;
    CGSize viewSize = imageView.bounds.size;

    CGFloat scaleX = viewSize.width / imageSize.width;
    CGFloat scaleY = viewSize.height / imageSize.height;
    CGFloat scale = MIN(scaleX, scaleY);

    CGFloat width = imageSize.width * scale;
    CGFloat height = imageSize.height * scale;
    CGFloat x = (viewSize.width - width) / 2;
    CGFloat y = (viewSize.height - height) / 2;

    return CGRectMake(x, y, width, height);
}

#pragma mark - 修正方向
- (UIImage *)fixOrientation:(UIImage *)image {
    if (image.imageOrientation == UIImageOrientationUp) {
        return image;
    }

    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    UIImage *normalized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalized;
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
