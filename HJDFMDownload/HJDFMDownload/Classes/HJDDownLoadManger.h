//
//  HJDDownLoadManger.h
//  HJDFMDownload
//
//  Created by 胡金东 on 2017/9/7.
//  Copyright © 2017年 胡金东. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HJDDownloader.h"

@interface HJDDownLoadManger : NSObject

/**
 创建单例
 */
+(instancetype)shareInstance;


// - 一个url对应一个下载任务
- (void)downLoader:(NSURL *)url downLoadInfo:(DownLoadInfoBlockType)downLoadInfoBlock progress:(ProgressBlockType)progressBlock success:(SuccessBlockType)successBlock fail:(FailBlockType)failBlock;

// - 暂停
- (void)pauseWithURL:(NSURL *)url;
// - 继续
- (void)resumeWithURL:(NSURL *)url;
// - 取消
- (void)cancelWithURL:(NSURL *)url;
// - 取消并删除
- (void)cancelAndCleanWithURL:(NSURL *)url;
// - 暂停所有
- (void)pauseAll;
// - 继续所有
- (void)resumeAll;


@end
