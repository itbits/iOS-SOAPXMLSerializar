/*Created by Muhammad Imran on 4/6/14. */

#import <Foundation/Foundation.h>

@class XMLContextConfiguration;
@class XMLMarshaller;
@class XMLUnmarshaller;


@interface XMLContext : NSObject {

@protected
    XMLContextConfiguration *contextConfiguration;
}

@property (nonatomic, strong) XMLContextConfiguration *contextConfiguration;

+ (XMLContext *)context;
- (XMLMarshaller *)createMarshaller;
- (XMLUnmarshaller *)createUnmarshaller;

@end
