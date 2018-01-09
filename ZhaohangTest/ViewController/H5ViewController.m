//
//  H5ViewController.m
//  ZhaohangTest
//
//  Created by 寒影 on 14/12/2017.
//  Copyright © 2017 xiaoi. All rights reserved.
//
#include "interf_dec.h"
#include "interf_enc.h"
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "H5ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

#import "AsrWithHttpController.h"
#import "TtsWithHttpController.h"
#import "MCAudioInputQueue.h"
#import "amrFileCodec.h"


#define MAX_AMR_FRAME_SIZE 32
static const NSTimeInterval bufferDuration = 0.02;
static  enum Mode req_mode = MR122;

@interface H5ViewController()<TtsControllerDelegate,WKUIDelegate,WKScriptMessageHandler,WKNavigationDelegate,MCAudioInputQueueDelegate,AsrWithHttpDelegate,AVAudioPlayerDelegate>{
    
    AudioStreamBasicDescription format;
    MCAudioInputQueue *recorder;
    BOOL inited;
    
    BOOL started;
    int byte_counter;
    int frames;
    int bytes;
    void *enstate;
    NSMutableData *audioData;
    AVAudioPlayer *player;
    
}

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic ,strong)AsrWithHttpController *asrHttpController;
@property (nonatomic ,strong)TtsWithHttpController *ttsHttpController;

@end

@implementation H5ViewController

-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    
    NSString *path = [[[NSBundle mainBundle] bundlePath]  stringByAppendingPathComponent:@"app.html"];
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    
    config.preferences = [[WKPreferences alloc] init];
    config.preferences.javaScriptEnabled = YES;
    config.processPool = [[WKProcessPool alloc] init];
    config.userContentController = [[WKUserContentController alloc] init];
    
    [config.userContentController addScriptMessageHandler:self name:@"startAsr"];
    [config.userContentController addScriptMessageHandler:self name:@"sendTtsText"];
    [config.userContentController addScriptMessageHandler:self name:@"endAsr"];
    
    CGRect cr = self.view.bounds;
    CGRect rect = CGRectMake(0, 0, cr.size.width, cr.size.height -49);
    
    self.webView = [[WKWebView alloc] initWithFrame:rect configuration:config];
    
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://172.16.9.214:28182/cmb-proxy/app/ios.html"]]];
    
    //        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
    _asrHttpController = [[AsrWithHttpController alloc]init];
    _ttsHttpController = [[TtsWithHttpController alloc]init];
    
    [self initAudio];
    
}



- (void)initAudio
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



-(void)initJSToWebView{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    NSLog(@"%@",message.name);
    [self event:message];
    
}



- (void)startRecord
{
    if (started)
    {
        return;
    }
    
    started = YES;
    format.mSampleRate = 8000.0f;
    
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


-(void)event:(WKScriptMessage *)message{
    
    NSString *name = message.name;
    
    if ([name isEqualToString:@"startAsr"]){
        
        audioData = [[NSMutableData alloc]init];
        enstate = Encoder_Interface_init(0);
        [self startRecord];
    }
    
    
    else  if ([name isEqualToString:@"endAsr"]){
        
        AsrSessionParams *params = [[AsrSessionParams alloc]init];
        params.baseURL = @"http://172.16.9.214:28182/cmb-proxy/rec";
        params.audioData  = audioData;
        [_asrHttpController begin:params delegate:self];
        
    }
    
    
    else  if ([name isEqualToString:@"sendTtsText"]){
        
        NSString *body = message.body;
        
        TTSSessionParams *params = [[TTSSessionParams alloc] init];
        params.baseURL = @"http://172.16.9.214:28182/cmb-proxy/synth?platform=android&userId=cmb";
        
        NSString *question = body;
        
        //        if (question.length < 1){
        //            question = @"你好，我是xiaoi机器人";
        //        }
        
        params.content = question;
        [_ttsHttpController begin:params delegate:self];
        
    }
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
    
    [audioData appendData:tempData];
    
}



-(void)onReceiveTTSAudioData:(NSData *)result{
    
    format.mSampleRate = 22000.0f;
    player = [[AVAudioPlayer alloc] initWithPcmData:result pcmFormat:format error:nil];
    player.delegate = self;
    [player play];
}


-(void)onReceiveAsrResult:(NSString *)result{
    
    NSString *functionName = [NSString stringWithFormat:@"showText('%@')",result];
    [self.webView evaluateJavaScript:functionName completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        
    }];
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    [self.webView evaluateJavaScript:@"endTts()" completionHandler:nil];
}


- (void)dealloc {
    [super dealloc];
}
@end


