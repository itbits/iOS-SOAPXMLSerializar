/*Created by Muhammad Imran on 4/6/14. */

#import <Foundation/Foundation.h>
#import "CoreURLConnection.h"
#import "EVEError.h"


@class CoreWebService;


@protocol CoreWebServiceServiceDelegate < NSObject >

@optional

- (void)soapService:(CoreWebService *)service hasDownloaded:(NSInteger)downloadedBytes;
- (void)soapService:(CoreWebService *)service didFinishStreaming:(NSString *)filePath;
- (BOOL)soapService:(CoreWebService *)service didReceiveError:(EVEError *)error;
- (void)soapService:(CoreWebService *)service didGet:(id)xmlObject;
- (void)soapService:(CoreWebService *)service didReceiveResponseHeader:(NSDictionary *)responseHeader;
- (void)soapService:(CoreWebService *)service didDidReceiveCached:(id)xmlObject;
- (void)soapService:(CoreWebService *)service didFinishCachedStreaming:(NSString *)filePath;
- (void)soapService:(CoreWebService *)service didUpdateDownloadProgress:(EVEDataDownloadProgress*)progress;

@end


@interface CoreWebService : NSObject< CoreURLConnectionDelegate > {

}

@property (nonatomic, strong) NSString *rootURL;
@property (nonatomic, weak) id<CoreWebServiceServiceDelegate> delegate;
@property (nonatomic, strong) CoreURLConnection *connection;
@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) Class responseClass;
@property (nonatomic, strong) NSDictionary *responseHeader;

/*!
@discussion
 settes the cache mode for current SOAP request there are three cache modes available.
 EVEURLConnectionCacheModeNone -did not cache the response data.
 EVEURLConnectionCacheModeMemory -cache response data in memory
 EVEURLConnectionCacheModeDisk -cache response data on local storage.
 */
@property (nonatomic, assign)  EVEURLConnectionCacheMode cacheMode;


- (id)initWithRootUrl:(NSString *)rootUrl serviceUrl:(NSString *)url;
- (BOOL)active;
- (void)cancel;
- (void)didReceiveError:(EVEError *)error;
- (void)setUrl:(NSString *)rootUrl serviceUrl:(NSString *)serviceUrl;

@end
