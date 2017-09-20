//
//  ViewController.m
//  HJDFMDownload
//
//  Created by 胡金东 on 2017/9/4.
//  Copyright © 2017年 胡金东. All rights reserved.
//

#import "ViewController.h"
#import "HJDDownLoadManger.h"

@interface ViewController (){
    NSURL * _url;
    NSURL * _url1;
}

//@property (nonatomic,strong) HJDDownloader * loader;
// - 下载
@property (nonatomic,strong) UIButton * downBtn;
// - 暂停
@property (nonatomic,strong) UIButton * pauseBtn;
// -暂停所有
@property (nonatomic,strong) UIButton * pauseAllBtn;
// - 取消
@property (nonatomic,strong) UIButton * cancelBtn;
// - 取消并删除
@property (nonatomic,strong) UIButton * cancelAndCleanBtn;
// - 继续
@property (nonatomic,strong) UIButton * resume;
// - 继续所有
@property (nonatomic,strong) UIButton * resumeAllBtn;




@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.downBtn];
    [self.view addSubview:self.cancelBtn];
    [self.view addSubview:self.pauseBtn];
    [self.view addSubview:self.pauseAllBtn];
    [self.view addSubview:self.resume];
    [self.view addSubview:self.resumeAllBtn];
    [self.view addSubview:self.cancelAndCleanBtn];

}

- (void)downBtnClick
{
    
    NSURL * url = [NSURL URLWithString:@"http://xiazai.xmindchina.cn/wm/xmind-8-mac-wm.dmg"];
    _url = url;
    NSURL * url1 = [NSURL URLWithString:@"http://download.dcloud.net.cn/HBuilder.8.0.2.macosx_64.dmg"];
    _url1 = url1;
    /**
     小文件
     */
//    https://www.charlesproxy.com/assets/release/4.1.4/charles-proxy-4.1.4.dmg
//http://dldir1.qq.com/qqtv/mac/TencentVideo_V1.0.8.30214.dmg
    
    /**
     大文件
     */
//http://xiazai.xmindchina.cn/wm/xmind-8-mac-wm.dmg
//    http://download.dcloud.net.cn/HBuilder.8.0.2.macosx_64.dmg
    
    [[HJDDownLoadManger shareInstance] downLoader:url downLoadInfo:^(long long totalSize) {
        NSLog(@"下载信息==%lld",totalSize/(1024*1024));
    } progress:^(float progress) {
        NSLog(@"下载进度==%f",progress);

    } success:^(NSString *filePath) {
         NSLog(@"下载成功路径==%@",filePath);
    } fail:^{
         NSLog(@"下载失败");
    }];
    
    [[HJDDownLoadManger shareInstance] downLoader:url1 downLoadInfo:^(long long totalSize) {
        NSLog(@"下载信息1==%lld",totalSize/(1024*1024));
    } progress:^(float progress) {
        NSLog(@"下载进度1==%f",progress);
        
    } success:^(NSString *filePath) {
        NSLog(@"下载成功路径1==%@",filePath);
    } fail:^{
        NSLog(@"下载失败1");
    }];

    
//    [self.loader setStateChangeBlock:^(HJDDwonLoadState state){
//        NSLog(@"下载状态==%zd",state);
//    }];
//    
//    
}
// - 暂停
- (void)pauseBtnClick
{
    [[HJDDownLoadManger shareInstance] pauseWithURL:_url];
}
// - 取消，任务销毁，重新下载
- (void)cancelBtnClick
{
    [[HJDDownLoadManger shareInstance] cancelWithURL:_url];
}
// - 取消并删除
- (void)cancelAndCleanBtnClick
{
    [[HJDDownLoadManger shareInstance] cancelAndCleanWithURL:_url];
}

// - 暂停所有
- (void)pauseAllBtnClick
{
    [[HJDDownLoadManger shareInstance] pauseAll];
}
// - 继续
- (void)resumeBtnClick
{
    [[HJDDownLoadManger shareInstance] resumeWithURL:_url];
}
// - 继续所有
- (void)resumeAllBtnClick
{
    [[HJDDownLoadManger shareInstance] resumeAll];
}
#pragma mark  - load


- (UIButton *)downBtn
{
    if (!_downBtn) {
        _downBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 50)];
        [_downBtn setTitle:@"下载" forState:UIControlStateNormal];
        [_downBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_downBtn addTarget:self action:@selector(downBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downBtn;
}

- (UIButton *)pauseBtn
{
    if (!_pauseBtn) {
        _pauseBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 150, 100, 50)];
        [_pauseBtn setTitle:@"暂停" forState:UIControlStateNormal];
        [_pauseBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_pauseBtn addTarget:self action:@selector(pauseBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pauseBtn;
}

- (UIButton *)cancelBtn
{
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 200, 100, 50)];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UIButton *)pauseAllBtn
{
    if (!_pauseAllBtn) {
        _pauseAllBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 250, 100, 50)];
        [_pauseAllBtn setTitle:@"暂停所有" forState:UIControlStateNormal];
        [_pauseAllBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_pauseAllBtn addTarget:self action:@selector(pauseAllBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pauseAllBtn;
}

- (UIButton *)resume
{
    if (!_resume) {
        
        _resume = [[UIButton alloc]initWithFrame:CGRectMake(100, 300, 100, 50)];
        [_resume setTitle:@"继续" forState:UIControlStateNormal];
        [_resume setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_resume addTarget:self action:@selector(resumeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resume;
}


- (UIButton *)resumeAllBtn
{
    if (!_resumeAllBtn) {
        _resumeAllBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 350, 100, 50)];
        [_resumeAllBtn setTitle:@"继续所有" forState:UIControlStateNormal];
        [_resumeAllBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_resumeAllBtn addTarget:self action:@selector(resumeAllBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resumeAllBtn;
}

- (UIButton *)cancelAndCleanBtn
{
    if (!_cancelAndCleanBtn) {
        _cancelAndCleanBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 400, 100, 50)];
        [_cancelAndCleanBtn setTitle:@"取消并删除" forState:UIControlStateNormal];
        [_cancelAndCleanBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_cancelAndCleanBtn addTarget:self action:@selector(cancelAndCleanBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelAndCleanBtn;
}
@end
