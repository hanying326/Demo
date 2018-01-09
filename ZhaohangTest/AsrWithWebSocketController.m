//
//  WebSocket.m
//  VoiceDemo
//
//  Created by 寒影 on 14/08/2017.
//  Copyright © 2017 xiaoi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsrWithWebSocketController.h"
#import <CommonCrypto/CommonDigest.h>
#import "AppInfo.h"


@interface AsrWithWebSocketController()<SRWebSocketDelegate>
{
    
    SRWebSocket * webSocket;
    
    NSString *modelStr;
    NSString *language;
    NSString *sessionId;
    NSString * languageType;
    
}

@property (nonatomic,strong)NSMutableArray *loadInfos;



@end

@implementation AsrWithWebSocketController

+(instancetype)share
{
    static dispatch_once_t onceToken;
    static AsrWithWebSocketController * instance=nil;
    
    dispatch_once(&onceToken,^{
        instance=[[self alloc]init];
        
    });
    return instance;
}


-(void)initSocket:(AsrSessionParams *)params delegate:(id<AsrWithWebSocketDelegate>) delegate
{
    
    [webSocket close];
    if ([self checkUrl:params.baseURL]){
        
        NSLog(@"%@",params.baseURL);
        
        webSocket = [[SRWebSocket alloc]initWithURL:[NSURL URLWithString:params.baseURL]];
        webSocket.delegate = self;
        
        self.delegate = delegate;
        
        NSOperationQueue * queue=[[NSOperationQueue alloc]init];
        queue.maxConcurrentOperationCount=1;
        [webSocket setDelegateOperationQueue:queue];
        
        [webSocket open];
        
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    
    [self extAuth];
}




- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    
  
    
    NSLog(@"didFailWithError:%@",error.description);
    
    
}


-(void)extAuth{
    
    NSString *auth = [[AppInfo shareInstance] getAuthWithKey:[AppInfo shareInstance].appKey secret:[AppInfo shareInstance].appSecret];
    NSInteger rate = 8000;
    id b = @(rate);
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                @"ExtAuth",            @"method",
                                auth,                  @"X-Auth",
                                b,                     @"samplingRate",
                                @"amr",                @"binEncode",
                                @"cmn-CHN",            @"language",
                                nil];
    
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *str = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    [webSocket send:str];
}


- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    
    NSLog(@"didCloseWithCode");
    
}


-(void)sendMsg:(NSString *)msg
{
    [webSocket send:msg];
}


-(void)sendAudio:(id)msg
{
    [webSocket send:msg];
}


- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSString *result ;
    
    if ( [message isKindOfClass:[NSString class]] ) {
        result = message;
        
        [self.delegate onReceiveResult:result];
        
    }
}

-(NSString *)uuidString
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}


-(void)createSession{
    
    sessionId = [self uuidString];
    NSString *requestId = [self uuidString];
    NSMutableDictionary *languagePack = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         @"cmn-CHN",      @"language",
                                         @"topic",       @"travel",
                                         nil];
    
    if ([[AppInfo shareInstance].languageType isEqualToString:@"wuu-CHN"]){
        [languagePack setValue:@"wuu-CHN" forKey:@"language"];
    }
    
    NSDictionary *clientData = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"COMPANY",        @"companyName",
                                @"APPLICATION",    @"applicationName",
                                @"d.e.f",          @"applicationVersion",
                                nil];
    
    NSDictionary *sessionParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"1s",                        @"detachedTimeout",
                                       @"3600s",                     @"idleTimeout",
                                       @"audio/L16;rate=8000",       @"audioFormat",
                                       nil];
    
    id boolNumber = [NSNumber numberWithBool:false];
    NSDictionary *recognitionParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                           boolNumber,      @"startRecognitionTimers",
                                           nil];
    
    boolNumber = [NSNumber numberWithBool:true];
    
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"CreateSession",           @"method",
                         @"1.0",                     @"version",
                         sessionId,                  @"sessionId",
                         requestId,                  @"requestId",
                         boolNumber,                 @"attach",
                         languagePack,               @"languagePack",
                         clientData,                 @"clientData",
                         sessionParameters,          @"sessionParameters",
                         recognitionParameters,      @"recognitionParameters",
                         nil];
    
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    [webSocket send:jsonData];
    
}


-(void)endOfInput{
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"EndOfInput",                   @"method",
                         nil];
    
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *str = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    [webSocket send:str];
}


-(void)closeSocket{
    
    [webSocket close];
    
}



-(bool) checkUrl:(NSString *)url{
    
    
    if (url != nil && url.length >1){
        
        NSURL *temp = [NSURL URLWithString:url];
        NSString *scheme = temp.scheme.lowercaseString;
        
        if (temp != nil){
            
            if ([scheme isEqualToString:@"wss"] || [scheme isEqualToString:@"ws"]) {
                
                return true;
                
            }
            
            
        }
    }
    
    
    return false;
    
}


-(void)stopSendAudio{
    
    
    [self endOfInput];
    
    
}




@end



































