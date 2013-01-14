/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import "QMIconsPaneView.h"
#import "QMIconCollectionViewItem.h"
#import "QMMindmapView.h"

@implementation QMIconsPaneView {
    __weak QMMindmapView *_mindmapView;
}

@synthesize mindmapView = _mindmapView;

- (NSCollectionViewItem *)newItemForRepresentedObject:(id)object {
    NSCollectionViewItem *collectionViewItem = [super newItemForRepresentedObject:object];
    QMIconCollectionViewItem *iconCollectionViewItem = (QMIconCollectionViewItem *)collectionViewItem;

    iconCollectionViewItem.mindmapView = _mindmapView;

    return collectionViewItem;
}

@end
