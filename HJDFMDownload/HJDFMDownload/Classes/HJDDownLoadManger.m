//
//  HJDDownLoadManger.m
//  HJDFMDownload
//
//  Created by 胡金东 on 2017/9/7.
//  Copyright © 2017年 胡金东. All rights reserved.
//

#import "HJDDownLoadManger.h"
#import "NSString+HJDMD5.h"

@interface HJDDownLoadManger ()<NSCopying,NSMutableCopying>
// - 设置可变的字典
@property (nonatomic,strong) NSMutableDictionary * dictDownloadInfo;

@end

@implementation HJDDownLoadManger

static HJDDownLoadManger * _shareDownLoader;

+(instancetype)shareInstance
{
    if (_shareDownLoader == nil) {
        _shareDownLoader = [[self alloc]init];
    }
    return _shareDownLoader;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    if (!_shareDownLoader) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareDownLoader = [super allocWithZone:zone];
        });
    }
    return _shareDownLoader;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _shareDownLoader;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return _shareDownLoader;
}

/**
 用字典保存，通过urlMd5的key去查找，没有就重新创建，有key就直接下载
 */
- (void)downLoader:(NSURL *)url downLoadInfo:(DownLoadInfoBlockType)downLoadInfoBlock progress:(ProgressBlockType)progressBlock success:(SuccessBlockType)successBlock fail:(FailBlockType)failBlock
{
    // -1. url md5加密
    NSString * urlMD5 = [url.absoluteString md5];
    // -2. 根据 urlMD5，查找对应的下载器
    HJDDownloader * downLoader = self.dictDownloadInfo[urlMD5];
    if (downLoader == nil) {
        downLoader = [[HJDDownloader alloc]init];
        self.dictDownloadInfo[urlMD5] = downLoader;
    }
    
    // - 如果不想做任何事情，直接照抄下来就行了，如果要在那个block中做事，就要打开block，在里面写相应的代码
    //    [downLoader downLoader:url downLoadInfo:downLoadInfo progress:progressBlock success:successBlock failed:failedBlock];

    
    __weak typeof(self) weakSelf = self;
    // - 这个下载完成之后, 移除下载器，所以打开successBlock在里面写代码
    [downLoader downLoader:url downLoadInfo:downLoadInfoBlock progress:progressBlock success:^(NSString *filePath) {
          // 下载完成之后, 移除下载器
        [weakSelf.dictDownloadInfo removeObjectForKey:urlMD5];
        // - 拦截block
        successBlock(filePath);
    } fail:failBlock];
}


// - 暂停
- (void)pauseWithURL:(NSURL *)url{
    NSString * urlMD5 = [url.absoluteString md5];
    // - 根据urlMD5取出下载任务
    HJDDownloader * downloader = self.dictDownloadInfo[urlMD5];
    // - 暂停任务
    [downloader pasueCurrentTask];
}
// - 继续
- (void)resumeWithURL:(NSURL *)url{
    NSString * urlMD5 = [url.absoluteString md5];
    HJDDownloader * downloader = self.dictDownloadInfo[urlMD5];
    [downloader resumeCurrentTask];
}
// - 取消
- (void)cancelWithURL:(NSURL *)url{
    NSString * urlMD5 = [url.absoluteString md5];
    HJDDownloader * downloader = self.dictDownloadInfo[urlMD5];
    [downloader cancelCurrentTask];
}
// - 取消并删除
- (void)cancelAndCleanWithURL:(NSURL *)url{
    NSString * urlMD5 = [url.absoluteString md5];
    HJDDownloader * downloader = self.dictDownloadInfo[urlMD5];
    [downloader cancelAndClean];

}
// - 暂停所有
- (void)pauseAll{
       [[self.dictDownloadInfo allValues] makeObjectsPerformSelector:@selector(pasueCurrentTask)];
}
// - 继续所有
- (void)resumeAll{
    [[self.dictDownloadInfo allValues] makeObjectsPerformSelector:@selector(resumeCurrentTask)];
}

#pragma mark  - load

- (NSMutableDictionary *)dictDownloadInfo
{
    if (!_dictDownloadInfo) {
        _dictDownloadInfo = [NSMutableDictionary dictionary];
    }
    return _dictDownloadInfo;
}

@end
