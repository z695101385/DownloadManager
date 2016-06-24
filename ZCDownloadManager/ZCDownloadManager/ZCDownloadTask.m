//
//  ZCDownloadTask.m
//  palynet
//
//  Created by 张晨 on 16/6/14.
//  Copyright © 2016年 zhangchen. All rights reserved.
//

#import "ZCDownloadTask.h"
#import "NSString+Hash.h"

#define ZCInfoPath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"Info"]

static NSString * const urlKey = @"url";

static NSString * const pathKey = @"path";

static NSString * const progressKey = @"progress";

static NSError *error;

@interface ZCDownloadTask ()<NSURLSessionDataDelegate>

{
    ZCDownloadTaskState _state;
}

/** session */
@property (nonatomic, strong) NSURLSession *session;
/** task */
@property (nonatomic, strong) NSURLSessionDataTask *task;
/** stream */
@property (nonatomic, strong) NSOutputStream *stream;
/** isJustOpened */
@property (nonatomic, assign) BOOL isJustOpened;

@end

@implementation ZCDownloadTask

- (NSURLSession *)session
{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    }
    return _session;
}

- (NSOutputStream *)stream
{
    if (!_stream) {
        
        _stream = [NSOutputStream outputStreamToFileAtPath:_filePath append:YES];
    }
    return _stream;
}

- (NSURLSessionDataTask *)task
{
    if (!_task) {
        
        if (self.fileLength && ZCDownloadedLength == self.fileLength) {
            NSLog(@"----文件已经下载过了");
            return nil;
        }
        
        // 创建请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]];
        
        // 设置请求头
        // Range : bytes=xxx-xxx
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-", ZCDownloadedLength];
        [request setValue:range forHTTPHeaderField:@"Range"];
        
        // 创建一个Data任务
        _task = [self.session dataTaskWithRequest:request];
    }
    return _task;
}

- (instancetype)initWithURL:(NSString *)url toPath:(NSString *)path progress:(ZCProgressBlock)progress state:(ZCStateBlock)state completion:(ZCDownloadedCompletionBlock)completion
{
    self.url = url;
    
    self.path = path;
    
    _progressBlock = progress;
    
    _stateBlock = state;
    
    _completionBlock = completion;
    
    _filePath = [_path stringByAppendingPathComponent:_fileName];
    
    return self;
}

- (void)setUrl:(NSString *)url
{
    _url = url;
    
    _fileName = url.md5String;
}

-(void)setPath:(NSString *)path
{
    _path = path;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:_path]) {
        
        [[NSFileManager defaultManager] createDirectoryAtPath:_path withIntermediateDirectories:YES attributes:nil error:nil];
        
    }
    
}

- (ZCDownloadTaskState)state
{
    if (_isJustOpened)
    {
        if (self.progress == 0.0) {
            _state = ZCDownloadTaskStateBeforeRun;
        }else if (self.progress == 1.0) {
            _state = ZCDownloadTaskStateCompleted;
        }else {
            _state = ZCDownloadTaskStateSuspended;
        }
        _isJustOpened = NO;
    }
    
    return _state;
}

- (void)setState:(ZCDownloadTaskState)state
{
    
    _state = state;
    
    
    
    if (_stateBlock) {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            _stateBlock(_state);
        }];
    }
}

- (NSInteger)fileLength
{
    
    if (_fileLength) {//_fileLength != 0
        
        return _fileLength;
        
    }else {//_fileLength == 0
        
        _fileLength = [[NSDictionary dictionaryWithContentsOfFile:ZCInfoPath][_fileName] integerValue];
        
        return _fileLength;
    }
    
}

- (CGFloat)progress
{
    _progress = 1.0 * ZCDownloadedLength / self.fileLength;
    
    return _progress;
}

- (void)resume
{
    [self.task resume];
    
    self.state = ZCDownloadTaskStateRunning;
}

- (void)suspend
{
    [self.task suspend];
    
    self.state = ZCDownloadTaskStateSuspended;
}

- (void)cancel
{
    [_session finishTasksAndInvalidate];
    
    _session = nil;
    
    [_task cancel];
    
    _task = nil;
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    self.fileLength = [response.allHeaderFields[@"Content-Length"] integerValue] + ZCDownloadedLength;
    
    // 存储总长度
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:ZCInfoPath];
    
    if (dict == nil) dict = [NSMutableDictionary dictionary];
    
    dict[_url.md5String] = @(self.fileLength);
    
    [dict writeToFile:ZCInfoPath atomically:YES];
    
    [self.stream open];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    
    [self.stream write:data.bytes maxLength:data.length];
    
    _progress = 1.0 * ZCDownloadedLength / self.fileLength;
    
    if (_progressBlock) {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            _progressBlock(_progress);
        }];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (!error) {
        self.state = ZCDownloadTaskStateCompleted;
    }
    
    [_stream close];
    
    _stream = nil;
    
    if (_completionBlock) {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            _completionBlock(error, _filePath);
        }];
    }
    

}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_url forKey:urlKey];
    
    [aCoder encodeObject:_path forKey:pathKey];
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        
        self.url = [aDecoder decodeObjectForKey:urlKey];
        
        self.path = [aDecoder decodeObjectForKey:pathKey];
        
        _filePath = [_path stringByAppendingPathComponent:_fileName];
        
        _isJustOpened = YES;
        
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"dealloc");
    
}

@end
