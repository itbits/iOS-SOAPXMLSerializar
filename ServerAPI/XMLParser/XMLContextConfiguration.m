/*Created by Muhammad Imran on 4/6/14. */

#import "XMLContextConfiguration.h"
#import "XMLTypeMapper.h"
#import "XMLMapping.h"

@implementation XMLContextConfiguration

@synthesize typeMappers;
@synthesize mapsByClassName;
@synthesize mapsByRootNode;

- (id)init {
    if (self = [super init]) {
        [self setTypeMappers:[NSMutableDictionary dictionary]];
        [self setMapsByClassName:[NSMutableDictionary dictionary]];
        [self setMapsByRootNode:[NSMutableDictionary dictionary]];
    }
    return (self);
}

- (void)registerType:(NSString *)type withMapper:(XMLTypeMapper *)mapper {
    [self.typeMappers setObject:mapper forKey:type];
}
- (XMLTypeMapper *)typeMapperForType:(NSString *)type {
    return [self.typeMappers objectForKey:type];
}

- (void)registerMapping:(XMLMapping *)mapping {
    NSLog(@"ILXML: Registering mapping for root node \"%@\", class \"%@\"", [mapping rootNode], [mapping className]);
    
    // only store the mappings by root-node for those that support it.  those that don't are 
    // typically classes that are referenced only and are never used as the root.
    if ([mapping rootNode] != nil) {
        [self.mapsByRootNode setObject:mapping
                                forKey:[mapping rootNode]];
    }
    
    // every mapping has a class associated with it, regardless of how it's serialized...
    [self.mapsByClassName setObject:mapping
                             forKey:[mapping className]];
}
- (XMLMapping *)mappingForClassName:(NSString *)className {
    XMLMapping *mapping = [mapsByClassName objectForKey:className];
    return (mapping);
}
- (XMLMapping *)mappingForRootNode:(NSString *)rootNode {
    XMLMapping *mapping = [mapsByRootNode objectForKey:rootNode];
    return (mapping);
}

@end
