//
//  AsrDemoController.h
//  zhaohangPoc
//
//  Created by 寒影 on 08/12/2017.
//  Copyright © 2017 huang xiaoguang. All rights reserved.
//

#ifndef AsrDemoController_h
#define AsrDemoController_h
#endif /* AsrDemoController_h */
#import <AVFoundation/AVFoundation.h>

@protocol AsrWithHttpDelegate<NSObject>

-(void)onReceiveAsrResult:(NSString *)result;

@end

@interface AsrSessionParams : NSObject

@property (nonatomic, strong) NSString          *content;
@property (nonatomic, strong) NSString          *baseURL;
@property (nonatomic, strong) NSString          *userID;
@property (nonatomic, strong) NSString          *platform;
@property (nonatomic, strong) NSData            *audioData;

@end

@interface  AsrWithHttpController: NSObject

@property(nonatomic,strong)NSString *baseUrl;

-(bool)begin:(AsrSessionParams *)params  delegate:(id<AsrWithHttpDelegate>)delegate;
-(void)appendData:(NSData *)data;

@end
