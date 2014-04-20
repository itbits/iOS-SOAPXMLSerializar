/*Created by Muhammad Imran on 4/6/14. */

#import "CoreURLConnection.h"

static NSMutableDictionary *globalCache;

@interface CoreURLConnection(Private)

- (void)logRequest:(NSString *)method content:(NSData *)content;
- (void)logResponse;

@end

@implementation CoreURLConnection

@synthesize delegate;
@synthesize url;
@synthesize bufferedContentTypes;
@synthesize connection;
@synthesize connectionActive;
@synthesize responseData;
@synthesize responseBuffered;
@synthesize filePath;
@synthesize file;
@synthesize cacheMode;

#pragma mark Initialization

+ (void)initialize {
    globalCache = [[NSMutableDictionary alloc] init];
}

- (id)initWithDelegate:(id<CoreURLConnectionDelegate>)d url:(NSString *)u {
    if ((self = [super init]) != nil) {
        [self setCacheMode:EVEURLConnectionCacheModeNone];
        [self setDelegate:d];
        [self setUrl:u];
        [self setConnection:nil];
        [self setResponseData:nil];
        [self setCacheMode:EVEURLConnectionCacheModeApplication];

    }
    return (self);
}

#pragma mark CoreURLConnection

- (NSMutableData *)cachedResponse:(NSData *)content {
    switch (cacheMode) {
        case EVEURLConnectionCacheModeNone:
            // if we aren't caching anything, return nil
            return (nil);
        case EVEURLConnectionCacheModeApplication: {
            // get the service cache from the global cache
            if ([globalCache objectForKey:NSStringFromClass([self class])] == nil) {
                [globalCache setObject:[NSMutableDictionary dictionary] forKey:NSStringFromClass([self class])];
            }
            NSMutableDictionary *globalServiceCache = [globalCache objectForKey:NSStringFromClass([self class])];
            // create the cache key
            NSString *cacheKey = [[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding];
            // see if we have a response cached for this request
            NSMutableData *cachedResponse = [globalServiceCache objectForKey:cacheKey];
            if (cachedResponse != nil) {
                // if we have a response, return it
                return (cachedResponse);
            } else {
                // if not, setup the current response object to cache
                [globalServiceCache setObject:responseData forKey:cacheKey];
                // tell the caller we need to hit the server
                return (nil);
            }
        }
        default:
            return (nil);
    }
}

- (void)purgeCacheForCurrentRequest {
    switch (cacheMode) {
        case EVEURLConnectionCacheModeNone:
            // if we aren't caching anything, don't do anything
            break;
        case EVEURLConnectionCacheModeApplication:
            // get the service cache from the global cache
            if ([globalCache objectForKey:NSStringFromClass([self class])] == nil) {
                [globalCache setObject:[NSMutableDictionary dictionary] forKey:NSStringFromClass([self class])];
            }
            NSMutableDictionary *connectionCache = [globalCache objectForKey:NSStringFromClass([self class])];
            // get rid of the current response data object from the cache
            id keyToPurge = nil;
            for (id key in [connectionCache allKeys]) {
                if ([connectionCache objectForKey:key] == responseData) {
                    keyToPurge = key;
                    break;
                }
            }
            if (keyToPurge != nil) {
                [connectionCache removeObjectForKey:keyToPurge];
            }
            break;
    }
}

- (void)invokeSOAPRequest:(NSURLRequest*)soapRequest method:(NSString *)method queryString:(NSString *)query content:(NSData *)content{
    // clear out our data cache, which will be as we receive data from the server.  in addition, if
    // we need to cache this particular request, then this will be the object that holds the
    // response.
    [self setResponseData:[NSMutableData data]];

    // if we have a cached response for this request, use it.  since every connection instance is
    // tied to a unique URL, the only differences (as far as what we support) are what we send in
    // the content body of the post -- so that is what we key on.
    NSMutableData *cache = [self cachedResponse:content];
    if (cache != nil) {
        // save the cached response
        [self setResponseData:cache];
        // by default, all cached responses are buffered
        [self setResponseBuffered:YES];
        // handle the cached data.
        [self connectionDidFinishLoading:connection];
    } else {
        // concatenate the query and URL
        // We need to fix this, If we have to send some data in query stirng.
        NSString *urlAndQuery = self.url;
        if (query != nil) {
            urlAndQuery = [NSString stringWithFormat:@"%@?%@", self.url, query];
        }
        // log the request
        [self logRequest:method content:content];
        // begin loading the data
        [self setConnection:[NSURLConnection connectionWithRequest:soapRequest delegate:self]];
        // tell the connection to begin
        [self.connection start];
        // mark the connection as active
        [self setConnectionActive:YES];
    }

}

- (BOOL)active {
    return connectionActive;
}

- (void)cancel {
    [self setConnectionActive:NO];
    // if the connection is active and we're streaming...
    if (connectionActive && file != nil) {
        // close up the file
        [self.file closeFile];
        // and delete it -- since the connection is still active we didn't get the entire thing
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    // if this service is participating in any kind of caching, make sure to clear out the current
    // response cache since we got cancelled
    if (connectionActive) {
        [self purgeCacheForCurrentRequest];
    }
    [self.connection cancel];
    [self setResponseData:nil];
    [self setConnection:nil];
}

#pragma mark NSURLConnection

- (void)connection:(NSURLConnection *)c didReceiveResponse:(NSURLResponse *)response {
    // we seem to be having hanging connections in the background -- if we get any notifications
    // from an old connection ignore them
    if (self.connection != c || !connectionActive) {
        return;
    }
    // by default buffer the response if we have no buffered content types
    [self setResponseBuffered:([bufferedContentTypes count] == 0)];
    // loop over all the content types to determine if we should buffer this response
    for (NSString *contentType in bufferedContentTypes) {
        if ([contentType isEqualToString:[response MIMEType]]) {
            [self setResponseBuffered:YES];
            break;
        }
    }
    int statusCode = [((NSHTTPURLResponse *)response) statusCode];
    // extract the headers and forward to whom registered
    NSDictionary *header = [(NSHTTPURLResponse *) response allHeaderFields];
    NSMutableDictionary *headerDic = [NSMutableDictionary dictionaryWithDictionary:header];
    [headerDic setObject:[NSNumber numberWithInteger:statusCode] forKey:@"statusCode"];
    if ([self.delegate respondsToSelector:@selector(connection:didReceiveResponseHeader:)]) {
        [self.delegate connection:self didReceiveResponseHeader:headerDic];
    }
}

- (void)connection:(NSURLConnection *)c didReceiveData:(NSData *)data {
    // we seem to be having hanging connections in the background -- if we get any notifications
    // from an old connection ignore them
    if (self.connection != c || !connectionActive) {
        return;
    }
    if (responseBuffered) {
        // buffer the data, if we're running in buffered zone
        [self.responseData appendData:data];
    } else {
        // append the data to the file we've created
        [self.file writeData:data];
        // tell the delegate what we've gotten so far
        if ([self.delegate respondsToSelector:@selector(connection:hasDownloaded:)]) {
            [self.delegate connection:self hasDownloaded:[self.file offsetInFile]];
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)c {
    // we seem to be having hanging connections in the background -- if we get any notifications
    // from an old connection ignore them
    if (self.connection != c || !connectionActive) {
        return;
    }
    [self setConnectionActive:NO];
    if (responseBuffered) {
        // log the response if configured for it
        [self logResponse];
        // notify the retriever that we've retrieved our data
        [self.delegate connection:self didReceiveData:[self responseData]];
    } else {
        [self.delegate connection:self didFinishStreaming:filePath];
    }
}

- (void)connection:(NSURLConnection *)c didFailWithError:(NSError *)error {
    // we seem to be having hanging connections in the background -- if we get any notifications
    // from an old connection ignore them
    if (self.connection != c || !connectionActive) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(connection:didFailWithError:)]) {
		[self.delegate connection:self didFailWithError:error];
	}
    [self setConnectionActive:NO];
    NSLog(@"Connection failed with error %@ %d", [error domain], [error code]);
}

#pragma mark CoreURLConnection(Private)

- (void)logRequest:(NSString *)method content:(NSData *)content {
    NSLog(@"====================================================================================");
    NSLog(@"Executing request for URL: %@ and method: %@", url, method);
    if (content != nil) {
        NSLog(@"Content: %@", [[NSString alloc] initWithData:content encoding:NSASCIIStringEncoding]);
    }
    NSLog(@"====================================================================================");
}

- (void)logResponse {
    NSLog(@"====================================================================================");
    if ([responseData length] > 10240) {
        NSLog(@"Connection returned over 10K of data; not logging");
    } else {
        NSLog(@"Connection returned data: %@", [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding]);
    }
    NSLog(@"====================================================================================");
}

@end
