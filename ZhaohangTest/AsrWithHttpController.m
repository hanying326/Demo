//
//  AsrDemoController.m
//  zhaohangPoc
//
//  Created by 寒影 on 08/12/2017.
//  Copyright © 2017 huang xiaoguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsrWithHttpController.h"
#import "AppInfo.h"
#import "AsrWithWebSocketController.h"

@interface AsrWithHttpController()<NSURLSessionDelegate,NSURLSessionTaskDelegate>
{
    NSMutableData *audioData;
}

@end

@implementation AsrWithHttpController


-(bool)begin:(AsrSessionParams *)params delegate:(id<AsrWithHttpDelegate>)delegate{

    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    NSURL *url = [NSURL URLWithString:params.baseURL];
    
    NSMutableURLRequest *request=[self initRequestParams:url];
    
    [request addValue:[NSString stringWithFormat:@"%lu",params.audioData.length] forHTTPHeaderField:@"Content-Length"];
    request.HTTPBody = params.audioData;
    
    NSURLSession *session=[NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        NSString *result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        [delegate onReceiveAsrResult:result];
  
    }];
    [dataTask resume];
    
    return  true;
}



-(NSMutableURLRequest *)initRequestParams:(NSURL *)url{
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    
    request.HTTPMethod=@"POST";
    [request addValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
    [request addValue:@"application/audio" forHTTPHeaderField:@"Content-Type"];
    NSString *auth = [[AppInfo shareInstance] getAuthWithKey:@"xiaoirecdemo" secret:@"xiaoirecdemo"];
    [request addValue:auth forHTTPHeaderField:@"X-AUTH"];
    [request addValue:@"amr" forHTTPHeaderField:@"X-ENCODE"];
    [request addValue:@"cmn-CHN" forHTTPHeaderField:@"X-LANG"];
    [request addValue:@"8000" forHTTPHeaderField:@"X-SAMPLERATE"];
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];

    return  request;
}

-(void)appendData:(NSData *)data{
 
    
}

@end

@implementation AsrSessionParams

@end


