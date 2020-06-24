//
//  JKMacDevelopToolsPrefixHeader.h
//  MacDevelopTools
//
//  Created by jk on 2018/12/25.
//  Copyright © 2018年 JK. All rights reserved.
//

#ifndef JKMacDevelopToolsPrefixHeader_h
#define JKMacDevelopToolsPrefixHeader_h

#define kJKStatusItemPopOverCloseNotification @"kJKStatusItemPopOverCloseNotification"
#define kJKStatusItemPopOverShowNotification @"kJKStatusItemPopOverShowNotification"

#define kJKStatusItemListChangeNotification @"kJKStatusItemListChangeNotification"

#define kJKHasStringValue(x) (x && [x isKindOfClass:[NSString class]] && x.length > 0)

//opengl mac
#define CSM_TARGET_MAC_GL

//#define PREMULTIPLIED_ALPHA_ENABLE

#endif /* JKMacDevelopToolsPrefixHeader_h */
