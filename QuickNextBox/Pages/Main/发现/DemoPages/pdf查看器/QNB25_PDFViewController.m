// LR126RCX_QNB25_PDFViewController.m
#import "QNB25_PDFViewController.h"
#import "PDFManager.h"

@interface QNB25_PDFViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) PDFView *pdfView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *bottomToolbar;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) PDFDocument *pdfDocument;

@end

@implementation QNB25_PDFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self loadPDFDocument];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 如果是返回操作且设置了需要删除文件
    if (self.isMovingFromParentViewController && self.shouldDeleteOnBack) {
        [[PDFManager sharedManager] deletePDFFile:self.pdfFilePath];
    }
}

- (void)setupUI {
    self.title = self.pdfTitle ?: @"PDF文档";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 创建PDF视图
    [self setupPDFView];
    
    // 创建底部工具栏
    [self setupBottomToolbar];
}

- (void)setupPDFView {
    // 创建滚动视图
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 3.0;
    self.scrollView.showsHorizontalScrollIndicator = YES;
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.alwaysBounceHorizontal = YES;
    [self.view addSubview:self.scrollView];
    
    // 创建PDF视图
    self.pdfView = [[PDFView alloc] initWithFrame:CGRectZero];
    self.pdfView.displayMode = kPDFDisplaySinglePageContinuous;
    self.pdfView.autoScales = YES;
    self.pdfView.displayDirection = kPDFDisplayDirectionVertical;
    [self.scrollView addSubview:self.pdfView];
}

- (void)setupBottomToolbar {
    CGFloat toolbarHeight = 60 + self.view.safeAreaInsets.bottom;
    self.bottomToolbar = [[UIView alloc] initWithFrame:CGRectZero];
    self.bottomToolbar.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    self.bottomToolbar.layer.borderWidth = 0.5;
    self.bottomToolbar.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:self.bottomToolbar];
    
    // 分享按钮
    self.shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.shareButton setTitle:@"分享" forState:UIControlStateNormal];
    [self.shareButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    self.shareButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.shareButton.backgroundColor = [UIColor whiteColor];
    self.shareButton.layer.cornerRadius = 8;
    self.shareButton.layer.borderWidth = 1;
    self.shareButton.layer.borderColor = [UIColor systemBlueColor].CGColor;
    [self.shareButton addTarget:self action:@selector(shareButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomToolbar addSubview:self.shareButton];
    
    // 删除按钮
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal];
    self.deleteButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.deleteButton.backgroundColor = [UIColor whiteColor];
    self.deleteButton.layer.cornerRadius = 8;
    self.deleteButton.layer.borderWidth = 1;
    self.deleteButton.layer.borderColor = [UIColor systemRedColor].CGColor;
    [self.deleteButton addTarget:self action:@selector(deleteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomToolbar addSubview:self.deleteButton];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // 布局底部工具栏
    CGFloat toolbarHeight = 60 + self.view.safeAreaInsets.bottom;
    self.bottomToolbar.frame = CGRectMake(0,
                                          self.view.bounds.size.height - toolbarHeight,
                                          self.view.bounds.size.width,
                                          toolbarHeight);
    
    // 布局按钮
    CGFloat buttonWidth = (self.view.bounds.size.width - 60) / 2;
    self.shareButton.frame = CGRectMake(20, 10, buttonWidth, 40);
    self.deleteButton.frame = CGRectMake(CGRectGetMaxX(self.shareButton.frame) + 20, 10, buttonWidth, 40);
    
    // 布局PDF视图
    CGFloat pdfViewHeight = self.view.bounds.size.height - toolbarHeight;
    self.scrollView.frame = CGRectMake(0, 0, self.view.bounds.size.width, pdfViewHeight);
    
    // 更新PDF视图大小
    [self updatePDFViewSize];
}

- (void)updatePDFViewSize {
    if (self.pdfDocument) {
        PDFPage *firstPage = [self.pdfDocument pageAtIndex:0];
        if (firstPage) {
            CGRect pageRect = [firstPage boundsForBox:kPDFDisplayBoxMediaBox];
            CGFloat scale = self.scrollView.bounds.size.width / pageRect.size.width;
            
            // 设置PDF视图的大小
            CGSize contentSize = CGSizeMake(pageRect.size.width * scale, pageRect.size.height * scale * self.pdfDocument.pageCount);
            self.pdfView.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
            self.scrollView.contentSize = contentSize;
        }
    }
}

- (void)loadPDFDocument {
    if (!self.pdfFilePath || ![[NSFileManager defaultManager] fileExistsAtPath:self.pdfFilePath]) {
        [self showAlertWithTitle:@"错误" message:@"PDF文件不存在"];
        return;
    }
    
    NSData *pdfData = [[PDFManager sharedManager] getPDFDataFromFile:self.pdfFilePath];
    if (!pdfData) {
        [self showAlertWithTitle:@"错误" message:@"无法读取PDF文件"];
        return;
    }
    
    self.pdfDocument = [[PDFDocument alloc] initWithData:pdfData];
    if (!self.pdfDocument) {
        [self showAlertWithTitle:@"错误" message:@"PDF文件格式错误"];
        return;
    }
    
    self.pdfView.document = self.pdfDocument;
    
    // 延迟更新尺寸，确保PDF已加载
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updatePDFViewSize];
    });
}

#pragma mark - Button Actions

- (void)shareButtonTapped {
    if (!self.pdfFilePath || ![[NSFileManager defaultManager] fileExistsAtPath:self.pdfFilePath]) {
        [self showAlertWithTitle:@"错误" message:@"PDF文件不存在"];
        return;
    }
    
    NSURL *fileURL = [NSURL fileURLWithPath:self.pdfFilePath];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:nil];
    
    // 针对iPad的弹出位置设置
    if ([activityVC respondsToSelector:@selector(popoverPresentationController)]) {
        activityVC.popoverPresentationController.sourceView = self.shareButton;
        activityVC.popoverPresentationController.sourceRect = self.shareButton.bounds;
    }
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)deleteButtonTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认删除"
                                                                   message:@"确定要删除这个PDF文件吗？"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * _Nonnull action) {
        [self deletePDFAndGoBack];
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:deleteAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deletePDFAndGoBack {
    BOOL success = [[PDFManager sharedManager] deletePDFFile:self.pdfFilePath];
    
    if (success) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self showAlertWithTitle:@"错误" message:@"删除文件失败"];
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.pdfView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // 可以在这里添加缩放后的额外处理
}

#pragma mark - Helper Methods

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
