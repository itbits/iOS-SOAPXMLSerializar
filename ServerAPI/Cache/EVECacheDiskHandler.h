//
//  EVECacheDiskHandler.h
//  TextXMLMapping
//
//  Created by Muhammad Imran on 4/28/14.
//
//

#import <Foundation/Foundation.h>
/**
 *  EVECacheDiskHandler will handle all the operations related to saving and retriving the files from disk.
 */
@interface EVECacheDiskHandler : NSObject {

}
/**
 *  Generates the cache file path for provide key.
 *
 *  @param key A unique string will be used to name file
 *
 *  @return The result will be the complete path to file against provide key
 */
+ (NSString*)cacheFilePathForKey:(NSString *)key;
/**
 *  Saves the data to disk against provided key
 *
 *  @param cachedResponseData data the we want to save in disk.
 *  @param key                unique key to name file on disk
 *
 *  @return Result will be TRUE/FALSE (true for success full operation and false for failed operation).
 */
+ (BOOL)saveResponseToDiskCache:(NSData *)cachedResponseData forKey:(NSString *)key;
/**
 *  Read the data from disk against provided key
 *
 *  @param key A unique string to identify the files on disk.
 *
 *  @return Result will be the data saved against provided key.
 */
+ (NSData*)cachedDataFromDiskForKey:(NSString *)key;
/**
 *  Delete the data from disk for provided key.
 *
 *  @param key Unique string to identify the file.
 *
 *  @return Result will be TRUE/FALSE (true for success full operation and false for failed operation).
 */
+ (BOOL)purgeDiskCacheForKey:(NSString*)key;

/**
 *  Prevent the item from beaing backed up at icloud
 *
 *  @param URL File URL for item.
 *
 *  @return YES/NO YES if the operation is successful and no if the operation fails.
 */
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

@end
