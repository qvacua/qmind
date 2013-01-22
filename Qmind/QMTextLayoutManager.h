/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>

@class QMAppSettings;

@interface QMTextLayoutManager : NSObject

@property (weak) QMAppSettings *settings;

- (CGFloat)widthOfString:(NSString *)string;
- (CGFloat)widthOfString:(NSString *)string usingFont:(NSFont *)font;
- (NSSize)sizeOfString:(NSString *)string maxWidth:(CGFloat)maxWidth;
- (NSSize)sizeOfString:(NSString *)string maxWidth:(CGFloat)maxWidth usingFont:(NSFont *)font;
- (NSSize)sizeOfAttributedString:(NSAttributedString *)attrStr maxWidth:(CGFloat)maxWidth;
- (NSSize)sizeOfAttributedString:(NSAttributedString *)attrStr;
- (NSRange)completeRangeOfAttributedString:(NSAttributedString *)attrStr;

/**
* Returns an NSDictionary which is suitable as attributes dictionary for creating an NSAttributedString. The attributes
* are
*   - default paragraph style + NSLeftTextAlignment + NSLineBreakByWordWrapping + given NSFont
*/
- (NSDictionary *)stringAttributesDictWithFont:(NSFont *)font;

/**
* Returns an NSDictionary which is suitable as attributes dictionary for creating an NSAttributedString. The attributes
* are
*   - default paragraph style + NSLeftTextAlignment + NSLineBreakByWordWrapping
 *                            + default NSFont specified in QMAppSettings
*/
- (NSDictionary *)stringAttributesDict;

@end
