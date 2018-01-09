//
//  AVAudioPlayer+PCM.h
//  PcmDataPlayer
//
//  Created by Chengyin on 14-12-25.
//  Copyright (c) 2014年 Chengyin. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVAudioPlayer (PCM)


- (instancetype)initWithPcmData:(NSData *)pcmData pcmFormat:(AudioStreamBasicDescription)format error:(NSError **)outError;


@end
