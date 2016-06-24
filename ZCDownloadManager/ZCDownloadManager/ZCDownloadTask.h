//
//  ZCDownloadTask.h
//  palynet
//
//  Created by 张晨 on 16/6/14.
//  Copyright © 2016年 zhangchen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZCDownloadTaskState) {
    ZCDownloadTaskStateBeforeRun = 0,           /* 下载任务未开始 */
    ZCDownloadTaskStateRunning = 1,             /* 正在下载 */
    ZCDownloadTaskStateSuspended = 2,           /* 下载暂停 */
    ZCDownloadTaskStateCompleted = 3,           /* 下载完成 */
};

#define ZCDownloadedLength [[[NSFileManager defaultManager] attributesOfItemAtPath:_filePath error:nil][NSFileSize] integerValue]

typedef void(^ZCProgressBlock)(float progress);

typedef void(^ZCDownloadedCompletionBlock)(NSError *error,NSString *filePath);

typedef void(^ZCStateBlock)(ZCDownloadTaskState state);


@interface ZCDownloadTask : NSObject

/** url */
@property (nonatomic, copy) NSString *url;
/** path */
@property (nonatomic, copy) NSString *path;
/** 保存文件名 */
@property (nonatomic, strong) NSString *fileName;
/** 文件保存路径 */
@property (nonatomic, strong) NSString *filePath;
/** 下载总长度 */
@property (nonatomic, assign) NSInteger fileLength;
/** 下载百分比 */
@property (nonatomic, assign) CGFloat progress;
/** task状态 */
@property (nonatomic, assign) ZCDownloadTaskState state;
/** progressBlock */
@property (nonatomic, strong) ZCProgressBlock progressBlock;
/** stateBlock */
@property (nonatomic, strong) ZCStateBlock stateBlock;
/** completionBlock */
@property (nonatomic, strong) ZCDownloadedCompletionBlock completionBlock;

/** 开始（继续）下载 */
- (void)resume;
/** 暂停下载 */
- (void)suspend;
/** 取消下载 */
- (void)cancel;
/** init */
- (instancetype)initWithURL:(NSString *)url toPath:(NSString *)path progress:(ZCProgressBlock)progress state:(ZCStateBlock)state completion:(ZCDownloadedCompletionBlock)completion;

@end
