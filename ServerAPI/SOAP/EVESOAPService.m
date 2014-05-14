/*Created by Muhammad Imran on 4/6/14. */

#import "EVESOAPService.h"
#import "SOAPFault.h"
#import "EVEKeyGenrator.h"

#define kCharsetUTF8Value @"text/xml; charset=utf-8"
#define kContentTypeHeader @"Content-Type"
#define kContentLengthHeader @"Content-Length"
#define kSOAPActionHeader @"SOAPAction"
#define kPOSTRequest @"POST"
#define kGETRequest @"GET";

@interface EVESOAPService ()

- (NSString*)sopaRequestWithXMLBoday:(NSString *)xml;

@end

@implementation EVESOAPService

- (id)initWithServiceURL:(NSString*)serviceURLString endPoint:(NSString *)paramEndPoint cacheMode:(EVEURLConnectionCacheMode)cacheMode{
    if (self = [super initWithRootUrl:kBaseServerURL serviceUrl:serviceURLString]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseServerURL,serviceURLString]];
        endPoint = paramEndPoint;
        self.cacheMode = cacheMode;
        [self.connection setCacheMode:self.cacheMode];
    }

    return self;
}

- (void)setResponseCacheMode:(EVEURLConnectionCacheMode)cahceMode {
    [self.connection setCacheMode:cahceMode];
}

- (NSString*)sopaRequestWithXMLBoday:(NSString *)xml {
    NSMutableString *soapMessage =[NSMutableString stringWithString:@"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\">"];
    [soapMessage appendString:@"<soapenv:Header/>"];
    [soapMessage appendString:@"<soapenv:Body>"];
    [soapMessage appendString:xml];
    [soapMessage appendString:@"</soapenv:Body>"];
    [soapMessage appendString:@"</soapenv:Envelope>"];
    return soapMessage;
}

- (void)doSoapRequest:(NSString *)xml{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *mesage = [self sopaRequestWithXMLBoday:xml];
	NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[mesage length]];
	[request addValue:kCharsetUTF8Value forHTTPHeaderField:kContentTypeHeader];
    [request addValue:endPoint forHTTPHeaderField: kSOAPActionHeader];
	[request addValue: msgLength forHTTPHeaderField:kContentLengthHeader];
	[request setHTTPMethod:kPOSTRequest];
	[request setHTTPBody: [mesage dataUsingEncoding:NSUTF8StringEncoding]];

    NSURL *soapActionURL = [NSURL URLWithString:endPoint];

    NSMutableString *cacheKey = [NSMutableString stringWithFormat:@"%@/%@",url, [[soapActionURL pathComponents] lastObject]];
    /*
     We need to make the cache keys unique for requests for getting data in chunks (Pagings etc..)
     for this we are appending the XML contenet from current request in cache key. It will make our cache key unique for request with same URL, same Method and same Language. (XML content will be difrent for each request)
     */
    [cacheKey appendFormat:@"-%@",xml];

    [self.connection invokeSOAPRequest:request cacheKey:[EVEKeyGenrator md5Key:cacheKey] queryString:nil];
}

#pragma mark CoreRESTService

- (void)didReceiveError:(EVEError *)error {

    // check for a session timeout...
    if (error.statusCode == 403) {
        // post a notification that the user's session timed out
        [[NSNotificationCenter defaultCenter] postNotificationName:kCommonSessionTimeout
                                                            object:nil];
    } else if (error.statusCode == 400 || error.statusCode == 401 ) {
        // post a notification that requested entuty not found
        [[NSNotificationCenter defaultCenter] postNotificationName:kAuthorizationFailureNotification
                                                            object:nil];
    }
    // all other errors are concerened unhandled and unexpected
    else {
        // post a notification that the server returned an error
        [[NSNotificationCenter defaultCenter] postNotificationName:kCommonUnexpectedServerError
                                                            object:nil];
    }
}


@end
