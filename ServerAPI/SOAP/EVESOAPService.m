/*Created by Muhammad Imran on 4/6/14. */

#import "EVESOAPService.h"
#import "SOAPFault.h"

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

- (id)initWithServiceURL:(NSString*)serviceURLString endPoint:(NSString *)paramEndPoint{
    if (self = [super initWithRootUrl:kBaseServerURL serviceUrl:serviceURLString]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseServerURL,serviceURLString]];
        endPoint = paramEndPoint;
    }

    return self;
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
	NSString *msgLength = [NSString stringWithFormat:@"%d", [mesage length]];
	[request addValue:kCharsetUTF8Value forHTTPHeaderField:kContentTypeHeader];
    [request addValue:endPoint forHTTPHeaderField: kSOAPActionHeader];
	[request addValue: msgLength forHTTPHeaderField:kContentLengthHeader];
	[request setHTTPMethod:kPOSTRequest];
	[request setHTTPBody: [mesage dataUsingEncoding:NSUTF8StringEncoding]];
    [self.connection invokeSOAPRequest:request method:kPOSTRequest queryString:nil content:nil];
}

#pragma mark CoreRESTService

- (BOOL)isErrorResponse:(id)xmlObject {
    if ([xmlObject respondsToSelector:@selector(isErrorResponse)]) {
        return [(SOAPFault*)xmlObject isErrorResponse];
    }
    int statusCode = [[self.responseHeader objectForKey:@"statusCode"] intValue];// if the response has a status attribute
    if (statusCode >=200 && statusCode < 230) {
        return NO;
    }
    return YES;
}

- (void)didReceiveError:(id)xmlObject {
    // grab the status object
    //EventoStatus *status = (EventoStatus *)[xmlObject performSelector:@selector(status)];
    int statusCode = [[self.responseHeader objectForKey:@"statusCode"] intValue];
    // check for a session timeout...
    if (statusCode == 403) {
        // post a notification that the user's session timed out
        [[NSNotificationCenter defaultCenter] postNotificationName:kCommonSessionTimeout
                                                            object:nil];
    } else if (statusCode == 400 || statusCode == 401 ) {
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

#pragma mark CoreURLConnectionDelegate

- (void)connection:(CoreURLConnection *)connection didFailWithError:(NSError *)error {
	// post a notification that we can't reach the service
	[[NSNotificationCenter defaultCenter] postNotificationName:kCommonUnableToAccessServices
														object:nil];
}

@end
