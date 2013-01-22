/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMIconCollectionViewItem.h"
#import "QMMindmapView.h"
#import "QMMindmapViewDataSource.h"
#import "QMCell.h"

@implementation QMIconCollectionViewItem {
    __weak QMMindmapView *_mindmapView;
}

@synthesize mindmapView = _mindmapView;

- (BOOL)canSetIcon {
    return [_mindmapView hasSelectedCells];
}

- (void)setIcon {
    [_mindmapView endEditing];

    id <QMMindmapViewDataSource> dataSource = _mindmapView.dataSource;
    NSArray *selCells = _mindmapView.selectedCells;

    for (QMCell *cell in selCells) {
        [dataSource mindmapView:_mindmapView addIcon:self.representedObject toItem:cell.identifier];
    }
}

@end
