/*Created by Muhammad Imran on 4/6/14. */

#import <Foundation/Foundation.h>
#import "CoreURLConnection.h"


@class CoreWebService;


@protocol CoreWebServiceServiceDelegate < NSObject >

@optional

- (void)soapService:(CoreWebService *)service hasDownloaded:(NSInteger)downloadedBytes;
- (void)soapService:(CoreWebService *)service didFinishStreaming:(NSString *)filePath;
- (BOOL)soapService:(CoreWebService *)service didReceiveError:(id)xmlObject;
- (void)soapService:(CoreWebService *)service didGet:(id)xmlObject;
- (void)soapService:(CoreWebService *)service didReceiveResponseHeader:(NSDictionary *)responseHeader;

@end


@interface CoreWebService : NSObject< CoreURLConnectionDelegate > {

}

@property (nonatomic, strong) NSString *rootURL;
@property (nonatomic, weak) id<CoreWebServiceServiceDelegate> delegate;
@property (nonatomic, strong) CoreURLConnection *connection;
@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) Class responseClass;
@property (nonatomic, strong) NSDictionary *responseHeader;

- (id)initWithRootUrl:(NSString *)rootUrl serviceUrl:(NSString *)url;
- (BOOL)active;
- (void)cancel;
- (BOOL)isErrorResponse:(id)xmlObject;
- (void)didReceiveError:(id)xmlObject;
- (void)setUrl:(NSString *)rootUrl serviceUrl:(NSString *)serviceUrl;

@end
