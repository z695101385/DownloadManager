# ZCDownloadManager
一个OC的下载类，封装了NSURLSession NSURLSessionDataTask操作简单

支持断点续传

子线程下载，不会卡住界面


通过```[ZCDownloadManager sharedInstance]```调用下载

```objc
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
```
```objc
/**
 *  移除任务
 *
 *  @param url  下载URL地址（NSString *）
 *  @param keep if keep == YES 只移除任务，保留文件（***谨慎使用,以下载文件需要自己手动清理***），else 移除任务与文件
 */
- (void)removeTaskWithURL:(NSString *)url preserveFile:(BOOL)keep;
```
```objc
/**
 *  取出任务
 *
 *  @param url 下载URL地址（NSString *）
 *
 *  @return 返回ZCDownloadTask ＊任务
 */
- (ZCDownloadTask *)taskWithURL:(NSString *)url;
```
```objc
//ZCDownloadTasks归档，在添加任务与删除任务时自动调用
//手动调用建议在AppDelegate中任务终止或进入后台时调用该方法
- (void)saveData;
```
