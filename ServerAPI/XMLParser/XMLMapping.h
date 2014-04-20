/*Created by Muhammad Imran on 4/6/14. */

#import <UIKit/UIKit.h>

/*!
 @discussion
    Defines the mapping for a single XML node.  Each node mapping instance defines a single mapping 
    for a node in an XML structure.  It identifies the specific XML node, the attribute of the
    underlying class, the type mapper to use in converting data, etc.
 */
@interface XMLNodeMapping : NSObject {
    /*!
     @discussion
        The XML node name this mapping applies to.
     */
    NSString *node;
    
    /*!
     @discussion
        The name of the property of the underlying class that contains the value for the node.
     */
    NSString *property;
    
    /*!
     @discussion
        Defines the XMLTypeMapper instance used to marshal data to/from XML.
     */
    NSString *type;
    
    /*!
     @discussion
        Contains key/value pairs from the &lt;type-configuration/&gt; element.  This is only 
        required for certain XMLTypeMappers.  See their documentation to know what configuration 
        values, if any, are required to be set here.
     */
    NSDictionary *typeConfiguration;
    
    /*!
     @discussion
        If YES, an empty XML element (&lt;foo/&gt;) will be serialized for nil values.  By default,
        nil values are not serialized to XML.
     */
    BOOL serializeNil;
}

@property (nonatomic, strong) NSString *node;
@property (nonatomic, strong) NSString *property;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSDictionary *typeConfiguration;
@property (nonatomic) BOOL serializeNil;

@end

/*!
 @discussion
    Every class that is mapped to XML via the mapping framework will have a single instance of this
    mapping class that defines *how* the object is to be serialized and deserialized to/from XML.
    The name of the Objective-C class and XML mapping file can be inferred from each other.  For an
    XML class XMLFoo, the mapping file should be called XMLFooMap.xml.  For a mapping file 
    XMLBarMap.xml, the Objective-C class should be named XMLBar.
 */
@interface XMLMapping : NSObject {
    
    /*!
     @discussion
        Defines the name of the class that maps to this XMLMapping instance.  The class should 
        comply with KVC.
     */
    NSString *className;
    
    /*!
     @discussion
        When the class is serialized to XML it is wrapped in this rootNode.  If a class is mapped
        as an embedded reference, then the rootNode is ignored and is taken instead to be the 
        attribute name being mapped.
     */
    NSString *rootNode;
    
    /*!
     @discussion
        Contains all the primitive node mappings (that is, those that can be serialized with a  
        simple type mapper call).  The XMLNodeMapping instance is keyeed to the element of the XML
        to which it belongs.
     */
    NSMutableDictionary *primitiveNodeMappings;
    
    /*!
     @discussion
        Contains all the many-to-one reference node mappings.  In this case, we simply want to 
        recurse to another XMLMapping entirely and serialize it.  Since overloading the default root
        node is optional, we need to store these in an array.
     */
    NSMutableArray *referenceNodeMappings;
    
    /*!
     @discussion
        Contains all the many-to-many array node mappings.  Since arrays are by definition
        collections of objects, we can't very easily set a root node here -- since there could be
        different root nodes that get selected to go into any given array.  Because of that, we need
        to store them in an array structure.
     */
    NSMutableArray *arrayNodeMappings;
}

@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSString *rootNode;
@property (nonatomic, strong) NSMutableDictionary *primitiveNodeMappings;
@property (nonatomic, strong) NSMutableArray *referenceNodeMappings;
@property (nonatomic, strong) NSMutableArray *arrayNodeMappings;

/*!
 @discussion
    Creates a new XMLMapping instance initialized with the contents of the given file path.  The 
    given XML file is assumed to be in valid format.  The XMLMapping instance is configured to be
    for an Objective-C class of the given name.
 @param filePath
    A full path to the XML file to read.
 @param cName
    The name of the Objective-C class that should be associated with the mapping.
 @result
    The XMLMapping instance.
*/
- (id)initWithFile:(NSString *)filePath className:(NSString *)cName;

/*!
 @discussion
    Returns true if the given fully qualified file follows the conventions of the framework (if the
    name of the file starts with XML and ends with Map, like XMLUserMap.xml).  This method JUST does
    a name check, it performs no sanity check on the contents of the file.  Called by the bootstrap
    mechanism to automatically check if an XML file found in the application bundle is an XML
    mapping file.
 @param filePath
    The fully qualified path to check.
 @result
    YES if the file should be assumed to be a mapping file. 
 */
+ (BOOL)isMappingFile:(NSString *)filePath;

/*!
 @method
    standardClassNameForMappingFile:
 @discussion
    Parses out what should be the name of the Objective-C class that maps to the given mapping file.
    Convention dictates that for a mapping file XMLUserMap.xml, the name of the Objvective-C class
    will be User.  This method assumes that isMappingFile: has already been called for the given
    file path and has returned true.
 @result
    The full name of the class that should correspond to the given file.
 */
+ (NSString *)standardClassNameForMappingFile:(NSString *)filePath;

/*!
 @discussion
    Delegates to initWithFile:className:
 @param filePath
    A full path to the XML file to read.
 @param cName
    The name of the Objective-C class that should be associated with the mapping.
 @result
    The XMLMapping instance.
 */
+ (XMLMapping *)mappingWithFile:(NSString *)filePath className:(NSString *)cName;

@end
