/*Created by Muhammad Imran on 4/6/14. */

#import <libxml/parser.h>
#import <libxml/xmlwriter.h>
#import <libxml/xmlmemory.h>

#import "XMLMarshaller.h"
#import "XMLTypeMapper.h"
#import "XMLMapping.h"
#import "XMLContextConfiguration.h"

@implementation XMLMarshaller

@synthesize contextConfiguration;

#pragma mark Initialization

- (id)initWithContextConfiguration:(XMLContextConfiguration *)config {
    if (self = [super init]) {
        [self setContextConfiguration:config];
    }
    return (self);
}

#pragma mark XMLMarshaller

- (void)marshal:(id)object nodeName:(NSString *)nodeName toWriter:(xmlTextWriterPtr)writer {
    // retrieve the mapping for this class from the configuration
    XMLMapping *classMapping = [contextConfiguration mappingForClassName:NSStringFromClass([object class])];
    
    // asser that we actually have the class mapped
    NSAssert(classMapping != nil, @"class is not mapped");
    
    // start the root element for this object, if required
    if ([classMapping rootNode] != nil) {
        xmlTextWriterStartElement(writer, nodeName != nil ?
                                  BAD_CAST [nodeName UTF8String] :  
                                  BAD_CAST [[classMapping rootNode] UTF8String]);
    }
    
    // first marshal all the basic primitive types 
    for (NSString *nodeName in [[classMapping primitiveNodeMappings] keyEnumerator]) {
        // get the XMLNodeMapping for this node
        XMLNodeMapping *mapping = [[classMapping primitiveNodeMappings] objectForKey:nodeName];
        
        // retrieve the property value from the object
        id value = [object valueForKey:[mapping property]];
        
        // if the value is nil and we're not required to serialize an empty element, move on to the
        // next configured node
        if (value == nil && ![mapping serializeNil]) {
            continue;
        }
        
        // get the XMLTypeMapper that is responsible for serializing this value
        id typeMapper = [self.contextConfiguration typeMapperForType:[mapping type]];
        
        // serialize the object to an NSString
        NSString *stringValue = [typeMapper toXML:value
                                typeConfiguration:[mapping typeConfiguration]];
        
        // write the converted string value out to the writer
        xmlTextWriterWriteElement(writer, BAD_CAST [nodeName UTF8String], BAD_CAST [stringValue UTF8String]);
    }
    
    // marshal all the object references
    for (XMLNodeMapping *mapping in [classMapping referenceNodeMappings]) {
        // retrieve the property value from the object
        id value = [object valueForKey:[mapping property]];
        
        // if the value is nil and we're not required to serialize an empty element, move on to the
        // next configured node
        if (value == nil && ![mapping serializeNil]) {
            continue;
        }
        
        // recurse in
        [self marshal:value nodeName:[[mapping typeConfiguration] objectForKey:@"referenceNode"] toWriter:writer];
    }
    
    // marshal all the arrays
    for (XMLNodeMapping *mapping in [classMapping arrayNodeMappings]) {
        // retrieve the property value from the object
        NSArray *value = (NSArray *)[object valueForKey:[mapping property]];
        
        // if the value is nil and we're not required to serialize an empty element, move on to the
        // next configured node
        if (value == nil && ![mapping serializeNil]) {
            continue;
        }
        
        NSDictionary *typeConfiguration = [mapping typeConfiguration];
        
        // if the configured node is the wrapper element
        if ([[typeConfiguration objectForKey:@"wrapperNode"] length] > 0) {
            // start a new embedded element to contain the items
            xmlTextWriterStartElement(writer, BAD_CAST [[typeConfiguration objectForKey:@"wrapperNode"] UTF8String]);
        }
        
        // loop over all objects in the array
        for (id arrayValue in value) {
            // if the embeeded element type is a reference
            if ([[typeConfiguration objectForKey:@"type"] isEqualToString:@"reference"]) {
                // recurse in
                [self marshal:arrayValue nodeName:[typeConfiguration objectForKey:@"referenceNode"] toWriter:writer];
            }
            // otherwise we treat it as a primitive
            else {                
                // get the XMLTypeMapper that is responsible for serializing this value
                id typeMapper = [self.contextConfiguration typeMapperForType:[typeConfiguration objectForKey:@"type"]];

                // serialize the object to an NSString
                NSString *stringValue = [typeMapper toXML:arrayValue
                                        typeConfiguration:nil];
                
                // write the converted string value out to the writer
                xmlTextWriterWriteElement(writer, BAD_CAST [[typeConfiguration objectForKey:@"referenceNode"] UTF8String], BAD_CAST [stringValue UTF8String]);
            }
        }
        
        // close the wrapper element if needed
        if ([[typeConfiguration objectForKey:@"wrapperNode"] length] > 0) {
            // end the surrounding element
            xmlTextWriterEndElement(writer);
        }
    }
        
    // end the root element for this object, if required
    if ([classMapping rootNode] != nil) {
        xmlTextWriterEndElement(writer);
    }
}
- (NSString *)marshal:(id)object {
    // create the buffer in which the XML document will be created
    xmlBufferPtr buffer = xmlBufferCreate();
    
    // create the XML writer that we'll use to traverse the objects and create the XML
    xmlTextWriterPtr writer = xmlNewTextWriterMemory(buffer, 0);
    
    // beginning with this object, drill down and create the XML
    [self marshal:object nodeName:nil toWriter:writer];
    
    // end the document, flushing any remaining data to the underlying buffer
    xmlTextWriterEndDocument(writer);
    
    // our buffer is now filled, so convert it to an NSString
    NSString *xml = [NSString stringWithCString:(const char *)buffer->content encoding:NSUTF8StringEncoding];
    
    // free up utilized memory
    xmlFreeTextWriter(writer);
    xmlBufferFree(buffer);
    
    // return the XML document
    return (xml);
}

@end
