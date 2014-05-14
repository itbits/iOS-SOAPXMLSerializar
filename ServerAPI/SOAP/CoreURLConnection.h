/*Created by Muhammad Imran on 4/6/14. */

#import <Foundation/Foundation.h>
#import "EVECacheDiskHandler.h"
#import "EVEDataDownloadProgress.h"

/**
 *  We will use this enum to set this cache mode
 */
typedef enum {
    /**
     *  The response will not be cached
     */
    EVEURLConnectionCacheModeNone,

    /**
     *  We will cache response in memory.
     */
    EVEURLConnectionCacheModeMemory,

    /**
     *  We will cache response on disk.
     */
    EVEURLConnectionCacheModeDisk
} EVEURLConnectionCacheMode;

@class CoreURLConnection;


@protocol CoreURLConnectionDelegate < NSObject >

@optional

- (void)connection:(CoreURLConnection *)connection hasDownloaded:(NSInteger)downloadedBytes;
- (void)connection:(CoreURLConnection *)connection didFinishStreaming:(NSString *)filePath;
- (void)connection:(CoreURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(CoreURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connection:(CoreURLConnection *)connection didReceiveResponseHeader:(NSDictionary *)responseHeader;
- (void)connection:(CoreURLConnection *)connection didDidReceiveCachedData:(NSData *)data;
- (void)connection:(CoreURLConnection *)connection didFinishCachedStreaming:(NSString *)filePath;
- (void)connection:(CoreURLConnection *)connection didUpdateDownloadProgress:(EVEDataDownloadProgress*)progress;


@end

@interface CoreURLConnection : NSObject {

}

@property (nonatomic, strong) id<CoreURLConnectionDelegate> delegate;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSArray *bufferedContentTypes;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, assign) BOOL connectionActive;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, assign) BOOL responseBuffered;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSFileHandle *file;
@property (nonatomic, assign) EVEURLConnectionCacheMode cacheMode;
@property (nonatomic, strong) NSString *cacheKey;
@property (nonatomic, strong) EVEDataDownloadProgress *progress;

- (id)initWithDelegate:(id<CoreURLConnectionDelegate>)delegate url:(NSString *)url;
- (BOOL)active;

- (void)invokeSOAPRequest:(NSURLRequest*)soapRequest cacheKey:(NSString *)cacheKey queryString:(NSString *)query;
- (void)cancel;
- (void)connectionDidFinishLoading:(NSURLConnection *)c;

@end
