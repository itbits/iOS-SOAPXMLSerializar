//
//  EVEError.h
//  TextXMLMapping
//
//  Created by Muhammad Imran on 5/4/14.
//
//

#import <Foundation/Foundation.h>

@interface EVEError : NSObject {

}

@property (nonatomic, assign) int statusCode;
@property (nonatomic, assign) int subCode;
@property (nonatomic, strong) id soapFault;


@end
