/*Created by Muhammad Imran on 4/6/14. */

#import <Foundation/Foundation.h>
#import "EventoServerAPIConstants.h"
#import "CoreWebService.h"

@interface EVESOAPService : CoreWebService {
    /*!
     @var
     url
     @discussion
     url holds the URL for current SOAP request.
     */
    NSURL *url;
    /*!
     @var
     @endPoint
     url
     @discussion
     endPoint holds the SOAP action URL for current SOAP request.
     */
    NSString *endPoint;

    
}

/**
 *	calls the webservice at specific end point, mentioned in param. grabs the response and
 *  returns to called method.
 *	@param	serviceURLString  web service url to hit.
 *	@param	paramEndPoint	  the sepcific end point in the webserivce to call.
 *
*/

- (id)initWithServiceURL:(NSString*)serviceURLString endPoint:(NSString *)paramEndPoint cacheMode:(EVEURLConnectionCacheMode)cacheMode;
/**
 *	calls the webservice at specific end point, mentioned in param. grabs the response and
 *  returns to called method.
 *	@param	xml	      web service url to hit.
 *
 */
- (void)doSoapRequest:(NSString *)xml;

- (void)setResponseCacheMode:(EVEURLConnectionCacheMode)cahceMode;

@end
