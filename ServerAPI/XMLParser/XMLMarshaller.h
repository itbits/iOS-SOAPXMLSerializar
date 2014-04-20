/*Created by Muhammad Imran on 4/6/14. */

#import <Foundation/Foundation.h>

@class XMLContextConfiguration;

/*!
 @class
    XMLMarshaller
 @abstract
    Marshals configured Objective-C classes to XML.
 @discussion
    
 */
@interface XMLMarshaller : NSObject {
    /*!
     @var
        contextConfiguration
     @discussion
        The current XML context configuration.  Contains type mappers, mapping definitions, etc.
     */
    XMLContextConfiguration *contextConfiguration;
}

@property (nonatomic, strong) XMLContextConfiguration *contextConfiguration;

/*!
 @method
    initWithContextConfiguration
 @discussion
    Initializes a new XMLMarshaller instance with the given configuration context.
 @result
    The object instance.
 */
- (id)initWithContextConfiguration:(XMLContextConfiguration *)contextConfiguration;

/*!
 @method
    marshal:
 @discussion
    Marshals the given Objective-C object to an XML structure.  Assumes that the given object will
    be the root node of an outgoing XML structure.  This method essentially initializes the libxml2
    writing engine and delegates the marshalling to marshal:toWriter.
 @param object
    The object to be marshalled to an XML structure.
 */
- (NSString *)marshal:(id)object;

@end
