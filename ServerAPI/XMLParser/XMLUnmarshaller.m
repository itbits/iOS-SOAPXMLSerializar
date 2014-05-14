/*Created by Muhammad Imran on 4/6/14. */

#import <objc/runtime.h>

#import <libxml/parser.h>
#import <libxml/xmlwriter.h>
#import <libxml/xmlmemory.h>

#import "XMLContext.h"
#import "XMLUnmarshaller.h"
#import "XMLContextConfiguration.h"
#import "XMLTypeMapper.h"
#import "XMLMapping.h"

@implementation XMLUnmarshaller

@synthesize contextConfiguration;

#pragma mark Initialization

- (id)initWithContextConfiguration:(XMLContextConfiguration *)config {
    if (self = [super init]) {
        [self setContextConfiguration:config];
    }
    return (self);
}

#pragma mark XMLUnmarshaller(Private)

- (XMLMapping *)referenceMappingForNodeName:(NSString *)nodeName typeConfiguration:(NSDictionary *)typeConfiguration {
    // if there is a match for the node name, return it
    if ([[typeConfiguration objectForKey:@"referenceNode"] isEqualToString:nodeName]) {
        // and return the mapping for it
        return [[[XMLContext context] contextConfiguration] mappingForClassName:[typeConfiguration objectForKey:@"referenceClass"]];
    }
    // if that failed, check to see if there is a class to check
    if ([typeConfiguration objectForKey:@"referenceIsKindOf"] != nil) {
        // get the kind of class to check
        Class referenceClass = NSClassFromString([typeConfiguration objectForKey:@"referenceIsKindOf"]);
            
        // attempt a lookup of the node on the context configuration
        XMLMapping *mapping = [[[XMLContext context] contextConfiguration] mappingForRootNode:nodeName];
            
        // if we were able to look up the node AND it's correct, return it
        if (mapping != nil && [NSClassFromString([mapping className]) isKindOfClass:referenceClass]) {
            return mapping;
        }
    }
    // if that failed, see if there is a protocol to check
    if ([typeConfiguration objectForKey:@"referenceConformsTo"] != nil) {
        // get the kind of protocol to check
        Protocol *referenceProtocol = NSProtocolFromString([typeConfiguration objectForKey:@"referenceConformsTo"]);
            
        // attempt a lookup of the node on the context configuration
        XMLMapping *mapping = [[[XMLContext context] contextConfiguration] mappingForRootNode:nodeName];
            
        // if we were able to look up the node AND it's correct, return it
        if (mapping != nil && [NSClassFromString([mapping className]) conformsToProtocol:referenceProtocol]) {
            return mapping;
        }
    }
    return nil;
}

- (XMLNodeMapping *)nodeMappingForReferenceNodeName:(NSString *)nodeName inMapping:(XMLMapping *)inMapping {
    for (XMLNodeMapping *referenceMapping in [inMapping referenceNodeMappings]) {
        // if there is a match for the node name, return it
        if ([[referenceMapping.typeConfiguration objectForKey:@"referenceNode"] isEqualToString:nodeName]) {
            // and return the mapping for it
            return referenceMapping;
        }
        // if that failed, check to see if there is a class to check
        if ([referenceMapping.typeConfiguration objectForKey:@"referenceIsKindOf"] != nil) {
            // get the kind of class to check
            Class referenceClass = NSClassFromString([referenceMapping.typeConfiguration objectForKey:@"referenceIsKindOf"]);
            
            // attempt a lookup of the node on the context configuration
            XMLMapping *mapping = [[[XMLContext context] contextConfiguration] mappingForRootNode:nodeName];
            
            // if we were able to look up the node AND it's correct, return it
            if (mapping != nil && [NSClassFromString([mapping className]) isKindOfClass:referenceClass]) {
                return referenceMapping;
            }
        }
        // if that failed, see if there is a protocol to check
        if ([referenceMapping.typeConfiguration objectForKey:@"referenceConformsTo"] != nil) {
            // get the kind of protocol to check
            Protocol *referenceProtocol = NSProtocolFromString([referenceMapping.typeConfiguration objectForKey:@"referenceConformsTo"]);
            
            // attempt a lookup of the node on the context configuration
            XMLMapping *mapping = [[[XMLContext context] contextConfiguration] mappingForRootNode:nodeName];
            
            // if we were able to look up the node AND it's correct, return it
            if (mapping != nil && [NSClassFromString([mapping className]) conformsToProtocol:referenceProtocol]) {
                return referenceMapping;
            }
        }
    }
    return nil;
}
- (XMLMapping *)mappingForReferenceNodeName:(NSString *)nodeName inMapping:(XMLMapping *)inMapping {
    // loop over all the reference mappings in the class mapping
    for (XMLNodeMapping *referenceMapping in [inMapping referenceNodeMappings]) {
        // see if this reference node matches the node name 
        XMLMapping *mapping = [self referenceMappingForNodeName:nodeName 
                                              typeConfiguration:[referenceMapping typeConfiguration]];
        
        // if so, return it
        if (mapping != nil) {
            return (mapping);
        }
    }
    return nil;
}

