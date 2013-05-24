/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <TBCacao/TBCacao.h>
#import "QMNodeIdGenerator.h"

@implementation QMNodeIdGenerator

TB_BEAN

#pragma mark Public
- (NSString *)nodeId {
    return [self uuid];
}

#pragma mark Private
- (NSString *)uuid {
    CFUUIDRef cfUuid = CFUUIDCreate(NULL);

    CFStringRef cfUuidStr = CFUUIDCreateString(NULL, cfUuid);
    CFRelease(cfUuid);

    NSString *result = [NSString stringWithString:(__bridge NSString *) cfUuidStr];
    CFRelease(cfUuidStr);

    return result;
}

@end
