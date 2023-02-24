//
//  JKGoControlNetworkRoute.h
//  jkgocontrol
//
//  Created by jk on 2022/5/20.
//

#ifndef JKGoControlNetworkRoute_h
#define JKGoControlNetworkRoute_h


#define kRoute_Auth(__host) [NSString stringWithFormat:@"%@/control/auth",__host]
#define kRoute_Action(__host) [NSString stringWithFormat:@"%@/control",__host]

typedef enum : NSUInteger {
    JKGoControlResponseCode_LocalNetworkError = -1,
    JKGoControlResponseCode_LocalNotRequestYet = 0,
    
    JKGoControlResponseCode_Suc = 10000,
    JKGoControlResponseCode_DataStruct,
    JKGoControlResponseCode_NoSuchActionPath,
    JKGoControlResponseCode_UnsupportAction,
    
    JKGoControlResponseCode_UnexpectedException = 20000,
    
    JKGoControlResponseCode_AuthDeny  = 40000,
    JKGoControlResponseCode_AuthSeqDeny  = 40001,
    JKGoControlResponseCode_SecretDeny  = 99999,
} JKGoControlResponseCode;

#endif /* JKGoControlNetworkRoute_h */
