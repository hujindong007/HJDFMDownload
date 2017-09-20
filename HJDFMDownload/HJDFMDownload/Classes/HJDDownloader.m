
//
//  HJDDownloader.m
//  HJDFMDownload
//
//  Created by 胡金东 on 2017/9/4.
//  Copyright © 2017年 胡金东. All rights reserved.
//

#import "HJDDownloader.h"
#import "HJDFileTool.h"
// - 缓存路径
#define HJDCachePath  NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
// - 临时路径
#define HJDTmpPath NSTemporaryDirectory()

@interface HJDDownloader ()<NSURLSessionDataDelegate>
{
    // 记录文件临时下载大小
    long long _tmpSize;
    // 记录文件总大小
    long long _totalSize;
}

@property (nonatomic,strong) NSURLSession * session;
/** 下载完成路径 */
@property (nonatomic,copy) NSString * downLoaderPath;
/** 下载临时路径 */
@property (nonatomic,copy) NSString * downTmpPath;
/** 文件输出流 */
@property (nonatomic,strong) NSOutputStream * outputStream;
/** 当前下载任务*/ // - 要用弱引用
@property (nonatomic,weak) NSURLSessionDataTask * dataTask;



@end

@implementation HJDDownloader

// - block 赋值
- (void)downLoader:(NSURL *)url downLoadInfo:(DownLoadInfoBlockType)downLoadInfoBlock progress:(ProgressBlockType)progressBlock success:(SuccessBlockType)successBlock fail:(FailBlockType)failBlock
{
    self.downLoadInfoBlock = downLoadInfoBlock;
    self.progressBlock = progressBlock;
    self.successBlock = successBlock;
    self.failBlock = failBlock;
    
    [self downloader:url];
}

- (void)downloader:(NSURL *)url
{
    // - 内部实现
    // - 1.真正的从头开始下载
    // - 2.如果任务存在了，继续下载
    
    // - 当前任务肯定存在的
    // - 当前下载任务的self.dataTask.originalRequest.URL是否url一致，一致说明任务已存在，则执行继续就行，不用从头开始下载
    if ([url isEqual:self.dataTask.originalRequest.URL]) {
        
        // - 判断如果是暂停状态，才走这，防止下载失败也走这，直接返回出去了
        if (self.state == HJDDwonLoadStatePause) {
            
            [self resumeCurrentTask];
            return;
        }
        
    }
    
    
    // 两种: 1. 任务不存在,请求下载
//    2. 任务存在, 但是, 任务的Url地址 不同,就取消，重新下载
    
    [self cancelCurrentTask];

    
    
    // 1. 文件的存放
    // 下载ing => temp + 名称
    // MD5 + URL 防止重复资源
    // a/1.png md5 -
    // b/1.png
    // 下载完成 => cache + 名称
    
    // - 获取文件名称, 指明路径, 开启一个新任务
    NSString * fileName = url.lastPathComponent;
//    stringByAppendingPathComponent 这个拼接会自动加斜杠(/)
//    stringByAppendingString 这个就是字符串简单的拼接
//    cache + 名称
    self.downLoaderPath = [HJDCachePath stringByAppendingPathComponent:fileName];
//    temp + 名称
    self.downTmpPath = [HJDTmpPath stringByAppendingPathComponent:fileName];
    
    // - 1. 判断，url地址，对应的资源，是下载完毕，（下载完成的目录里面，存在这个文件）
    // - 1.1 告诉外界，下载完毕，并且传递相关信息（本地的路径，文件的大小）
    // - 直接 return
    if ([HJDFileTool fileExists:self.downLoaderPath]) {
        self.state = HJDDwonLoadStateSuccess;
        return;
    }
    
    // - 2.检测，临时文件是否存在
    // - 2.1 不存在：从0字节开始请求资源
    // - return
    if (![HJDFileTool fileExists:self.downTmpPath]) {
        // - 从0字节开始请求资源
        [self downLoadWithURL:url offsetSize:0];
        return;
    }
    
    // - 2.2 存在：直接，以当前的存在文件大小，作为开始字节，去网络请求资源
    //   本地大小 == 总大小  ==> 移动到下载完成的路径中
    //    本地大小 > 总大小  ==> 删除本地临时缓存, 从0开始下载
    //    本地大小 < 总大小 => 从本地大小开始下载
    _tmpSize = [HJDFileTool fileSize:self.downTmpPath];
    // - 测试数据（没有缓存，2.1也要先注释）
//    _tmpSize = 12;
    [self downLoadWithURL:url offsetSize:_tmpSize];
    
    /**
     不用这个方法是因为  上面调用[self downLoadWithURL:url offsetSize:_tmpSize];会调用代理delegate方法，哪里可以请求判断，在这里在写就等于多写一遍
     */
    // 文件的总大小获取
    // 发送网络请求
    // 同步(要用同步，接着就要判断，异步就会直接跳过获取不了大小) / 异步
    // - 要用“HEAD”请求方法，得到响应头资源就可以得到文件大小了，如果不用“HEAD”，会把资源下载完，才结束
    
//            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//            request.HTTPMethod = @"HEAD";
//            NSHTTPURLResponse *response = nil;
//            NSError *error = nil;
//            [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//            // 资源已经下载完毕了❌
//            // 我们需要的是响应头
//            if (error == nil) {
//    
//                NSLog(@"%@", response);
//            }
    

    
}
/**
 暂停任务
 注意:
 - 如果调用了几次继续
 - 调用几次暂停, 才可以暂停
 - 解决方案: 引入状态
 */

