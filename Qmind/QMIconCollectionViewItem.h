/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>

@class QMMindmapView;

@interface QMIconCollectionViewItem : NSCollectionViewItem

@property (weak) QMMindmapView *mindmapView;

- (BOOL)canSetIcon;
- (void)setIcon;

@end