- (XMLNodeMapping *)nodeMappingForArrayWithWrapperForNodeName:(NSString *)nodeName inMapping:(XMLMapping *)inMapping node:(xmlNodePtr)node {
    for (XMLNodeMapping *arrayMapping in [inMapping arrayNodeMappings]) {
        NSDictionary *typeConfig = arrayMapping.typeConfiguration;
        
        if ([[typeConfig objectForKey:@"wrapperNode"] isEqualToString:nodeName]) {
            NSString *wrapperNodeAttribute = [typeConfig objectForKey:@"wrapperNodeAttribute"];
            NSString *wrapperNodeAttributeValue = [typeConfig objectForKey:@"wrapperNodeAttributeValue"];
            
            // check to see if we need to key off a name/value attribute pair
            if (wrapperNodeAttribute != nil && wrapperNodeAttributeValue != nil) {
                // in this case, we only return the wrapper node if the attribute/value pair matches
                if (xmlHasProp(node, BAD_CAST [wrapperNodeAttribute UTF8String])) {
                    xmlChar *xmlPropValue = xmlGetProp(node, BAD_CAST [wrapperNodeAttribute UTF8String]);
                    NSString *propValue = [NSString stringWithUTF8String:(const char *)xmlPropValue];
                    xmlFree(xmlPropValue);
                    
                    if ([propValue isEqualToString:wrapperNodeAttributeValue]) {
                        return (arrayMapping);
                    }
                }
            }
            // otherwise just return the found node
            else {
                return (arrayMapping);
            }
        }
    }
    return nil;
}
- (XMLNodeMapping *)nodeMappingForArrayWithNodeName:(NSString *)nodeName inMapping:(XMLMapping *)inMapping {
    for (XMLNodeMapping *arrayMapping in [inMapping arrayNodeMappings]) {
        // skip any mappings configured with wrapper nodes -- those are taken care of elsewhere
        if ([arrayMapping.typeConfiguration objectForKey:@"wrapperNode"] != nil) {
            continue;
        }
        
        // if we have a reference node name configured that matches this node name, take it
        if ([[arrayMapping.typeConfiguration objectForKey:@"referenceNode"] isEqualToString:nodeName]) {
            return arrayMapping;
        }
        
        // if that failed, check to see if there is a class to check
        if ([arrayMapping.typeConfiguration objectForKey:@"referenceIsKindOf"] != nil) {
            // get the kind of class to check
            Class referenceClass = NSClassFromString([arrayMapping.typeConfiguration objectForKey:@"referenceIsKindOf"]);
            
            // attempt a lookup of the node on the context configuration
            XMLMapping *mapping = [[[XMLContext context] contextConfiguration] mappingForRootNode:nodeName];
            
            // if we were able to look up the node AND it's correct, return it
            if (mapping != nil && [NSClassFromString([mapping className]) isKindOfClass:referenceClass]) {
                return arrayMapping;
            }
        }
        
        // if that failed, see if there is a protocol to check
        if ([arrayMapping.typeConfiguration objectForKey:@"referenceConformsTo"] != nil) {
            // get the kind of protocol to check
            Protocol *referenceProtocol = NSProtocolFromString([arrayMapping.typeConfiguration objectForKey:@"referenceConformsTo"]);
            
            // attempt a lookup of the node on the context configuration
            XMLMapping *mapping = [[[XMLContext context] contextConfiguration] mappingForRootNode:nodeName];
            
            // if we were able to look up the node AND it's correct, return it
            if (mapping != nil && [NSClassFromString([mapping className]) conformsToProtocol:referenceProtocol]) {
                return arrayMapping;
            }
        }
        
    }
    return nil;
}

