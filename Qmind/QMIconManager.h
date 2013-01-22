/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>
#import "QMTypes.h"

@interface QMIconManager : NSObject

/**
* Array of all supported icon codes. The array is sorted ascending and case sensitive.
*/
@property (readonly) NSArray *iconCodes;

- (id)iconRepresentationForCode:(NSString *)iconCode;
- (QMIconKind)kindForCode:(NSString *)iconCode;

@end
