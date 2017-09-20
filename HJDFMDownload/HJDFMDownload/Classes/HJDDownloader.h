//
//  HJDDownloader.h
//  HJDFMDownload
//
//  Created by 胡金东 on 2017/9/4.
//  Copyright © 2017年 胡金东. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 枚举 没有选择的时候默认第一个，有时候赋值看见把第一个赋值1或者unknown，就是防止默认状态
 */
// - 下载状态
typedef NS_ENUM(NSUInteger,HJDDwonLoadState) {
    HJDDwonLoadStatePause,
    HJDDownloadStateDownLoading,
    HJDDwonLoadStateSuccess,
    HJDDwonLoadStateFailed
};
/**
 block
 */

// - 传文件总大小
typedef void(^DownLoadInfoBlockType)(long long totalSize);
// - 传下载进度
typedef void(^ProgressBlockType)(float progress);
// - 传成功后的路径
typedef void(^SuccessBlockType)(NSString * filePath);
// - 失败
typedef void(^FailBlockType)();
// - 传下载状态
typedef void(^StateChangeBlockType)(HJDDwonLoadState state);




// - 一个下载器，对应一个下载任务
// - HJDDownloader -> url
@interface HJDDownloader : NSObject


- (void)downLoader:(NSURL *)url downLoadInfo:(DownLoadInfoBlockType)downLoadInfoBlock progress:(ProgressBlockType)progressBlock success:(SuccessBlockType)successBlock fail:(FailBlockType)failBlock;



/**
 根据url地址下载资源，如果任务已经存在，则执行继续动作
 */
- (void)downloader:(NSURL *)url;
/**
 暂停任务
 注意： 如果调用了几次继续，就要调用几次暂停，才可以暂停
 解决方案：引入状态
 */
- (void)pasueCurrentTask;
/**
 继续任务
 - 如果调用了几次暂停, 就要调用几次继续, 才可以继续
 - 解决方案: 引入状态
 */
- (void)resumeCurrentTask;
/**
 取消任务
 */
- (void)cancelCurrentTask;
/**
 取消任务，并删除文件
 */
- (void)cancelAndClean;




// - 定义下载状态 (readonly就是写Set方法，所以要在里面重写Set方法)
@property (nonatomic,assign,readonly) HJDDwonLoadState  state;
@property (nonatomic,assign,readonly) float progress;

@property (nonatomic,copy) DownLoadInfoBlockType downLoadInfoBlock;
@property (nonatomic,copy) ProgressBlockType progressBlock;
@property (nonatomic,copy) SuccessBlockType successBlock;
@property (nonatomic,copy) FailBlockType failBlock;
@property (nonatomic,copy) StateChangeBlockType stateChangeBlock;






@end
