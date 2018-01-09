//
//  AsrViewController.m
//  ZhaohangTest
//
//  Created by 寒影 on 13/12/2017.
//  Copyright © 2017 xiaoi. All rights reserved.
//

#include "interf_dec.h"
#include "interf_enc.h"
#import <Foundation/Foundation.h>
#import "AsrViewController.h"
#import "AsrWithHttpController.h"
#import "AsrWithWebSocketController.h"
#import "MCAudioInputQueue.h"
#import "amrFileCodec.h"
#import "AppInfo.h"

#define MAX_AMR_FRAME_SIZE 32
static const NSTimeInterval bufferDuration = 0.02;
static  enum Mode req_mode = MR122;

#define HTTPMODE 1
#define WEBSOCKETMODE 2

@interface AsrViewController()<AsrWithHttpDelegate,MCAudioInputQueueDelegate,AsrWithWebSocketDelegate>
{
    
    AudioStreamBasicDescription format;
    MCAudioInputQueue *recorder;
    BOOL inited;
    BOOL started;
    int byte_counter;
    int frames;
    int bytes;
    void *enstate;
    NSMutableData *audioData;
    
    NSInteger  requestMode;
    
}

@property (nonatomic ,strong)AsrWithWebSocketController *socketController;
@property (nonatomic ,strong)AsrWithHttpController *asrHttpController;
@property (retain, nonatomic) IBOutlet UIButton *recordBtn;
@property (retain, nonatomic) IBOutlet UITextView *resultView;
@property (retain, nonatomic) IBOutlet UILabel *label;
@property (retain, nonatomic) IBOutlet UIButton *webSocketBtn;

@end

@implementation  AsrViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    _asrHttpController = [[AsrWithHttpController alloc]init];
    [self initRecorder];
    
}

-(void)initUI{
    
    UIColor *backColor =[UIColor colorWithRed:24/255.0 green:180/255.0 blue:237/255.0 alpha:1.0];
    
    //    CGRect rx = [ UIScreen mainScreen ].bounds;
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = backColor;
    }
    
    [_label setBackgroundColor :backColor];
    [_label setTextColor:[UIColor whiteColor]];
    
    [_resultView setEditable: false];
    _resultView.layer.borderWidth = 1;
    _resultView.layer.borderColor = backColor.CGColor;
    _resultView.layer.cornerRadius = 5;
    
    _recordBtn.backgroundColor = backColor;
    _recordBtn.tintColor = [UIColor whiteColor];
    
    _webSocketBtn.backgroundColor = backColor;
    _webSocketBtn.tintColor = [UIColor whiteColor];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (void)initRecorder
{
    if (inited)
    {
        return;
    }
    
    inited = YES;
    format.mFormatID = kAudioFormatLinearPCM;
    format.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    format.mBitsPerChannel = 16;
    format.mChannelsPerFrame = 1;
    format.mBytesPerPacket = format.mBytesPerFrame = (format.mBitsPerChannel / 8) * format.mChannelsPerFrame;
    format.mFramesPerPacket = 1;
    format.mSampleRate = 8000.0f;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}



- (void)startRecord
{
    if (started)
    {
        return;
    }
    
    started = YES;
    recorder = [MCAudioInputQueue inputQueueWithFormat:format bufferDuration:bufferDuration delegate:self];
    recorder.meteringEnabled = YES;
    [recorder start];
    
}

- (void)stopRecord
{
    if (!started)
    {
        return;
    }
    started = NO;
    
    [recorder stop];
    recorder = nil;
}


-(void)startAsrWithWebSocket{
    
    [AppInfo shareInstance].appKey = @"xiaoirecdemo";
    [AppInfo shareInstance].appSecret = @"xiaoirecdemo";
    
    _socketController = [AsrWithWebSocketController share];
    AsrSessionParams *params = [[AsrSessionParams alloc]init];
    params.baseURL = @"ws://172.16.9.214:28182/cmb-proxy/recoglive";
    
    [_socketController initSocket:params delegate:self];
}


-(void)startAsrWithHttp{
    
    enstate = Encoder_Interface_init(0);
    requestMode = HTTPMODE;
    [self startRecord];
    
}

- (IBAction)touchDown:(id)sender {
    
    audioData = [[NSMutableData alloc]init];
    [self startAsrWithHttp];
}


- (IBAction)touchUp:(id)sender {
    
    Encoder_Interface_exit(enstate);
    [self stopRecord];
    
    AsrSessionParams *params = [[AsrSessionParams alloc]init];
    params.baseURL = @"http://172.16.9.214:28182/cmb-proxy/rec";
    params.audioData  = audioData;
    [_asrHttpController begin:params delegate:self];
    
}

- (IBAction)wsTouchDown:(id)sender {
    
    [self startAsrWithWebSocket];
    
}

- (IBAction)wsTouchUp:(id)sender {
    
    Encoder_Interface_exit(enstate);
    
    [self stopRecord];
    [_socketController stopSendAudio];
}


- (void)inputQueue:(MCAudioInputQueue *)inputQueue inputData:(NSData *)data numberOfPackets:(UInt32)numberOfPackets{
    
    char *charData;
    if (data)
    {
        charData = [data bytes];
    }
    
    short speech[160];
    unsigned char amrFrame[MAX_AMR_FRAME_SIZE];
    int nRead = ReadPCMFrameData(speech, charData, 1, 16);
    byte_counter = Encoder_Interface_Encode(enstate, req_mode, speech, amrFrame, 0);
    NSData  *tempData =[NSData dataWithBytes:amrFrame length:byte_counter];
    [inputQueue updateMeters];
    
    if (requestMode == HTTPMODE){
        [audioData appendData:tempData];
    }
    
    else if (requestMode == WEBSOCKETMODE){
        [_socketController sendAudio:tempData];
    }
}


-(void)onReceiveAsrResult:(NSString *)result{
    
    NSLog(@"onReceiveAsrResult");
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _resultView.text = result;
    }];
}


-(void)onReceiveResult:(NSString *)result{
    
    NSData *rsultData = [result dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:rsultData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    NSLog(@"%@",dic);
    
    NSString *response = [dic objectForKey:@"response"];
    NSString *state = [dic objectForKey:@"state"];
    NSString *msg = [dic objectForKey:@"msg"];
    msg = [self replaceUnicode:msg];
    
    NSLog(@"%@",msg);
    
    if ([response isEqualToString:@"ExtAuth"] && [state isEqualToString:@"success"] ){
        
        requestMode = WEBSOCKETMODE;
        enstate = Encoder_Interface_init(0);
        [self startRecord];
        
    }
    
    else if ([response isEqualToString:@"result"]&& [state isEqualToString:@"success"]){
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            _resultView.text = msg;
        }];
    }
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


- (void)dealloc {
    [_recordBtn release];
    [_resultView release];
    [_label release];
    [_webSocketBtn release];
    [super dealloc];
}
@end




