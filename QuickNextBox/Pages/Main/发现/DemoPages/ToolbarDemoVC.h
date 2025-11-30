//
//  ToolbarDemoVC.h.h
//  QuickNextBox
//
//  Created by lgc on 2025/11/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ToolbarActionType) {
    ToolbarActionTypeSave,
    ToolbarActionTypeShare,
    ToolbarActionTypeEdit,
    ToolbarActionTypeDelete,
    ToolbarActionTypeFavorite
};

@interface ToolbarDemoVC : UIViewController

@end

NS_ASSUME_NONNULL_END
