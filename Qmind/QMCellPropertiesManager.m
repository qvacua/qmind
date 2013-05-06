/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMCellPropertiesManager.h"
#import "QMCell.h"
#import "QMMindmapViewDataSource.h"
#import "QMRootCell.h"
#import "QMMindmapView.h"

@interface QMCellPropertiesManager ()

@property id <QMMindmapViewDataSource> dataSource;
@property QMMindmapView *view;

@end

@implementation QMCellPropertiesManager

#pragma mark Public
- (id)initWithMindmapView:(QMMindmapView *)view {
    self = [super init];
    if (self) {
        _view = view;
        _dataSource = _view.dataSource;
    }

    return self;
}

- (id)initWithDataSource:(id <QMMindmapViewDataSource>)dataSource {
    self = [super init];
    if (self) {
        _view = nil;
        _dataSource = dataSource;
    }

    return self;
}

- (QMCell *)cellWithParent:(QMCell *)parentCell itemOfParent:(id)itemOfParent {
    QMCell *cell;

    if (itemOfParent == nil) {
        QMRootCell *rootCell = [[QMRootCell alloc] initWithView:self.view];
        cell = rootCell;
    } else {
        cell = [[QMCell alloc] initWithView:self.view];

        if (parentCell.isRoot) {
            BOOL isItemLeft = [_dataSource mindmapView:self.view isItemLeft:itemOfParent];
            if (isItemLeft) {
                [(QMRootCell *) parentCell addObjectInLeftChildren:cell];
            } else {
                [parentCell addObjectInChildren:cell];
            }
        } else {
            [parentCell addObjectInChildren:cell];
        }
    }

    [self fillCellPropertiesWithIdentifier:itemOfParent cell:cell];
    [self fillAllChildrenWithIdentifier:itemOfParent cell:cell];

    return cell;
}

- (void)fillCellPropertiesWithIdentifier:(id)givenItem cell:(QMCell *)cell {
    cell.identifier = [_dataSource mindmapView:self.view identifierForItem:givenItem];
    cell.stringValue = [_dataSource mindmapView:self.view stringValueOfItem:givenItem];
    cell.font = [_dataSource mindmapView:self.view fontOfItem:givenItem];
    cell.folded = [_dataSource mindmapView:self.view isItemFolded:givenItem];

    [self fillIconsOfCell:cell];
}

- (void)fillIconsOfCell:(QMCell *)cell {
    NSArray *iconsOfItem = [_dataSource mindmapView:self.view iconsOfItem:cell.identifier];
    for (id icon in iconsOfItem) {
        [cell insertObject:icon inIconsAtIndex:cell.icons.count];
    }
}

- (void)fillAllChildrenWithIdentifier:(id)givenItem cell:(QMCell *)cell {
    NSInteger childrenCount = [_dataSource mindmapView:self.view numberOfChildrenOfItem:givenItem];
    for (NSUInteger i = 0; i < childrenCount; i++) {
        id childItem = [_dataSource mindmapView:self.view child:i ofItem:givenItem];
        [self cellWithParent:cell itemOfParent:childItem];
    }

    if (!cell.root) {
        return;
    }

    NSInteger leftChildrenCount = [_dataSource mindmapView:self.view numberOfLeftChildrenOfItem:givenItem];
    for (NSUInteger i = 0; i < leftChildrenCount; i++) {
        id childItem = [_dataSource mindmapView:self.view leftChild:i ofItem:givenItem];
        [self cellWithParent:cell itemOfParent:childItem];
    }
}

@end
