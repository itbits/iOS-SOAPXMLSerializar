//
//  EVEKeyGenrator.h
//  TextXMLMapping
//
//  Created by Muhammad Imran on 4/27/14.
//
//

#import <Foundation/Foundation.h> 
#import <CommonCrypto/CommonDigest.h>
/**
 *  This class will be used togenrate MD5 hash from a string.
 */
@interface EVEKeyGenrator : NSObject {

}
/**
 *  This method will create a MD5 hash from a string.
 *
 *  @param urlstring url in String formate.
 *
 *  @return the result will be the MD5 hash.
 */
+ (NSString*)md5Key:(NSString *)urlstring;

@end
