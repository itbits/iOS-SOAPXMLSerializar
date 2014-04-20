/*Created by Muhammad Imran on 4/6/14. */

#import "XMLContext.h"
#import "XMLContextConfiguration.h"
#import "XMLTypeMapper.h"
#import "XMLMapping.h"
#import "XMLMarshaller.h"
#import "XMLUnmarshaller.h"

static XMLContext *singleton;

@interface XMLContext(Setup)

- (void)setupTypeMappers;
- (void)setupMappingFiles;

@end

@implementation XMLContext

@synthesize contextConfiguration;

#pragma mark Initialization

+ (void)initialize {
    singleton = [[XMLContext alloc] init];
}
- (id)init {
    if (self = [super init]) {
        [self setContextConfiguration:[[XMLContextConfiguration alloc] init]];
        [self setupTypeMappers];
        [self setupMappingFiles];
    }
    return (self);
}

#pragma mark Public Methods

+ (XMLContext *)context {
    return singleton;
}
- (XMLUnmarshaller *)createUnmarshaller {
    return [[XMLUnmarshaller alloc] initWithContextConfiguration:contextConfiguration];
}
- (XMLMarshaller *)createMarshaller {
    return [[XMLMarshaller alloc] initWithContextConfiguration:contextConfiguration];
}

#pragma mark XMLContext(Setup)

- (void)setupTypeMappers {
    [self.contextConfiguration registerType:kStringType 
                                 withMapper:(XMLTypeMapper*)[[XMLStringTypeMapper alloc] init]];
    [self.contextConfiguration registerType:kNumberType 
                                 withMapper:(XMLTypeMapper*)[[XMLNumberTypeMapper alloc] init]];
    [self.contextConfiguration registerType:k1970DateType 
                                 withMapper:(XMLTypeMapper*)[[XML1970DateTypeMapper alloc] init]];
    [self.contextConfiguration registerType:kIntType
                                 withMapper:(XMLTypeMapper*)[[XMLIntTypeMapper alloc] init]];
    [self.contextConfiguration registerType:kBooleanType
                                 withMapper:(XMLTypeMapper*)[[XMLBooleanTypeMapper alloc] init]];
    [self.contextConfiguration registerType:kLongBooleanType
                                 withMapper:(XMLTypeMapper*)[[XMLLongBooleanTypeMapper alloc] init]];
}
- (void)setupMappingFiles {
    // get a reference to all the xml files in the current bundle
    NSArray *xmlBundleResources = 
        [[NSBundle mainBundle] pathsForResourcesOfType:@"xml" inDirectory:@""];
    
    // loop over each one
    for (NSString *xmlPath in xmlBundleResources) {
        if ([XMLMapping isMappingFile:xmlPath]) {

            // get the name of the class in the conventional format
            NSString *className = [XMLMapping standardClassNameForMappingFile:xmlPath];
            
            // convert the XML file to an XMLMapping instance
            XMLMapping *mapping = [XMLMapping mappingWithFile:xmlPath className:className];
            
            // and register it with the configuration
            [self.contextConfiguration registerMapping:mapping];
        }
    }
}

@end
