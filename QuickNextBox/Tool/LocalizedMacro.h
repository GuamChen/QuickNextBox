// LocalizedMacro.h
#ifndef LocalizedMacro_h
#define LocalizedMacro_h

// 快捷宏
#define Localized(key) [key localized]
#define LocalizedWithComment(key, comment) [key localizedWithComment:comment]

// 常用文本宏
#define L_Welcome Localized(@"welcome")
#define L_Back Localized(@"back")
#define L_Save Localized(@"save")
#define L_Cancel Localized(@"cancel")

#endif /* LocalizedMacro_h */
