//
//  ViewController.m
//  TestSpeech
//
//  Created by CyonLeuMBP on 2016/11/11.
//  Copyright © 2016年 CyonLeuMBP. All rights reserved.
//

#import "ViewController.h"

#import <Speech/Speech.h>


@interface ViewController ()
    @property (weak, nonatomic) IBOutlet UIButton *strartRecordButton;
    @property (weak, nonatomic) IBOutlet UIButton *stopRecordButton;
    @property (weak, nonatomic) IBOutlet UITextView *resultTextView;
    
    @property (strong, nonatomic) AVAudioRecorder *recorder;
    @property (strong, nonatomic) NSString *fullPath;
    @property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
    @property (strong, nonatomic) NSLocale *locale;//
    @property (weak, nonatomic) IBOutlet UISegmentedControl *laungeSegmentControl;
    
    

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupRecorder];//初始化录音
    self.locale = [NSLocale currentLocale];
    [self.laungeSegmentControl addTarget:self action:@selector(languageValueChanged:) forControlEvents:UIControlEventValueChanged];
        //申请用户语音识别权限
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        
        if (status == SFSpeechRecognizerAuthorizationStatusAuthorized) {
                //允许使用
            
        }
    }];

}

#pragma mark - Private Method
    
- (void)setupRecorder {
    NSString *dir = [[self getDirectoryDocuments] stringByAppendingPathComponent:@"recorderDir"];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if (![fileMgr fileExistsAtPath:dir]) {
        [self createDirectory:dir];
    }
    
    NSString *audioName = [NSString  stringWithFormat:@"recorderFile.caf"];
    NSString *fullPath = [dir stringByAppendingPathComponent:audioName];
    self.fullPath = fullPath;
    
    NSArray *pathComponents = [NSArray arrayWithObjects: fullPath,nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
        // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
        // Initiate and prepare the recorder
    self.recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:nil];
        //    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
        // 获取Documents目录路径
- (NSString *)getDirectoryDocuments
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        return documentsDirectory;
    }
    
        // 创建文件夹
- (BOOL)createDirectory:(NSString *) pathDirectory
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
            // 创建目录
        BOOL res=[fileManager createDirectoryAtPath:pathDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        if (res) {
            NSLog(@"文件夹创建成功");
        } else {
            NSLog(@"文件夹创建失败");
            return NO;
        }
        
        return YES;
    }
    
#pragma mark - Event 
    
- (void)languageValueChanged:(UISegmentedControl *)segmentControl {
    if (segmentControl.selectedSegmentIndex == 0) {
            //中文
        self.locale = [[NSLocale alloc]initWithLocaleIdentifier:@"zh-Hans"];
    } else {
            //英语
        self.locale = [[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
    }
}
    
- (IBAction)onStartButton:(id)sender {
    
    __weak typeof (self) weakSelf = self;
        //创建语音识别操作类对象
    SFSpeechRecognizer * rec = [[SFSpeechRecognizer alloc] initWithLocale:self.locale];
    NSURL *fileUrl = [NSURL fileURLWithPath:self.fullPath];
        //通过一个音频路径创建音频识别请求
    SFSpeechRecognitionRequest * request = [[SFSpeechURLRecognitionRequest alloc] initWithURL:fileUrl];
        //进行请求
    
    if (!rec.isAvailable) {
        [self.activityView stopAnimating];
        NSLog(@"SFSpeechRecognizer 不可用");
        return;
    }
    
    [self.activityView startAnimating];
    [rec recognitionTaskWithRequest:request resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        [weakSelf.activityView stopAnimating];

            //打印语音识别的结果字符串
        NSLog(@"%@",result.bestTranscription.formattedString);
        
   
        weakSelf.resultTextView.text = result.bestTranscription.formattedString;
            
        if (result.isFinal) {
            //识别完成；
            [weakSelf.activityView stopAnimating];
        }
        
   
    }];
    
    
}
    
- (IBAction)onStopButton:(id)sender {
}
    
    
    
- (IBAction)onStartRecorderButton:(id)sender {
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session setActive:YES error:nil];
    [self.recorder record];
    
    [self.activityView startAnimating];
}
    
    
- (IBAction)onStopRecorderButton:(id)sender {
    [self.recorder stop];
    
    [self onStartButton:nil];
    
}
    
    
    
    
    


@end
