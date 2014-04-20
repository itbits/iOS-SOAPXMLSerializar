/*Created by Muhammad Imran on 4/6/14. */

#import "CoreWebService.h"
#import "XMLContext.h"
#import "XMLMarshaller.h"
#import "XMLUnmarshaller.h"
#import "EventoServerAPIConstants.h"
#import <UIKit/UIDevice.h>

@implementation CoreWebService

@synthesize rootURL;
@synthesize delegate;
@synthesize connection;
@synthesize method;
@synthesize responseClass;

#pragma mark Initialization

- (id)initWithRootUrl:(NSString *)rootUrl serviceUrl:(NSString *)serviceUrl {
    if ((self = [super init])) {
        // calculate the fully qualified REST URL
        NSString *fullyQualifiedUrl = [NSString stringWithFormat:@"%@%@", rootUrl, serviceUrl];
        // create and initialize the connection
        [self setConnection:[[CoreURLConnection alloc] initWithDelegate:self
                                                                         url:fullyQualifiedUrl]];
        // set the content type to buffer
        [self.connection setBufferedContentTypes:[NSArray arrayWithObject:@"text/xml"]];
    }
    return (self);
}

- (void)setUrl:(NSString *)rootUrl serviceUrl:(NSString *)serviceUrl {
    // calculate the fully qualified REST URL
    NSString *fullyQualifiedUrl = [NSString stringWithFormat:@"%@%@", rootUrl, serviceUrl];
    // create and initialize the connection
    [self setConnection:[[CoreURLConnection alloc] initWithDelegate:self
                                                                     url:fullyQualifiedUrl]];
    // set the content type to buffer
    [self.connection setBufferedContentTypes:[NSArray arrayWithObject:@"text/xml"]];
}

- (NSString*)removeExtraSOAPTags:(NSString*)sopString {
    NSString *soapString = [NSString stringWithString:sopString];
    NSRange rangForBodyStartingTag = [soapString rangeOfString:@"Body>" options:NSCaseInsensitiveSearch];
    soapString = [soapString substringFromIndex:(rangForBodyStartingTag.location + rangForBodyStartingTag.length)];

    NSRange rangForBodyEndingTag = [soapString rangeOfString:@"Body>" options:NSBackwardsSearch];
    soapString = [soapString substringToIndex:(rangForBodyEndingTag.location)];
    // Remove the extra stirng after last closing tag

    NSRange rang = [soapString rangeOfString:@">" options:NSBackwardsSearch];
    return [soapString substringToIndex:(rang.location+1)];
}

#pragma mark CoreWebServiceService

- (BOOL)active {
    return [self.connection active];
}

- (void)cancel {
    [self.connection cancel];
}

- (BOOL)isErrorResponse:(id)xmlObject {
    return (NO);
}

- (void)didReceiveError:(id)xmlObject {
}

#pragma mark CoreURLConnectionDelegate

- (void)connection:(CoreURLConnection *)c didReceiveData:(NSData *)data {
    // deserialize the data as XML, if any data is present
    id xmlObject = nil;
    if (data != nil && [data length] > 0) {
        // get a new unmarshaller reference
        XMLUnmarshaller *unmarshaller = [[XMLContext context] createUnmarshaller];
        //Remove Extra SOAP tags from XML, this will be helpful for simplifing XML maps
        NSString *soapString = [self removeExtraSOAPTags:[[NSString alloc] initWithData:data
                                                                encoding:NSUTF8StringEncoding]];
        // check to see if we have a manually configured root node...
        if (responseClass != NULL) {
            xmlObject = [unmarshaller unmarshal:soapString
                                       rootNode:responseClass];
        } else {
            // have the unmarshaller deserialize the XML object
            xmlObject = [unmarshaller unmarshal:soapString];
        }
    }
    // if this XML response represents an error
    if ([self isErrorResponse:xmlObject]) {
        // if the delegate responds to the handling selector, see if it wants to handle it
        BOOL errorHandled = NO;
        if ([delegate respondsToSelector:@selector(soapService:didReceiveError:)]) {
            errorHandled = [delegate soapService:self didReceiveError:xmlObject];
        }
        // if the error hasn't been handled, allow the subclass to handle it
        if (!errorHandled) {
            [self didReceiveError:xmlObject];
        }
    }
    // otherwise, we got a normal response
    else {
        //send the delegate message
        [delegate soapService:self didGet:xmlObject];
    }
}

- (void)connection:(CoreURLConnection *)connection hasDownloaded:(NSInteger)downloadedBytes {
    if ([delegate respondsToSelector:@selector(soapService:hasDownloaded:)]) {
        [delegate soapService:self hasDownloaded:downloadedBytes];
    }
}

- (void)connection:(CoreURLConnection *)connection didFinishStreaming:(NSString *)filePath {
    if ([delegate respondsToSelector:@selector(soapService:didFinishStreaming:)]) {
        [delegate soapService:self didFinishStreaming:filePath];
    }
}

- (void)connection:(CoreURLConnection *)con didReceiveResponseHeader:(NSDictionary *)responseH {
    // For handling the Page not found or redirection error we have to get the status code from responce header.
    int statusCode = [[responseH objectForKey:@"statusCode"] intValue];
    [self setResponseHeader:responseH];
    if (statusCode == 404) {
        BOOL errorHandled = NO;
        if ([delegate respondsToSelector:@selector(soapService:didReceiveError:)]) {
            errorHandled = [delegate soapService:self didReceiveError:nil];
        }
        if (!errorHandled) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kCommonUnableToAccessServices
                                                                object:nil];
        }
        [con cancel];
        //pass the response header data to controller.
    } else if ([self.delegate respondsToSelector:@selector(soapService:didReceiveResponseHeader:)]) {
        [self.delegate soapService:self didReceiveResponseHeader:responseH];
    }
}

@end
