/*Created by Muhammad Imran on 4/6/14. */

#import <Foundation/Foundation.h>

@class XMLContextConfiguration;

/*!
 @discussion
    Unmarshals a given XML document to a pre-configured Objective-C object.
 */
@interface XMLUnmarshaller : NSObject {
    /*!
     @discussion
        The current XML context configuration.  Contains type mappers, mapping definitions, etc.
     */
    XMLContextConfiguration *contextConfiguration;
}

@property (nonatomic, strong) XMLContextConfiguration *contextConfiguration;

/*!
 @discussion
    Initializes a new XMLMarshaller instance with the given configuration context.
 @result
    The object instance.
 */
- (id)initWithContextConfiguration:(XMLContextConfiguration *)contextConfiguration;

/*!
 @discussion
    Unmarshals the given XML document to a configured Objective-C object.  The unmarshalling 
    framework will automatically select the mapping to use based on the name of the root node.
 @param xml
    The XML to unmarshal.
 @result
    The unmarshalled Objective-C object.
 */
- (id)unmarshal:(NSString *)xml;

/*!
 @discussion
    Unmarshals the given XML document to a configured Objective-C object.  In this case, you must
    provide a mapping to use for the document.  Use this method when there could be multiple 
    mappings provided for the same root node, which would make auto selection impossible.
 @param xml
    The XML document to unmarshal
 @param rootNode
    The class that implements the mappings for the root of the document.
 @result
    The unmarshalled Objective-C object.
 */
- (id)unmarshal:(NSString *)xml rootNode:(Class)rootNode;

@end
