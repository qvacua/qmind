/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>

@class QMAppSettings;
@protocol TBInitializingBean;

/**
* Converts the attributes of <font> element to NSFont and vice versa. If we have the default font at hand,
* we do nothing.
*/
@interface QMFontConverter : NSObject <TBInitializingBean>

@property (weak) QMAppSettings *settings;
@property (unsafe_unretained) NSFontManager *fontManager;

/**
* Returns an NSFont out of FreeMind font attributes in form of a dictionary.
*/
- (NSFont *)fontFromFontAttrDict:(NSDictionary *)fontAttrDict;

/**
* Returns FreeMind font attributes in form of a dictionary out of an NSFont
*/
- (NSDictionary *)fontAttrDictFromFont:(NSFont *)font;

@end
