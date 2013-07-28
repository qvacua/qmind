/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Foundation/Foundation.h>

@class QMCell;
@class QMTextLayoutManager;
@class QMAppSettings;
@protocol TBBean;

@interface QMCellSizeManager : NSObject <TBBean>

@property (weak) QMTextLayoutManager *textLayoutManager;
@property (weak) QMAppSettings *settings;

/**
* Returns the complete size of the cell, ie including icons, text, margins etc..
*/
- (NSSize)sizeOfCell:(QMCell *)cell;

/**
* Returns the size of icons without margins around them.
*/
- (NSSize)sizeOfIconsOfCell:(QMCell *)cell;

/**
* Returns the size of text content of the cell without margins around them.
*/
- (NSSize)sizeOfTextOfCell:(QMCell *)cell;

- (NSSize)sizeOfChildrenFamily:(NSArray *)children;

- (NSSize)sizeOfFamilyOfCell:(QMCell *)cell;

@end
