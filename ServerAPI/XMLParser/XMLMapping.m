/*Created by Muhammad Imran on 4/6/14. */

#import <libxml/parser.h>
#import <libxml/xmlmemory.h>

#import "XMLMapping.h"
#import "XMLContext.h"
#import "XMLContextConfiguration.h"

@interface XMLMapping(MapFileParser)

- (void)parseFile:(NSString *)filePath;
- (void)parseRootNode:(xmlDocPtr)xmlDocument node:(xmlNodePtr)xmlNode;
- (void)parseNodeMappings:(xmlDocPtr)xmlDocument node:(xmlNodePtr)xmlNode;
- (void)parseNodeMapping:(xmlDocPtr)xmlDocument node:(xmlNodePtr)xmlNode;
- (void)parseNodeMappingConfiguration:(XMLNodeMapping *)nodeMapping document:(xmlDocPtr)xmlDocument node:(xmlNodePtr)xmlNode;

@end

@implementation XMLNodeMapping

@synthesize node;
@synthesize property;
@synthesize type;
@synthesize typeConfiguration;
@synthesize serializeNil;


@end

@implementation XMLMapping

@synthesize className;
@synthesize rootNode;
@synthesize primitiveNodeMappings;
@synthesize referenceNodeMappings;
@synthesize arrayNodeMappings;

#pragma mark Initialization

- (id)initWithFile:(NSString *)filePath className:(NSString *)cName {
    if (self = [super init]) {
        [self setClassName:cName];
        [self setPrimitiveNodeMappings:[NSMutableDictionary dictionary]];
        [self setReferenceNodeMappings:[NSMutableArray array]];
        [self setArrayNodeMappings:[NSMutableArray array]];
        [self parseFile:filePath];
    }
    return (self);
}

#pragma mark XMLMapping

+ (BOOL)isMappingFile:(NSString *)filePath {
    // get the name of the file itself, minus all the path info and file extension
    NSString *xmlFileName = [[[filePath lastPathComponent] pathComponents] objectAtIndex:0];
    NSString *xmlRootFileName = [xmlFileName stringByDeletingPathExtension];
    
    // it's a valid name if it has an XML prefix and Map suffix
    return ([xmlRootFileName hasSuffix:@"XMLMap"]);
}
+ (NSString *)standardClassNameForMappingFile:(NSString *)filePath {
    // get the name of the file itself, minus all the path info and file extension
    NSString *xmlFileName = [[[filePath lastPathComponent] pathComponents] objectAtIndex:0];
    NSString *xmlRootFileName = [xmlFileName stringByDeletingPathExtension];
    
    // return the name of the class
    return [xmlRootFileName substringWithRange:NSMakeRange(0, [xmlRootFileName length] - 6)];
}
+ (XMLMapping *)mappingWithFile:(NSString *)filePath className:(NSString *)cName {
    return [[XMLMapping alloc] initWithFile:filePath className:cName];
}

#pragma mark XMLMapping(MapFileParser)