- (id)typeValue:(NSString *)type typeConfiguration:(NSDictionary *)typeConfiguration document:(xmlDocPtr)document node:(xmlNodePtr)node {
    // get the XMLTypeMapper that is responsible for deserializing this value
    id typeMapper = [self.contextConfiguration typeMapperForType:type];
    
    // get the value of this node out of the XML
    xmlChar *xmlNodeValue = xmlNodeListGetString(document, node->xmlChildrenNode, 1);
    NSString *nodeValue = nil;
    if (xmlNodeValue != NULL) {
        nodeValue = [NSString stringWithCString:(const char *)xmlNodeValue
                                       encoding:NSUTF8StringEncoding];
    }
    xmlFree(xmlNodeValue);
    
    return [typeMapper toValue:nodeValue typeConfiguration:typeConfiguration];
}

- (id)unmarshal:(xmlDocPtr)xmlDocument node:(xmlNodePtr)node mapping:(XMLMapping *)mapping {
    // create a new object of the given type
    id value = [[NSClassFromString([mapping className]) alloc] init];

    // drill down one level in the XML hierarchy as we'll need to pull out all the attributes
    node = node->xmlChildrenNode;
    
    // loop over all the children
    while (node != NULL) {
		// get the mappings for this attribute
        NSString *nodeName = [NSString stringWithCString:(const char *)node->name 
                                                encoding:NSUTF8StringEncoding];
        
        // first check to see if this node is a primitive node type
        if ([mapping.primitiveNodeMappings objectForKey:nodeName] != nil) {
            // get the XMLNodeMapping that maps this XML element
            XMLNodeMapping *nodeMapping = [[mapping primitiveNodeMappings] objectForKey:nodeName];
            
            // convert the raw XML string to an Objective-C object and set it on our object
            [value setValue:[self typeValue:[nodeMapping type]
                          typeConfiguration:[nodeMapping typeConfiguration]
                                   document:xmlDocument
                                       node:node]
                     forKey:[nodeMapping property]];
        }
        // then check to see if there are any references setup that match the current node
        else if ([self mappingForReferenceNodeName:nodeName inMapping:mapping] != nil) {
            // get the XMLMapping that maps this XML element
            XMLMapping *referenceMapping = [self mappingForReferenceNodeName:nodeName inMapping:mapping];
            XMLNodeMapping *referenceNodeMapping = [self nodeMappingForReferenceNodeName:nodeName inMapping:mapping];
            
            // deserialize it and set it on the object
            [value setValue:[self unmarshal:xmlDocument node:node mapping:referenceMapping] 
                     forKey:[referenceNodeMapping property]];
        }
        // then check to see if this element is the root node containing an array
        else if ([self nodeMappingForArrayWithWrapperForNodeName:nodeName inMapping:mapping node:node] != nil) {
            // since all the child elements are in this element, drill in
            xmlNodePtr arrayNode = node->xmlChildrenNode;

            // get the node mapping out
            XMLNodeMapping *nodeMapping = [self nodeMappingForArrayWithWrapperForNodeName:nodeName inMapping:mapping node:node];
            
            // create a new array to hold all the objects
            NSMutableArray *arrayObjects = [NSMutableArray array];
            
            // loop over all child elements
            while (arrayNode != NULL) {
                // get the mappings for this attribute
                NSString *arrayNodeName = [NSString stringWithCString:(const char *)arrayNode->name 
                                                             encoding:NSUTF8StringEncoding];
                
                // if the child elements are references...
                if ([[nodeMapping.typeConfiguration objectForKey:@"type"] isEqualToString:@"reference"]) {
                    // deserialize it and add to the array
                    [arrayObjects addObject:[self unmarshal:xmlDocument
                                                       node:arrayNode
                                                    mapping:[self referenceMappingForNodeName:arrayNodeName 
                                                                            typeConfiguration:nodeMapping.typeConfiguration]]];
                } 
                // otherwise treat it as a property
                else {
                    // convert the raw XML string to an Objective-C object and set it on our object
                    [arrayObjects addObject:[self typeValue:[nodeMapping.typeConfiguration objectForKey:@"type"]
                                          typeConfiguration:nil
                                                   document:xmlDocument
                                                       node:arrayNode]];
                }
                
                // next child
                arrayNode = arrayNode->next;
            }
            
            // finally set the array on the value
            [value setValue:arrayObjects
                     forKey:[nodeMapping property]];
        }
        // final fallback -- see if this node is contained in an anonymous array (without a root node)
        else if ([self nodeMappingForArrayWithNodeName:nodeName inMapping:mapping] != nil) {
            // get the node mapping
            XMLNodeMapping *nodeMapping = [self nodeMappingForArrayWithNodeName:nodeName inMapping:mapping];
            
            // make sure we have an NSMutableArray set on the object
            if ([value valueForKey:[nodeMapping property]] == nil) {
                [value setValue:[NSMutableArray array] forKey:[nodeMapping property]];
            }
            
            // get the NSMutableArray out of the value object
            NSMutableArray *arrayObjects = [value valueForKey:[nodeMapping property]];
            
            // if the child elements are references...
            if ([[nodeMapping.typeConfiguration objectForKey:@"type"] isEqualToString:@"reference"]) {
                // deserialize it and add to the array
                [arrayObjects addObject:[self unmarshal:xmlDocument
                                                   node:node
                                                mapping:[self referenceMappingForNodeName:nodeName 
                                                                        typeConfiguration:nodeMapping.typeConfiguration]]];
            } 
            // otherwise treat it as a property
            else {
                // convert the raw XML string to an Objective-C object and set it on our object
                [arrayObjects addObject:[self typeValue:[nodeMapping.typeConfiguration objectForKey:@"type"]
                                      typeConfiguration:nil
                                               document:xmlDocument
                                                   node:node]];
            }
        }
        
        // move to the next node in the tree
        node = node->next;
    }
    
    return value;
}
- (id)unmarshal:(xmlDocPtr)xmlDocument node:(xmlNodePtr)node {
    // first we need to locate the XMLMapping for the root node we're deserializing
    XMLMapping *mapping = [self.contextConfiguration mappingForRootNode:[NSString stringWithCString:(const char *)node->name
                                                                                           encoding:NSUTF8StringEncoding]];
    
    // then unmarshal
    return [self unmarshal:xmlDocument node:node mapping:mapping];
}

