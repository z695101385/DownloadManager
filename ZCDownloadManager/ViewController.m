//
//  ViewController.m
//  ZCDownloadManager
//
//  Created by 张晨 on 16/6/14.
//  Copyright © 2016年 zhangchen. All rights reserved.
//

#import "ViewController.h"
#import "ZCDownloadManager.h"

#define ZCCachesPath  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"111"]

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *one;
@property (weak, nonatomic) IBOutlet UIButton *two;
@property (weak, nonatomic) IBOutlet UIProgressView *oneProgressView;
@property (weak, nonatomic) IBOutlet UIProgressView *twoProgressView;
/** url数组 */
@property (nonatomic, strong) NSArray *urls;

@end

@implementation ViewController
//矩阵懒加载
- (NSArray *)urls
{
    if (!_urls) {
        _urls = @[@{@"url":@"http://120.25.226.186:32812/resources/videos/minion_01.mp4",
                    @"btn":_one,
                    @"progress":_oneProgressView},
                  @{@"url":@"http://120.25.226.186:32812/resources/videos/minion_02.mp4",
                    @"btn":_two,
                    @"progress":_twoProgressView},];
    }
    return _urls;
}


- (IBAction)downloadOne:(id)sender {
    
    [self downloadTaskOfIndex:0];
    
}

- (IBAction)downloadTwo:(id)sender {
    
    [self downloadTaskOfIndex:1];
    
}

- (IBAction)deleteOne:(id)sender {
    
    [self deleteTaskOfIndex:0];
    
}

- (IBAction)deleteTwo:(id)sender {
    
    [self deleteTaskOfIndex:1];
}
//根据index添加下载任务
- (void)downloadTaskOfIndex:(NSInteger)index
{
    
    NSString *url = self.urls[index][@"url"];
    
    UIProgressView *pv = self.urls[index][@"progress"];
    
    UIButton *btn = self.urls[index][@"btn"];
    
    [[ZCDownloadManager sharedInstance] downloadTaskWithURL:url
                                                     toPath:ZCCachesPath
                                                   progress:^(float progress) {
                                                       [pv setProgress:progress];
                                                   }
                                                      state:^(ZCDownloadTaskState state) {
                                                          [self resetButton:btn byState:state];
                                                      }
                                                 completion:^(NSError *error, NSString *filePath) {
                                                     NSLog(@"%@",filePath);
                                                 }];
}
//根据index删除下载文件
- (void)deleteTaskOfIndex:(NSInteger)index
{
    NSString *url = self.urls[index][@"url"];
    
    UIProgressView *pv = self.urls[index][@"progress"];
    
    UIButton *btn = self.urls[index][@"btn"];
    
    [[ZCDownloadManager sharedInstance] removeTaskWithURL:url preserveFile:NO];
    
    [pv setProgress:0.0];
    
    [self resetButton:btn byState:ZCDownloadTaskStateBeforeRun];
}

- (void)viewDidLoad
{
    //启动时检测文件下载状态
    [self setUpBtnAndprogress];
}


- (void)setUpBtnAndprogress
{
    for (NSInteger i = 0; i < self.urls.count; i++) {
        
        NSString *url = self.urls[i][@"url"];
        
        UIProgressView *pv = self.urls[i][@"progress"];
        
        UIButton *btn = self.urls[i][@"btn"];
        
        [pv setProgress:[[ZCDownloadManager sharedInstance] taskWithURL:url].progress];
        
        [self resetButton:btn byState:[[ZCDownloadManager sharedInstance] taskWithURL:url].state];
    }
    
}
//根据下载状态设置按钮标题
- (void)resetButton:(UIButton *)btn byState:(ZCDownloadTaskState)state
{
    if (state == ZCDownloadTaskStateBeforeRun) {
        [btn setTitle:@"开始" forState:UIControlStateNormal];
    }else if (state == ZCDownloadTaskStateRunning) {
        [btn setTitle:@"暂停" forState:UIControlStateNormal];
    }else if (state == ZCDownloadTaskStateSuspended) {
        [btn setTitle:@"继续" forState:UIControlStateNormal];
    }else if (state == ZCDownloadTaskStateCompleted) {
        [btn setTitle:@"完成" forState:UIControlStateNormal];
    }
}

@end
