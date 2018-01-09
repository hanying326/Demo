//
//  WebSocket.h
//  VoiceDemo
//
//  Created by 寒影 on 14/08/2017.
//  Copyright © 2017 xiaoi. All rights reserved.
//

#ifndef WebSocket_h
#define WebSocket_h
#endif /* WebSocket_h */
#import "SRWebSocket.h"
#import "AsrWithHttpController.h"


@protocol AsrWithWebSocketDelegate<NSObject>


-(void)onReceiveResult:(NSString *)result;


@end


@interface AsrWithWebSocketController :NSObject



@property (nonatomic,strong)id<AsrWithWebSocketDelegate> delegate;


+ (instancetype)share;

-(void)initSocket:(AsrSessionParams *)params delegate:(id<AsrWithWebSocketDelegate>) delegate;

-(void)sendMsg:(NSString *)msg;
-(void)sendAudio:(id)audio;

-(void)closeSocket;
-(void)stopSendAudio;


@end