#pragma mark XMLUnmarshaller

- (id)unmarshal:(NSString *)xml rootNode:(Class)rootNode {
    // convert the NSString to a C-string usable by libxml
    const char *cString = [xml cStringUsingEncoding:NSUTF8StringEncoding];
    
    // convert the XML document to an xmlDocPtr libxml2 reference
    xmlDocPtr xmlDocument = xmlParseMemory(cString, (int)strlen(cString));
    
    // get the root element
    xmlNodePtr node = xmlDocGetRootElement(xmlDocument);
    
    // look up the XMLMapping for the given class
    XMLMapping *mapping = [self.contextConfiguration mappingForClassName:NSStringFromClass(rootNode)];
    
    // get the value to return
    id value = [self unmarshal:xmlDocument node:node mapping:mapping];
    
    // free the document
    xmlFreeDoc(xmlDocument);
    
    // and return the value
    return value;
}
- (id)unmarshal:(NSString *)xml {
    // convert the NSString to a C-string usable by libxml
    const char *cString = [xml cStringUsingEncoding:NSUTF8StringEncoding];

    // convert the XML document to an xmlDocPtr libxml2 reference
    xmlDocPtr xmlDocument = xmlParseMemory(cString, (int)strlen(cString));
    
    // get the root element
    xmlNodePtr node = xmlDocGetRootElement(xmlDocument);
    
    // get the value to return
    id value = [self unmarshal:xmlDocument node:node];

    // free the document
    xmlFreeDoc(xmlDocument);
    
    // and return the value
    return value;
}

@end
