/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Foundation/Foundation.h>

@class QMRootNode;
@class QMFontManager;
@protocol TBBean;

/**
* Converts the internal node structure to NSData such that you can write it down. The result will be a mm file.
*/
@interface QMMindmapWriter : NSObject <TBBean>

@property (weak) QMFontManager *fontConverter;

/**
* Returns the whole mindmap as NSData such that we can save it to the disk.
*/
- (NSData *)dataForRootNode:(QMRootNode *)rootNode;

@end
