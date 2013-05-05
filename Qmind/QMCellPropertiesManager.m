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

@interface QMCellPropertiesManager ()

@property id <QMMindmapViewDataSource> dataSource;

@end

@implementation QMCellPropertiesManager

#pragma mark Public
- (id)initWithDataSource:(id <QMMindmapViewDataSource>)dataSource {
    self = [super init];
    if (self) {
        _dataSource = dataSource;
    }

    return self;
}

- (QMCell *)cellWithParent:(QMCell *)parentCell itemOfParent:(id)itemOfParent {
    QMCell *cell;

    if (itemOfParent == nil) {
        QMRootCell *rootCell = [[QMRootCell alloc] initWithView:nil];
        cell = rootCell;
    } else {
        cell = [[QMCell alloc] initWithView:nil];

        if (parentCell.isRoot) {
            BOOL isItemLeft = [_dataSource mindmapView:nil isItemLeft:itemOfParent];
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
    cell.identifier = [_dataSource mindmapView:nil identifierForItem:givenItem];
    cell.stringValue = [_dataSource mindmapView:nil stringValueOfItem:givenItem];
    cell.font = [_dataSource mindmapView:nil fontOfItem:givenItem];
    cell.folded = [_dataSource mindmapView:nil isItemFolded:givenItem];

    [self fillIconsOfCell:cell];
}

- (void)fillIconsOfCell:(QMCell *)cell {
    NSArray *iconsOfItem = [_dataSource mindmapView:nil iconsOfItem:cell.identifier];
    for (id icon in iconsOfItem) {
        [cell insertObject:icon inIconsAtIndex:cell.icons.count];
    }
}

- (void)fillAllChildrenWithIdentifier:(id)givenItem cell:(QMCell *)cell {
    NSInteger childrenCount = [_dataSource mindmapView:nil numberOfChildrenOfItem:givenItem];
    for (NSUInteger i = 0; i < childrenCount; i++) {
        id childItem = [_dataSource mindmapView:nil child:i ofItem:givenItem];
        [self cellWithParent:cell itemOfParent:childItem];
    }

    if (!cell.root) {
        return;
    }

    NSInteger leftChildrenCount = [_dataSource mindmapView:nil numberOfLeftChildrenOfItem:givenItem];
    for (NSUInteger i = 0; i < leftChildrenCount; i++) {
        id childItem = [_dataSource mindmapView:nil leftChild:i ofItem:givenItem];
        [self cellWithParent:cell itemOfParent:childItem];
    }
}

@end
