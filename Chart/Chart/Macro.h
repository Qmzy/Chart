//  宏
//
//  Macro.h
//  Chart
//
//  Created by CYKJ on 2019/1/3.
//  Copyright © 2019年 D. All rights reserved.


#ifndef Macro_h
#define Macro_h


#undef    ST_SINGLETON
#define ST_SINGLETON \
- (instancetype)sharedInstance; \
+ (instancetype)sharedInstance;

#undef    DEF_SINGLETON
#define DEF_SINGLETON \
- (instancetype)sharedInstance \
{ \
return [[self class] sharedInstance]; \
} \
+ (instancetype)sharedInstance \
{ \
static dispatch_once_t once; \
static id __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[self alloc] init]; } ); \
return __singleton__; \
}



#undef  UIColorFromRGB
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#undef  UIColorFromRGB_A
#define UIColorFromRGB_A(r, g, b) ([UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0])

#define UIColorFromARGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:((float)((rgbValue & 0xFF000000)>>24)/255.0)]


#define VIEW_W  CGRectGetWidth(self.frame)
#define VIEW_H  CGRectGetHeight(self.frame)

#define SCREEN_WIDTH         ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT        ([[UIScreen mainScreen] bounds].size.height)


#undef  SELF_WEEK
#define SELF_WEEK  __weak __typeof(self)weakSelf = self

#undef  SELF_STRONG
#define SELF_STRONG __strong __typeof(weakSelf)strongSelf = weakSelf

#endif
