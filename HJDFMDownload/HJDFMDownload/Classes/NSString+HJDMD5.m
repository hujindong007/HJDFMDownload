//
//  NSString+HJDMD5.m
//  HJDFMDownload
//
//  Created by 胡金东 on 2017/9/7.
//  Copyright © 2017年 胡金东. All rights reserved.
//

#import "NSString+HJDMD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (HJDMD5)

- (NSString *)md5 {
    
    const char * data = self.UTF8String;
    
    unsigned char md [CC_MD5_DIGEST_LENGTH];
    // - 作用：把c语言的字符串转换成MD5 C字符串
    CC_MD5(data, (CC_LONG)strlen(data), md);
    
    NSMutableString * result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0;  i < CC_MD5_DIGEST_LENGTH; i++) {
        // - md5 是16位显示,02表示两位不够补0，x是16位
        [result appendFormat:@"%02x",md[i]];
    }
    return  result;
}

@end
