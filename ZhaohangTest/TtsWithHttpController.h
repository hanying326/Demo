//
//  TtsDemoController.h
//  zhaohangPoc
//
//  Created by 寒影 on 08/12/2017.
//  Copyright © 2017 huang xiaoguang. All rights reserved.
//

#ifndef TtsDemoController_h
#define TtsDemoController_h
#endif /* TtsDemoController_h */
#import <AVFoundation/AVFoundation.h>

@protocol TtsControllerDelegate<NSObject>

-(void)onReceiveTTSAudioData:(NSData *)result;

@end



@interface TTSSessionParams : NSObject

@property (nonatomic, strong) NSString          *content;
@property (nonatomic, strong) NSString          *baseURL;
@property (nonatomic, assign) NSString          *speechType;
@property (nonatomic, strong) NSString          *userID;
@property (nonatomic, strong) NSString          *platform;

@end

@interface TtsWithHttpController : NSObject

@property (nonatomic,strong)id<TtsControllerDelegate> delegate;

- (BOOL)begin:(TTSSessionParams *)params delegate:(id<TtsControllerDelegate>)delegate;
-(void) realTimeTTS:(TTSSessionParams *)params delegate:(id<TtsControllerDelegate>)delegate;


@end

