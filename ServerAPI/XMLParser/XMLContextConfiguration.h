/*Created by Muhammad Imran on 4/6/14. */

#import <Foundation/Foundation.h>
#import "EventoServerAPIConstants.h"

@class XMLTypeMapper;
@class XMLMapping;

@interface XMLContextConfiguration : NSObject {

@protected
    
    NSMutableDictionary *typeMappers;
    NSMutableDictionary *mapsByClassName;
    NSMutableDictionary *mapsByRootNode;
}

@property (nonatomic, strong) NSMutableDictionary *typeMappers;
@property (nonatomic, strong) NSMutableDictionary *mapsByClassName;
@property (nonatomic, strong) NSMutableDictionary *mapsByRootNode;

- (void)registerType:(NSString *)type withMapper:(XMLTypeMapper *)mapper;
- (XMLTypeMapper *)typeMapperForType:(NSString *)type;
- (void)registerMapping:(XMLMapping *)mapping;
- (XMLMapping *)mappingForClassName:(NSString *)className;
- (XMLMapping *)mappingForRootNode:(NSString *)rootNode;

@end
