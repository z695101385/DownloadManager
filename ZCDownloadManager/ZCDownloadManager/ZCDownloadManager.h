//
//  ZCDownloadManager.h
//  palynet
//
//  Created by 张晨 on 16/6/14.
//  Copyright © 2016年 zhangchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZCDownloadTask.h"

@interface ZCDownloadManager : NSObject

/** ZCDownloadTaskArray(ZCDownloadTask) */
@property (nonatomic, strong) NSMutableArray *ZCDownloadTasks;

+ (instancetype)sharedInstance;

/**
 *  操作下载任务
 *  ＊当任务不存在时，调用方法会自动创建任务并开始下载
 *  ＊当任务正在下载时，调用方法会暂停任务
 *  ＊当任务暂停时，调用方法会继续任务
 *  ＊若任务已完成，调用方法不会进行任何处理
 *  @param url         下载URL地址（NSString *）
 *  @param path        存放下载文件的目录地址，若目录不存在则自动创建
 *  @param progress    下载进度变更时调用代码块（主线程）
 *  @param state       下载状态变更时调用代码块（主线程）
 *  @param completion  下载完成后调用代码块（主线程）
 *
 */
- (void)downloadTaskWithURL:(NSString *)url toPath:(NSString *)path progress:(ZCProgressBlock)progress state:(ZCStateBlock)state completion:(ZCDownloadedCompletionBlock)completion;

/**
 *  移除任务
 *
 *  @param url  下载URL地址（NSString *）
 *  @param keep if keep == YES 只移除任务，保留文件（***谨慎使用,以下载文件需要自己手动清理***），else 移除任务与文件
 */
- (void)removeTaskWithURL:(NSString *)url preserveFile:(BOOL)keep;

/**
 *  取出任务
 *
 *  @param url 下载URL地址（NSString *）
 *
 *  @return 返回ZCDownloadTask ＊任务
 */
- (ZCDownloadTask *)taskWithURL:(NSString *)url;
//ZCDownloadTasks归档，建议在AppDelegate中任务终止或进入后台时调用该方法
- (void)saveData;

@end
