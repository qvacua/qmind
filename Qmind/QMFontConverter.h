/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>

/**
* Converts the attributes of <font> element to NSFont and vice versa. If we have the default font at hand,
* we do nothing.
*/
@interface QMFontConverter : NSObject

/**
* Returns an NSFont out of FreeMind font attributes in form of a dictionary.
*/
- (NSFont *)fontFromFontAttrDict:(NSDictionary *)fontAttrDict;

/**
* Returns FreeMind font attributes in form of a dictionary out of an NSFont
*/
- (NSDictionary *)fontAttrDictFromFont:(NSFont *)font;

+ (QMFontConverter *)sharedConverter;

@end
