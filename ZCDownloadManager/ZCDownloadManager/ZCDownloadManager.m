//
//  ZCDownloadManager.m
//  palynet
//
//  Created by 张晨 on 16/6/14.
//  Copyright © 2016年 zhangchen. All rights reserved.
//

#import "ZCDownloadManager.h"


#define ZCTaskPath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"Task"]

@implementation ZCDownloadManager

- (void)downloadTaskWithURL:(NSString *)url toPath:(NSString *)path progress:(ZCProgressBlock)progress state:(ZCStateBlock)state completion:(ZCDownloadedCompletionBlock)completion
{
    ZCDownloadTask *task = [self taskWithURL:url];
    
    if (task) {
        
        if (progress && !task.progressBlock) {
            task.progressBlock = progress;
        }
        
        if (state && !task.stateBlock) {
            task.stateBlock = state;
        }
        
        if (completion && !task.completionBlock) {
            task.completionBlock = completion;
        }
    }else {
        
        task = [[ZCDownloadTask alloc] initWithURL:url toPath:path progress:progress state:state completion:completion];
        
        [self.ZCDownloadTasks addObject:task];
        
        [self saveData];
    }

    if (task.state == ZCDownloadTaskStateBeforeRun || task.state == ZCDownloadTaskStateSuspended) {
        
        [task resume];
        
    }else if (task.state == ZCDownloadTaskStateRunning) {//任务已暂停
        
        [task suspend];
    }
}

- (void)removeTaskWithURL:(NSString *)url preserveFile:(BOOL)keep
{
    ZCDownloadTask *task = [self taskWithURL:url];
    
    [task cancel];
    
    NSError *error;
    
    if (!keep && [[NSFileManager defaultManager] fileExistsAtPath:task.filePath]) {
        
        [[NSFileManager defaultManager] removeItemAtPath:task.filePath error:&error];
        
        if (error && task.completionBlock) {
            
            task.completionBlock(error,task.filePath);
        }
    }
    
    [self.ZCDownloadTasks removeObject:task];
    
    [self saveData];
}

- (ZCDownloadTask *)taskWithURL:(NSString *)url
{
    for (ZCDownloadTask *task in self.ZCDownloadTasks) {
        if ([task.url isEqualToString:url]) {
            return task;
        }
    }
    return nil;
}

- (void)saveData
{
    [NSKeyedArchiver archiveRootObject:self.ZCDownloadTasks toFile:ZCTaskPath];
}

- (NSMutableArray *)ZCDownloadTasks
{
    if (!_ZCDownloadTasks) {
        
        _ZCDownloadTasks = [NSKeyedUnarchiver unarchiveObjectWithFile:ZCTaskPath];
        
        if (!_ZCDownloadTasks) {
            
            _ZCDownloadTasks = [NSMutableArray array];
            
        }
    }
    
    return _ZCDownloadTasks;
}

static id _instace;

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken; 
    dispatch_once(&onceToken, ^{ 
        _instace = [super allocWithZone:zone]; 
    }); 
    return _instace; 
} 

+ (instancetype)sharedInstance 
{ 
    static dispatch_once_t onceToken; 
    dispatch_once(&onceToken, ^{ 
        _instace = [[self alloc] init]; 
    }); 
    return _instace; 
} 

- (id)copyWithZone:(NSZone *)zone 
{ 
    return _instace; 
}
@end