- (void)parseFile:(NSString *)filePath {
    // get a reference to the file using libxml2
    xmlDocPtr xmlDocument = xmlParseFile([filePath cStringUsingEncoding:NSUTF8StringEncoding]);
    
    // get a reference to the root node
    xmlNodePtr xmlNode = xmlDocGetRootElement(xmlDocument);
    
    // drill down to the children elements
    xmlNode = xmlNode->xmlChildrenNode;
    
    // loop over all the top level elements
    while (xmlNode != nil) {
        // if this node is defining the root node to use for this mapping
        if (!xmlStrcmp(xmlNode->name, BAD_CAST "root-node")) {
            xmlChar *xmlValue = xmlNodeListGetString(xmlDocument, xmlNode->xmlChildrenNode, 1);
            [self setRootNode:[NSString stringWithCString:(const char *)xmlValue 
                                                 encoding:NSUTF8StringEncoding]];
            xmlFree(xmlValue);
        }
        
        // if this node is defining all the individual node mappings
        if (!xmlStrcmp(xmlNode->name, BAD_CAST "node-mappings")) {
            [self parseNodeMappings:xmlDocument node:xmlNode];
        }
        
        // go to the next child node
        xmlNode = xmlNode->next;
    }
    
    // free up libxml2 memory
    xmlFreeDoc(xmlDocument);
}
- (void)parseNodeMappings:(xmlDocPtr)xmlDocument node:(xmlNodePtr)xmlNode {
    // drill down so we can get access to all the individual node-mappings
    xmlNode = xmlNode->xmlChildrenNode;
    
    // loop over all the children
    while (xmlNode != nil) {
        // if this is a node mapping element
        if (!xmlStrcmp(xmlNode->name, BAD_CAST "node-mapping")) {
            [self parseNodeMapping:xmlDocument node:xmlNode];
        }
        
        // move to the next node
        xmlNode = xmlNode->next;
    }
}
- (void)parseNodeMapping:(xmlDocPtr)xmlDocument node:(xmlNodePtr)xmlNode {
    // create a new XMLNodeMapping instance for this node
    XMLNodeMapping *nodeMapping = [[XMLNodeMapping alloc] init];
    
    // read out the value of the core node mapping attributes
    xmlChar *xNode         = xmlGetProp(xmlNode, BAD_CAST "node");
    xmlChar *xProperty     = xmlGetProp(xmlNode, BAD_CAST "property");
    xmlChar *xType         = xmlGetProp(xmlNode, BAD_CAST "type");
    xmlChar *xSerializeNil = xmlGetProp(xmlNode, BAD_CAST "serialize-nil");
    
    // parse out NSString values
    if (xNode != NULL) {
        [nodeMapping setNode:[NSString stringWithCString:(const char *)xNode encoding:NSUTF8StringEncoding]];
    }
    [nodeMapping setProperty:[NSString stringWithCString:(const char *)xProperty encoding:NSUTF8StringEncoding]];
    [nodeMapping setType:[NSString stringWithCString:(const char *)xType encoding:NSUTF8StringEncoding]];
    [nodeMapping setSerializeNil:(!xmlStrcmp(xSerializeNil, BAD_CAST "true"))];
    
    // free attribute values
    xmlFree(xNode);
    xmlFree(xProperty);
    xmlFree(xType);
    xmlFree(xSerializeNil);

    // set any configuration
    [self parseNodeMappingConfiguration:nodeMapping document:xmlDocument node:xmlNode];
    
    // finally save the XMLNodeMapping instance to the appropriate location
    if ([nodeMapping.type isEqualToString:@"reference"]) {
        [self.referenceNodeMappings addObject:nodeMapping];
    } else if ([nodeMapping.type isEqualToString:@"array"]) {
        [self.arrayNodeMappings addObject:nodeMapping];
    } else {
        [self.primitiveNodeMappings setObject:nodeMapping forKey:[nodeMapping node]];
    }
}
- (void)parseNodeMappingConfiguration:(XMLNodeMapping *)nodeMapping document:(xmlDocPtr)xmlDocument node:(xmlNodePtr)xmlNode {
    // drill down one level beneath the <node-mapping> configuration
    xmlNode = xmlNode->xmlChildrenNode;
    
    // create the dictionary for the configuration
    NSMutableDictionary *typeConfiguration = [NSMutableDictionary dictionary];
    
    // loop over all defined elements
    while (xmlNode != NULL) {
        // if this is a configuration element...
        if (!xmlStrcmp(xmlNode->name, BAD_CAST "type-configuration")) {
            // drill down
            xmlNodePtr xmlConfigurationNode = xmlNode->xmlChildrenNode;
            
            // loop over all the elements inside the <configuration> node
            while (xmlConfigurationNode != NULL) {
                // if this is a <property> node
                if (!xmlStrcmp(xmlConfigurationNode->name, BAD_CAST "property")) {
                    // extract the key and value attributes
                    xmlChar *key   = xmlGetProp(xmlConfigurationNode, BAD_CAST "key");
                    xmlChar *value = xmlGetProp(xmlConfigurationNode, BAD_CAST "value");
                    
                    // save the key/value pair in the config dictionary
                    [typeConfiguration setObject:[NSString stringWithCString:(const char *)value
                                                                    encoding:NSUTF8StringEncoding]
                                          forKey:[NSString stringWithCString:(const char *)key 
                                                                    encoding:NSUTF8StringEncoding]];
                    
                    // free libxml2 memory
                    xmlFree(key);
                    xmlFree(value);
                }
                
                xmlConfigurationNode = xmlConfigurationNode->next;
            }
        }
        
        // go to the next element
        xmlNode = xmlNode->next;
    }
    
    // save the configuration on the node
    [nodeMapping setTypeConfiguration:typeConfiguration];
}

@end