- (void)pasueCurrentTask{
    if (self.state == HJDDownloadStateDownLoading) {
        [self.dataTask suspend];
         self.state = HJDDwonLoadStatePause;
    }
}

/**
 继续任务
 - 如果调用了几次暂停, 就要调用几次继续, 才可以继续
 - 解决方案: 引入状态
 */
- (void)resumeCurrentTask
{// - 判断任务是否存在 且 状态是暂停
    if (self.dataTask && self.state == HJDDwonLoadStatePause) {
        // 使用resume方法启动任务
        [self.dataTask resume];
        self.state = HJDDownloadStateDownLoading;
    }
}


/**
 取消任务
 */
- (void)cancelCurrentTask{
    
    self.state = HJDDwonLoadStatePause;
    [self.session invalidateAndCancel];
    // - 至为nil， session是懒加载，下次可以重新创建
    self.session = nil;
}
/**
 取消任务，并删除文件
 */
- (void)cancelAndClean{
    // - 取消任务
    [self cancelCurrentTask];
    [HJDFileTool removefile:self.downTmpPath];
}


#pragma mark  - delegate
// - 第一次接受到响应的时候调用（响应头，并没有具体的资源内容）
// - 通过这个方法，里面，系统提供的回调代码块，可以控制是继续请求，还是取消请求
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
//    NSLog(@"response=%@",response);
    // - 打印
//    response=<NSHTTPURLResponse: 0x170030c20> { URL: http://free2.macx.cn:8281/tools/photo/SnapNDragPro418.dmg } { status code: 206, headers {
//        "Accept-Ranges" = bytes;
//        "Content-Length" = 11;
//        "Content-Range" = "bytes 0-10/11";
//        "Content-Type" = "text/html";
//        Date = "Tue, 05 Sep 2017 09:35:32 GMT";
//        Etag = "\"1063451cdf48cf1:0\"";
//        "Last-Modified" = "Wed, 26 Mar 2014 10:35:30 GMT";
//        Server = "Microsoft-IIS/7.5";
//    } }
    
    
    // Content-Length 请求的大小 != 资源大小
    // 当tmpSize为100的时候 Content-Length 19061705
    // 实际总大小 19061805
    // 本地缓存大小

    // 取资源总大小
    // 1. 如果没有Content-Range 从  Content-Length 取出来（所以下载的时候写一下Range这个方法）
    // 2. 如果 Content-Range 有, 应该从Content-Range里面获取
    _totalSize = [response.allHeaderFields[@"Content-Length"] longLongValue];
    // - Range方式获取内容大小
    NSString * contentRangSize = response.allHeaderFields[@"Content-Range"];
    if (contentRangSize.length != 0) {
//        "Content-Range" = "bytes 0-10/11"分割，取最后一个
        _totalSize = [[contentRangSize componentsSeparatedByString:@"/"].lastObject longLongValue];
    }
     // 传递给外界 : 总大小 & 本地存储的文件路径
    if (self.downLoadInfoBlock != nil) {
        self.downLoadInfoBlock(_totalSize);
    }
    
    
    // - 临时文件等资源总大小
    if (_tmpSize == _totalSize) {
        // - 1.移动到下载完成文件夹
//        NSLog(@"移动文件到下载完成");
        [HJDFileTool movefile:self.downTmpPath toPath:self.downLoaderPath];
        // - 2.取消本次请求
//        NSURLSessionResponseAllow 这个继续请求
        completionHandler(NSURLSessionResponseCancel);
        // - 3.修改状态
        self.state = HJDDwonLoadStateSuccess;
        return;
    }
    
    if (_tmpSize > _totalSize) {
        // - 文件出错
        // - 1.删除临时缓存
//        NSLog(@"删除临时文件");
        [HJDFileTool removefile:self.downTmpPath];
        // 2. 取消请求（这个是错误的请求，就是_tmpSize比_totalSize大再去请求下载是无意义，所以要取消，从0 开始下载开始一个新的请求）
        completionHandler(NSURLSessionResponseCancel);

        // - 3. 从0开始下载（这是有一个请求）
//        NSLog(@"重新下载");
        [self downloader:response.URL];//这样开始下载就不会造成下面的情况
        //             [self downLoadWithURL:response.URL offset:0];//写这个方法有问题，当删除临时缓存失败，我们给的是从0开始下载，就会叠加在缓存文件上，造成_tmpSize会大于totalSize报错
              return;
        
    }
    // - 改状态
    self.state = HJDDownloadStateDownLoading;
    // 继续接受数据
    // - 确定开始下载数据
    // - 通过下载流缓存到tmp，下载一点就append追加一点，这样就不会造成内存紧张
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.downTmpPath append:YES];
    // - 打开下载流
    [self.outputStream open];
    completionHandler(NSURLSessionResponseAllow);
    

    
}

