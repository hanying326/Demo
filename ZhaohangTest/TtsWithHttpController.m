//
//  TtsDemoController.m
//  zhaohangPoc
//
//  Created by 寒影 on 08/12/2017.
//  Copyright © 2017 huang xiaoguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TtsWithHttpController.h"
#import "AppInfo.h"


@interface TtsWithHttpController()<NSURLConnectionDelegate,NSURLConnectionDataDelegate>

@end

@implementation TtsWithHttpController

- (BOOL)begin:(TTSSessionParams *)params delegate:(id<TtsControllerDelegate>)delegate{
    
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    
    NSURL *url = [NSURL URLWithString:params.baseURL];
    NSMutableURLRequest * request = [self initRequestParams:url];
    
    NSData *questionData = [params.content dataUsingEncoding:NSUTF8StringEncoding];
    [request addValue:[NSString stringWithFormat:@"%lu", questionData.length] forHTTPHeaderField:@"Content-length"];
    [request setHTTPBody:questionData];
    
    NSURLSession *session=[NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        [delegate onReceiveTTSAudioData:data];
        
    }];
    [dataTask resume];
    return true;
    
}

-(NSMutableURLRequest *)initRequestParams:(NSURL *)url {
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    request.timeoutInterval = 5;
    [request addValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
    [request addValue:@"PCM" forHTTPHeaderField:@"X-AUE"];
    [request addValue:@"utf-8" forHTTPHeaderField:@"X-TXE"];
    [request addValue:@"audio/L16;rate=8000" forHTTPHeaderField:@"X-AUF"];
    [request addValue:@"Li-sa" forHTTPHeaderField:@"X-AUT"];
    [request addValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    return  request;
}


-(void) realTimeTTS:(TTSSessionParams *)params delegate:(id<TtsControllerDelegate>)delegate{
    
    self.delegate = delegate;
    
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    NSURL *url = [NSURL URLWithString:params.baseURL];
    NSMutableURLRequest * request = [self initRequestParams:url];
    NSData *questionData = [params.content dataUsingEncoding:NSUTF8StringEncoding];
    [request addValue:[NSString stringWithFormat:@"%lu", questionData.length] forHTTPHeaderField:@"Content-length"];
    [request setHTTPBody:questionData];
    
    NSURLConnection *connection  = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [connection start];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
      [self.delegate onReceiveTTSAudioData:data];
    
}


@end

@implementation TTSSessionParams

@end





