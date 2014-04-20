/*Created by Muhammad Imran on 4/6/14. */

#import <libxml/parser.h>
#import <libxml/xmlwriter.h>
#import <libxml/xmlmemory.h>
#import <Foundation/Foundation.h>

/*!
 @protocol 
    XMLTypeMapper
 @abstract 
    Defines methods required to translate to and from XML and Objective-C.
 @discussion 
    The XML mapping framework utilizes multiple instances of the XMLTypeMapper protocol to aid in
    serializing and deserializing XML data to and from Objective-C data types.  The base framework
    comes out-of-box with support for primitives NSString, NSDate, NSNumber and aggregations.
 @author
    Imran;
 */
@protocol XMLTypeMapper

/*!
 @method
    isValid:typeConfiguration:
 @abstract
    Validates that the given chunk of XML is valid for this type mapper.
 @discussion
    This method is called immediately before the toXML message is sent to the type mapper to ensure
    that the given XML value can in fact be converted to an Objective-C datatype.  This allows us to
    report better errors if we encounter invalid or unexpected XML data.
 @param xml
    The XML value for validation.
 @param typeConfiguration
    The type configuration from the XML mapping.
 @result
    YES if the value is valid, NO otherwise.
 */
- (BOOL)isValid:(NSString *)xml typeConfiguration:(NSDictionary *)typeConfiguration;

/*!
 @method 
    toXML:configuration:
 @abstract
    Convert the given Objective-C type to an XML representation.
 @discussion
    The framework calls this method to serialize the given concrete Objective-C type to XML.  As an
    example, we might model NSDate classes internally as NSDate instances -- but when they get 
    serialized to XML, the returned value could be milliseconds since the epoch.
 @param value
    The concrete Objective-C type to serialize to XML.
 @param typeConfiguration
    The type configuration from the XML mapping.
 @result
    An NSString containing the value to put into the outgoing XML document.
 */
- (NSString *)toXML:(id)value typeConfiguration:(NSDictionary *)typeConfiguration;

/*!
 @method
    toValue:
 @abstract
    Convert the given XML value to a concrete Objective-C type.
 @discussion
    The framework calls this method to deserialize XML date to concrete Objective-C objects.  As an
    example we might model NSDate classes internally as NSDate instances.  If the XML we are mapping
    exposes dates as milliseconds since the epoch, this method would take as input the millisecond
    value and return the NSDate instance.
 @param xml
    The XML value to convert to a concrete Objective-C type.
 @param typeConfiguration
    The type configuration from the XML mapping.
 @result
    The concrete Objective-C type.
 */
- (id)toValue:(NSString *)xml typeConfiguration:(NSDictionary *)typeConfiguration;

@end

#define kStringType      @"string"
#define kNumberType      @"number"
#define k1970DateType    @"1970date"
#define kIntType         @"int"
#define kBooleanType     @"boolean"
#define kLongBooleanType @"longboolean"

/*!
 @discussion
    Converts values to and from NSStrings.  All values within XML are treated literally and
    serialized to and from XML directly.
 */
@interface XMLStringTypeMapper : NSObject < XMLTypeMapper >

@end

/*!
 @discussion
    Converts values to and from NSNumbers.  Treats all values as primitive doubles and creates
    NSNumber instances based on the double value.
 */
@interface XMLNumberTypeMapper : NSObject < XMLTypeMapper >

@end

/*!
 @discussion
    Converts values to and from NSDate instances with epoch input.  Assumes the value within the XML
    document contains the number of milliseconds since the epoch (January 1st, 1970 at 12:00 GMT).
 */
@interface XML1970DateTypeMapper : NSObject < XMLTypeMapper >

@end

/*!
 @discussion
    Converts values to and from NSInteger values.
 */
@interface XMLIntTypeMapper : NSObject < XMLTypeMapper >

@end

/*!
 @discussion
    Converts values to and from BOOL values (T/F).
 */
@interface XMLBooleanTypeMapper : NSObject < XMLTypeMapper >

@end

/*!
 @discussion
    Converts values to and from BOOL values (true/false).
 */
@interface XMLLongBooleanTypeMapper : NSObject < XMLTypeMapper >

@end

