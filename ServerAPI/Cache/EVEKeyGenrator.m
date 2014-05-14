//
//  EVEKeyGenrator.m
//  TextXMLMapping
//
//  Created by Muhammad Imran on 4/27/14.
//
//

#import "EVEKeyGenrator.h"

@implementation EVEKeyGenrator

+ (NSString*)md5Key:(NSString *)urlstring {
    const char *cStr = [urlstring UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (int)strlen(cStr), digest );
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return  output;
}

@end
