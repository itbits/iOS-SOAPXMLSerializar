/*Created by Muhammad Imran on 4/6/14. */

#import "XMLTypeMapper.h"
#import "XMLContext.h"

@implementation XMLStringTypeMapper

- (BOOL)isValid:(NSString *)xml typeConfiguration:(NSDictionary *)typeConfiguration {
    return YES;
}
- (NSString *)toXML:(id)value typeConfiguration:(NSDictionary *)typeConfiguration {
    return (NSString *)value;
}
- (id)toValue:(NSString *)xml typeConfiguration:(NSDictionary *)typeConfiguration {
    return [xml stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end

@implementation XMLNumberTypeMapper

- (BOOL)isValid:(NSString *)xml typeConfiguration:(NSDictionary *)typeConfiguration {
    if (xml != nil && [xml length] > 0) {
        return ([[NSScanner scannerWithString:xml] scanDouble:NULL] == YES);
    } else {
        return (YES);
    }
}
- (NSString *)toXML:(id)value typeConfiguration:(NSDictionary *)typeConfiguration {
    return [(NSNumber *)value stringValue];
}
- (id)toValue:(NSString *)xml typeConfiguration:(NSDictionary *)typeConfiguration {
    return [NSNumber numberWithDouble:[xml doubleValue]];
}

@end

@implementation XML1970DateTypeMapper

- (BOOL)isValid:(NSString *)xml typeConfiguration:(NSDictionary *)typeConfiguration {
    if (xml != nil && [xml length] > 0) {
        return ([[NSScanner scannerWithString:xml] scanDouble:NULL] == YES);
    } else {
        return (YES);
    }
}
- (NSString *)toXML:(id)value typeConfiguration:(NSDictionary *)typeConfiguration {
    return ([[NSNumber numberWithDouble:([(NSDate *)value timeIntervalSince1970] * 1000)] stringValue]);
}
- (id)toValue:(NSString *)xml typeConfiguration:(NSDictionary *)typeConfiguration {
    return ([NSDate dateWithTimeIntervalSince1970:([xml doubleValue]/1000)]);
}

@end

@implementation XMLIntTypeMapper

- (BOOL)isValid:(NSString *)xml typeConfiguration:(NSDictionary *)typeConfiguration {
    if (xml != nil && [xml length] > 0) {
        return ([[NSScanner scannerWithString:xml] scanInt:NULL] == YES);
    } else {
        return (YES);
    }
}
- (NSString *)toXML:(id)value typeConfiguration:(NSDictionary *)typeConfiguration {
    return ([value stringValue]);
}
- (id)toValue:(NSString *)xml typeConfiguration:(NSDictionary *)typeConfiguration {
    return ([NSNumber numberWithInt:[xml intValue]]);
}

@end

@implementation XMLBooleanTypeMapper

- (BOOL)isValid:(NSString *)xml typeConfiguration:(NSDictionary *)typeConfiguration {
    return xml != nil && ([xml isEqual:@"T"] || [xml isEqual:@"F"]);
}
- (NSString *)toXML:(id)value typeConfiguration:(NSDictionary *)typeConfiguration {
    return [value intValue] == YES ? @"T" : @"F";
}
- (id)toValue:(NSString *)xml typeConfiguration:(NSDictionary *)typeConfiguration {
    return [xml isEqual:@"T"] ? [NSNumber numberWithInt:YES] : [NSNumber numberWithInt:NO];
}

@end

@implementation XMLLongBooleanTypeMapper

- (BOOL)isValid:(NSString *)xml typeConfiguration:(NSDictionary *)typeConfiguration {
    return xml != nil && ([xml isEqual:@"true"] || [xml isEqual:@"false"]);
}
- (NSString *)toXML:(id)value typeConfiguration:(NSDictionary *)typeConfiguration {
    return [value intValue] == YES ? @"true" : @"false";
}
- (id)toValue:(NSString *)xml typeConfiguration:(NSDictionary *)typeConfiguration {
    return [xml isEqual:@"true"] ? [NSNumber numberWithInt:YES] : [NSNumber numberWithInt:NO];
}

@end

