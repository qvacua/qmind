/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <TBCacao/TBCacao.h>
#import "QMIdGenerator.h"


@implementation QMIdGenerator

#pragma mark Public
- (NSString *)nodeId {
  return [@"ID_" stringByAppendingString:self.uuid];
}

#pragma mark Private
- (NSString *)uuid {
  CFUUIDRef cfUuid = CFUUIDCreate(NULL);

  CFStringRef cfUuidStr = CFUUIDCreateString(NULL, cfUuid);
  CFRelease(cfUuid);

  NSString *result = (__bridge_transfer NSString *) cfUuidStr;
  return result;
}

@end
