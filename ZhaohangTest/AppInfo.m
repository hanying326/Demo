//
//  AppInfo.m
//  zhaohangPoc
//
//  Created by 寒影 on 11/12/2017.
//  Copyright © 2017 huang xiaoguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppInfo.h"
#import <CommonCrypto/CommonDigest.h>

@interface AppInfo ()

@end

@implementation AppInfo


+(instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static AppInfo * instance=nil;
    
    dispatch_once(&onceToken,^{
        instance=[[self alloc]init];
        
    });
    return instance;
}


-(NSString *)getAuthWithKey:(NSString *)key secret:(NSString *)secret{
    
    
    
    NSMutableArray *sign = [self getSHA1Encode:@"recoglive" withKey:key withSecret:secret];
    NSMutableString *auth = [[NSMutableString alloc]init];
    NSInteger count = [sign count];
    if(sign != nil && count ==2){
        
        [auth appendString:[NSString stringWithFormat:@"app_key=\"%@\"",key]];
        [auth appendString:[NSString stringWithFormat:@",nonce=\"%@\"",[sign objectAtIndex:0]]];
        [auth appendString:[NSString stringWithFormat:@",signature=\"%@\"",[sign objectAtIndex:1]]];
    }
    return auth;
}

-(NSMutableArray *)getSHA1Encode:(NSString *)requestType withKey:(NSString *)key withSecret:(NSString *)secret {
    
    NSMutableArray *result = [[NSMutableArray alloc]init];
    NSString *nonce = [self getRandomString:40];
    
    NSString *ha1 = [[self SHA1EncodeToHex:[NSString stringWithFormat:@"%@:xiaoi.com:%@",key,secret]] lowercaseString];
    NSString *ha2 = [[self SHA1EncodeToHex:[NSString stringWithFormat:@"POST:/%@",requestType]] lowercaseString];
    NSString *signature = [[self SHA1EncodeToHex:[NSString stringWithFormat:@"%@:%@:%@",ha1,nonce,ha2]] lowercaseString];
    
    [result addObject:nonce];
    [result addObject:signature];
    return result;
    
}
-(NSString *)getRandomString :(NSInteger)lenth{
    
    NSString *base = @"abcdefghijklmnopqrstuvwxyxABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *result = [[NSMutableString alloc]init];
    
    for (int i = 0; i< lenth; ++i){
        
        int x = arc4random() % base.length;
        UniChar ch = [base characterAtIndex:x];
        [result appendString:[NSString stringWithFormat:@"%C",ch]];
        
    }
    return result;
}

-(NSString *)SHA1EncodeToHex:(NSString *)origin{
    
    return [self sha1:origin];
}


- (NSString*) sha1:(NSString *)str
{
    const char *cstr = [str cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSData *data = [NSData dataWithBytes:cstr length:str.length];
    
    //使用对应的CC_SHA1,CC_SHA256,CC_SHA384,CC_SHA512的长度分别是20,32,48,64
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    //使用对应的CC_SHA256,CC_SHA384,CC_SHA512
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

- (NSString*) replaceUnicode:(NSString*)TransformUnicodeString
{
    NSString*tepStr1 = [TransformUnicodeString stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
    NSString*tepStr2 = [tepStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
    NSString*tepStr3 = [[@"\""  stringByAppendingString:tepStr2]stringByAppendingString:@"\""];
    NSData*tepData = [tepStr3  dataUsingEncoding:NSUTF8StringEncoding];
    NSString* axiba = [NSPropertyListSerialization    propertyListWithData:tepData options:NSPropertyListMutableContainers
                                                                    format:NULL error:NULL];
    return  [axiba    stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}


@end



