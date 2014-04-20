/*Created by Muhammad Imran on 4/6/14. */

#import <Foundation/Foundation.h>

typedef enum {
    EVEURLConnectionCacheModeNone,
    EVEURLConnectionCacheModeApplication
} EVEURLConnectionCacheMode;

@class CoreURLConnection;

@protocol CoreURLConnectionDelegate < NSObject >

@optional

- (void)connection:(CoreURLConnection *)connection hasDownloaded:(NSInteger)downloadedBytes;
- (void)connection:(CoreURLConnection *)connection didFinishStreaming:(NSString *)filePath;
- (void)connection:(CoreURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(CoreURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connection:(CoreURLConnection *)connection didReceiveResponseHeader:(NSDictionary *)responseHeader;

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

- (id)initWithDelegate:(id<CoreURLConnectionDelegate>)delegate url:(NSString *)url;
- (BOOL)active;

- (void)invokeSOAPRequest:(NSURLRequest*)soapRequest method:(NSString *)method queryString:(NSString *)query content:(NSData *)content;
- (void)cancel;
- (void)connectionDidFinishLoading:(NSURLConnection *)c;

@end
