//
//  TTSViewController.m
//  ZhaohangTest
//
//  Created by 寒影 on 13/12/2017.
//  Copyright © 2017 xiaoi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTSViewController.h"
#import "TtsWithHttpController.h"


@interface TTSViewController ()<TtsControllerDelegate,AVAudioPlayerDelegate>
{
    
    BOOL inited;
    AVAudioPlayer *player;
    AudioStreamBasicDescription format;
    NSMutableData *audioData;
    UISwipeGestureRecognizer * recognizer;
    UIColor *backColor;
    UIColor *grayColor;
    
}

@property (nonatomic ,strong)TtsWithHttpController *ttsController;
@property (retain, nonatomic) IBOutlet UILabel *label;
@property (retain, nonatomic) IBOutlet UIButton *playBtn;
@property (retain, nonatomic) IBOutlet UITextView *questionView;

@end

@implementation TTSViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self initUI];
    _ttsController = [[TtsWithHttpController alloc]init];
    [self initPlayer];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


-(void)initUI{
    
    backColor =[UIColor colorWithRed:24/255.0 green:180/255.0 blue:237/255.0 alpha:1.0];
    grayColor =[UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:1.0];
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = backColor;
    }
    
    [_label setBackgroundColor :backColor];
    [_label setTextColor:[UIColor whiteColor]];
    
    _questionView.layer.borderWidth = 1;
    _questionView.layer.borderColor = backColor.CGColor;
    _questionView.layer.cornerRadius = 5;
    
    _playBtn.backgroundColor = backColor;
    _playBtn.tintColor = [UIColor whiteColor];
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.view addGestureRecognizer:recognizer];
    
}


- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    if(recognizer.direction == UISwipeGestureRecognizerDirectionDown) {
        [self.view endEditing:YES];
    }
}



- (void)initPlayer{
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
    format.mSampleRate = 22000.0f;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}


- (IBAction)playTTS:(id)sender {
    
    //     _playBtn.backgroundColor = grayColor;
    _playBtn.enabled = false;
    TTSSessionParams *params = [[TTSSessionParams alloc] init];
    params.baseURL = @"http://172.16.9.214:28182/cmb-proxy/synth?platform=android&userId=cmb";
    
    NSString *question = _questionView.text;
    
    if (question.length < 1){
        question = @"你好，我是小i机器人";
    }
    
    params.content = question;
    [_ttsController begin:params delegate:self];
    
    
}

-(void)onReceiveTTSAudioData:(NSData *)result{
    
    player = [[AVAudioPlayer alloc] initWithPcmData:result pcmFormat:format error:nil];
    player.delegate = self;
    [player play];
    
    //    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    //          _playBtn.backgroundColor = grayColor;
    //    }];
    
}


-(void)stopPlay {
    
    if ([player isPlaying]){
        [player stop];
    }
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    _playBtn.enabled = true;
    
    //    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    //        _playBtn.backgroundColor = backColor;
    //    }];
    
}


- (void)dealloc {
    [_label release];
    [_playBtn release];
    [_questionView release];
    [super dealloc];
}
@end
