//
//  ViewController.m
//  AVAdioRecordPlayer
//
//  Created by mac03 on 16/1/20.
//  Copyright © 2016年 SY. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

enum
{
    ENC_AAC = 1,
    ENC_ALAC = 2,
    ENC_IMA4 = 3,
    ENC_ILBC = 4,
    ENC_ULAW = 5,
    ENC_PCM = 6,
} encodingTypes;

@interface ViewController ()
{
    AVAudioPlayer *audioPlayer;
    AVAudioRecorder *audioRecorder;
    int recordEncoding;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
 
    CGFloat kbtnW = 200;
    CGFloat kbtnH = 40;
    CGFloat kMargin = 30;
    NSArray * titles =  @[@"startRecord",@"stratPlay",@"startStop"];


    for (int i = 0; i <titles.count; i++) {
     
        UIButton * button = [UIButton new];
        button.frame = CGRectMake(kMargin, i*(kbtnH+kMargin)+kMargin, kbtnW, kbtnH);
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        switch (i) {
            case 0:{
            [button addTarget:self action:@selector(startRecording) forControlEvents:UIControlEventTouchDown];
            [button addTarget:self action:@selector(stopRecording) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(stopRecording) forControlEvents:UIControlEventTouchUpOutside];
            }
                break;
           
            case 1:
            [button addTarget:self action:@selector(playRecording) forControlEvents:UIControlEventTouchUpInside];
                 break;
            case 2:
                [button addTarget:self action:@selector(stopPlaying) forControlEvents:UIControlEventTouchUpInside];
                 break;
            default:
                break;
        }
   
        [self.view addSubview:button];
        
    }
}



-(void) startRecording
{

    audioRecorder = nil;

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] initWithCapacity:10];
    if(recordEncoding == ENC_PCM)
    {
        [recordSettings setObject:[NSNumber numberWithInt: kAudioFormatLinearPCM] forKey: AVFormatIDKey];//音乐格式
        [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];//音乐采样率
        [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];//音乐通道
        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        //音乐比特率
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    }
    else
    {
        NSNumber *formatObject;
        
        switch (recordEncoding) {
            case (ENC_AAC):
                formatObject = [NSNumber numberWithInt: kAudioFormatMPEG4AAC];
                break;
            case (ENC_ALAC):
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleLossless];
                break;
            case (ENC_IMA4):
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
                break;
            case (ENC_ILBC):
                formatObject = [NSNumber numberWithInt: kAudioFormatiLBC];
                break;
            case (ENC_ULAW):
                formatObject = [NSNumber numberWithInt: kAudioFormatULaw];
                break;
            default:
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
        }
        
        [recordSettings setObject:formatObject forKey: AVFormatIDKey];//ID
        [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];//采样率
        [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];//通道的数目,1单声道,2立体声
        [recordSettings setObject:[NSNumber numberWithInt:12800] forKey:AVEncoderBitRateKey];//解码率
        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];//采样位
        [recordSettings setObject:[NSNumber numberWithInt: AVAudioQualityHigh] forKey: AVEncoderAudioQualityKey];
    }
    
    NSString * urlStr = [NSString stringWithFormat:@"%@/recordTest.caf", [[NSBundle mainBundle] resourcePath]];
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    
    NSLog(@"%@",urlStr);
    NSError *error = nil;
    audioRecorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&error];
    
    if ([audioRecorder prepareToRecord] == YES){
        [audioRecorder record];
    }else {
        int errorCode = CFSwapInt32HostToBig ([error code]);
        NSLog(@"Error: %@ [%4.4s])" , [error localizedDescription], (char*)&errorCode);
        
    }
    NSLog(@"recording");
}

-(void) stopRecording
{
    NSLog(@"stopRecording");
    [audioRecorder stop];
}

-(void) playRecording
{
    NSLog(@"playRecording");
    // Init audio with playback capability
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/recordTest.caf", [[NSBundle mainBundle] resourcePath]]];
    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    audioPlayer.numberOfLoops = 0;
    [audioPlayer play];
   
}

-(void) stopPlaying
{
    NSLog(@"stopPlaying");
    [audioPlayer stop];
}


@end
