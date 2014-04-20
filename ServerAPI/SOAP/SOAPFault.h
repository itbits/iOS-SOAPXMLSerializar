/*Created by Muhammad Imran on 4/6/14. */

#import <Foundation/Foundation.h>

/*!
 @class
 SOAPFault
 @abstract
 SOAPFault will handle the SOAP fault response
 @discussion
 This class defines the SOAP fault response.
 */
@interface SOAPFault : NSObject {

}
/*!
 @property
 faultString
 @discussion
 faultString Contains SOAP falt error message.
 */
@property (nonatomic, strong) NSString *faultString;

/*!
 @property
 faultCode
 @discussion
 faultCode Contains SOAP falt error code.
 */
@property (nonatomic, strong) NSString *faultCode;

/*!
 @discussion 
 This method will be used to check if we get error in SOAP response
 @result
 T/F true is the response is error
 */
- (BOOL)isErrorResponse;

@end
