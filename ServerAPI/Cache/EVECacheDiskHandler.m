//
//  EVECacheDiskHandler.m
//  TextXMLMapping
//
//  Created by Muhammad Imran on 4/28/14.
//
//

#import "EVECacheDiskHandler.h"

@implementation EVECacheDiskHandler

+ (NSString*)cacheFilePathForKey:(NSString *)key {
    NSArray *directoriesPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [directoriesPaths objectAtIndex:0];
    NSMutableString *cacheDirectoryPath = [[NSMutableString alloc] initWithString:[cacheDirectory stringByAppendingPathComponent:@"WebServicesCache/"]];
    NSError *error;
    //Create WebServicesCache directory if it did not exist.
	if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDirectoryPath]) {
		if (![[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectoryPath
									   withIntermediateDirectories:NO
														attributes:nil
															 error:&error]){
			NSLog(@"Error while creating directory: %@", error);
		} else {
            NSURL *url = [NSURL fileURLWithPath:cacheDirectoryPath isDirectory:YES];
            [self addSkipBackupAttributeToItemAtURL:url];
        }
	}
    NSString *cacheFilePath = [NSString stringWithFormat:@"%@/%@.eve", cacheDirectoryPath,key];
    return cacheFilePath;
}

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);

    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}
+ (BOOL)saveResponseToDiskCache:(NSData *)cachedResponseData forKey:(NSString *)key{
    NSString *cacheFilePath = [self cacheFilePathForKey:key];
    return [cachedResponseData writeToFile:cacheFilePath atomically:YES];
}

+ (NSData*)cachedDataFromDiskForKey:(NSString *)key {
    NSString *cacheFilePath = [self cacheFilePathForKey:key];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
        return [NSData dataWithContentsOfFile:cacheFilePath];
    } else {
        return nil;
    }
}

+ (BOOL)purgeDiskCacheForKey:(NSString*)key {
    NSString *cacheFilePath = [self cacheFilePathForKey:key];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
        return [[NSFileManager defaultManager] removeItemAtPath:cacheFilePath error:nil];
    } else {
        return NO;
    }

}


@end