// - 当用户确定，继续接受数据的时候调用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    // - 当前已经下载大小
    _tmpSize += data.length;
    // - self.progress是float ，_tmpSize是long，用1.0放在前面乘 是降低精度
    self.progress = 1.0 * _tmpSize / _totalSize;
    
    // - 打开下载流 开始写数据,一点一点的写入
    [self.outputStream write:data.bytes maxLength:data.length];
//    NSLog(@"在接受后续数据");
}

// - 请求完成的时候调用（不等于 请求成功或者请求失败,只要请求完成）
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
//     NSLog(@"请求完成");
    if (error == nil) {
        // - 走到这里也不一定是成功的
        // - 可以肯定的是数据是请求完成了
        // 判断, 本地缓存 == 文件总大小 {filename: filesize: md5:xxx}需要服务器支持不只是判断大小，也要判断MD5加密数据比对是否一致，是否丢包，数据被篡改
        // 如果等于 => 验证, 是否文件完整(file md5 )
        
        // - 请求完成，移动文件
        [HJDFileTool movefile:self.downTmpPath toPath:self.downLoaderPath];
        self.state = HJDDwonLoadStateSuccess;

        
    }else{
        
//        NSLog(@"有问题%zd==%@",error.code,error.localizedDescription);
        if (-999 == error.code) {//取消
            self.state = HJDDwonLoadStatePause;
        }else{//没网等情况
            self.state = HJDDwonLoadStateFailed;
        }
    }
    // - 不管成功失败，请求完成就关闭下载流
    [self.outputStream close];
   
}
#pragma mark  - 下载私有方法

- (void)downLoadWithURL:(NSURL *)url offsetSize:(long long)size{
    // - timeoutInterval:0 0表示一直加载，不设置超时，自己可以设置超时时间
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-",size] forHTTPHeaderField:@"Range"];
    // - session 分配的task，默认情况，挂起状态
    self.dataTask = [self.session dataTaskWithRequest:request];
    // - 下载
    [self resumeCurrentTask];
    
}


#pragma mark  - load
- (NSURLSession *)session
{
    if (!_session) {
        NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
        // - [NSOperationQueue mainQueue]回到主线程，这个也可以写自己创建的线程，自己决定
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (void)setState:(HJDDwonLoadState)state
{
    // - 数据过滤，防止点击多次暂停之后还要点击多次开始，只有状态不一样才去才去赋值
    if (_state == state) {
        return;
    }
    _state = state;
    
    // - 代理 通知 block
    // - 判断stateChangeBlock是否存在
    if (self.stateChangeBlock) {//存在
        self.stateChangeBlock(_state);
    }
    // - 判断下载状态成功且successBlock存在，返回下载成功路径
    if (_state == HJDDwonLoadStateSuccess && self.successBlock) {
        self.successBlock(self.downLoaderPath);
    }
    
    if (_state == HJDDwonLoadStateFailed && self.failBlock) {
        self.failBlock();
    }
    
    
}

- (void)setProgress:(float)progress
{
    _progress = progress;
    if (self.progressBlock) {
        self.progressBlock(_progress);
    }
}

@end
