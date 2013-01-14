/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import <Qkit/Qkit.h>
#import "QMBaseTestCase.h"
#import "QMIconGridView.h"
#import "QMMindmapView.h"
#import "QMIconCollectionViewItem.h"
#import "QMMindmapViewDataSource.h"
#import "QMMindmapViewDataSourceImpl.h"
#import "QMIcon.h"
#import "QMCell.h"

@interface IconCollectionViewItemTest : QMBaseTestCase
@end

@implementation IconCollectionViewItemTest {
    QMIconCollectionViewItem *viewItem;

    QMMindmapView *mindmapView;
    id<QMMindmapViewDataSource> dataSource;
    QMCell *cell1;
    QMCell *cell2;
    QMIcon *icon;
}

- (void)setUp {
    [super setUp];

    mindmapView = mock([QMMindmapView class]);
    dataSource = mockProtocol(@protocol(QMMindmapViewDataSource));
    [given([mindmapView dataSource]) willReturn:dataSource];

    viewItem = [[QMIconCollectionViewItem alloc] init];
    viewItem.mindmapView = mindmapView;

    cell1 = [[QMCell alloc] initWithView:mindmapView];
    cell1.identifier = [[NSObject alloc] init];
    cell2 = [[QMCell alloc] initWithView:mindmapView];
    cell2.identifier = [[NSObject alloc] init];

    icon = [[QMIcon alloc] initWithCode:@"icon1"];
}

- (void)testCanSetIcon {
    [given([mindmapView hasSelectedCells]) willReturnBool:YES];
    assertThat(@([viewItem canSetIcon]), isYes);

    [given([mindmapView hasSelectedCells]) willReturnBool:NO];
    assertThat(@([viewItem canSetIcon]), isNo);
}

- (void)testSetIcon {
    [given([mindmapView hasSelectedCells]) willReturnBool:YES];
    [given([mindmapView selectedCells]) willReturn:@[cell1, cell2]];

    viewItem.representedObject = icon;
    [viewItem setIcon];

    [verify(mindmapView) endEditing];
    [verify(dataSource) mindmapView:mindmapView addIcon:icon toItem:cell1.identifier];
    [verify(dataSource) mindmapView:mindmapView addIcon:icon toItem:cell2.identifier];
}

- (void)testSetIconNoSelectedCells {
    [given([mindmapView hasSelectedCells]) willReturnBool:NO];
    [given([mindmapView selectedCells]) willReturn:@[]];

    viewItem.representedObject = icon;
    [viewItem setIcon];

    [verifyCount(dataSource, never()) mindmapView:mindmapView addIcon:icon toItem:anything()];
}

@end
