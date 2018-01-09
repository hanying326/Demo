//
//  AppInfo.h
//  zhaohangPoc
//
//  Created by 寒影 on 11/12/2017.
//  Copyright © 2017 huang xiaoguang. All rights reserved.
//

#ifndef AppInfo_h
#define AppInfo_h
#endif /* AppInfo_h */
#import <AVFoundation/AVFoundation.h>

@interface AppInfo : NSObject

@property (nonatomic,strong)NSString *languageType;

@property (nonatomic,strong)NSString *appKey;
@property (nonatomic,strong)NSString *appSecret;

+(instancetype)shareInstance;


-(NSString *)getAuthWithKey:(NSString *)key secret:(NSString *)secret;

@end



