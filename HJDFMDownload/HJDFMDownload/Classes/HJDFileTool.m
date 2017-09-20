//
//  HJDFileTool.m
//  HJDFMDownload
//
//  Created by 胡金东 on 2017/9/5.
//  Copyright © 2017年 胡金东. All rights reserved.
//

#import "HJDFileTool.h"

@implementation HJDFileTool

+ (BOOL)fileExists:(NSString *)filePath{
    // - 判断路径是否存在，不存在直接返回NO
    if (filePath.length == 0) {
        return NO;
    }
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}


+ (long long)fileSize:(NSString *)fileLPath{
    // - 如果不存在，直接返回0字节
    if (![self fileExists:fileLPath]) {
        return 0;
    }
    NSDictionary * fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:fileLPath error:nil];
    return [fileInfo[NSFileSize] longLongValue];
}

+ (void)movefile:(NSString *)fromPath toPath:(NSString *)toPath{
    // - 如果没有这个文件，直接返回
    if (![self fileSize:fromPath]) {
        return;
    }
    [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:nil];
}

+ (void)removefile:(NSString *)filePath{
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

@end
