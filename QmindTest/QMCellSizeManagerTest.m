/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Qkit/Qkit.h>
#import "QMBaseTestCase.h"
#import "QMCellSizeManager.h"
#import "QMTextLayoutManager.h"
#import "QMAppSettings.h"
#import "QMCell.h"
#import "QMMindmapView.h"
#import "QMRootCell.h"
#import "QMIcon.h"

@interface QMCellSizeManagerTest : QMBaseTestCase
@end

@implementation QMCellSizeManagerTest {
    QMCellSizeManager *manager;
    QMTextLayoutManager *textLayoutManager;
    QMAppSettings *settings;
    QMMindmapView *view;

    QMRootCell *rootCell;
    QMCell *cell;
    QMCell *childCell1;
    QMCell *childCell2;
    QMCell *leftChildCell1;
    QMCell *leftChildCell2;

    CGFloat maxWidth;
    CGFloat sizeOfIcon;
    CGFloat sizeOfLinkIcon;
    CGFloat horPadding;
    CGFloat vertPadding;
    CGFloat interIconDist;
    CGFloat linkIconMargin;
    CGFloat minHeight;
    CGFloat minWidth;
    CGFloat iconTextDist;
    CGFloat rootCellMaxWidth;

    CGFloat horCellDist;
    CGFloat vertCellDist;
}

- (void)setUp {
    [super setUp];

    manager = [[QMCellSizeManager alloc] init];
    textLayoutManager = mock([QMTextLayoutManager class]);
    settings = [[QMAppSettings alloc] init];

    view = mock([QMMindmapView class]);

    manager.textLayoutManager = textLayoutManager;
    manager.settings = settings;

    rootCell = [[QMRootCell alloc] initWithView:view];
    cell = [[QMCell alloc] initWithView:view];
    childCell1 = [[QMCell alloc] initWithView:view];
    childCell2 = [[QMCell alloc] initWithView:view];
    leftChildCell1 = [[QMCell alloc] initWithView:view];
    leftChildCell2 = [[QMCell alloc] initWithView:view];

    [self prepareCell:rootCell stringValue:@"root cell"];
    [self prepareCell:cell stringValue:@"Test Cell"];
    [self prepareCell:childCell1 stringValue:@"Child 1"];
    [self prepareCell:childCell2 stringValue:@"Child 2"];
    [self prepareCell:leftChildCell1 stringValue:@"Left Cell 1"];
    [self prepareCell:leftChildCell2 stringValue:@"Left Cell 2"];

    minHeight = [settings floatForKey:qSettingNodeMinHeight];
    minWidth = [settings floatForKey:qSettingNodeMinWidth];
    maxWidth = [settings floatForKey:qSettingMaxTextNodeWidth];
    rootCellMaxWidth = [settings floatForKey:qSettingMaxRootCellTextWidth];

    sizeOfIcon = [settings floatForKey:qSettingIconDrawSize];
    sizeOfLinkIcon = [settings floatForKey:qSettingLinkIconDrawSize];
    interIconDist = [settings floatForKey:qSettingInterIconDistance];
    linkIconMargin = [settings floatForKey:qSettingLinkIconHorizontalMargin];
    iconTextDist = [settings floatForKey:qSettingIconTextDistance];

    horPadding = [settings floatForKey:qSettingCellHorizontalPadding];
    vertPadding = [settings floatForKey:qSettingCellVerticalPadding];

    horCellDist = [settings floatForKey:qSettingInternodeHorizontalDistance];
    vertCellDist = [settings floatForKey:qSettingInternodeVerticalDistance];
}

- (void)testIconSize {
    QMIcon *icon1 = [[QMIcon alloc] initWithCode:@"1"];
    QMIcon *icon2 = [[QMIcon alloc] initWithCode:@"2"];
    QMIcon *icon3 = [[QMIcon alloc] initWithCode:@"3"];

    [cell addObjectInIcons:icon1];
    [cell addObjectInIcons:icon2];
    [cell addObjectInIcons:icon3];

    assertThatSize([manager sizeOfIconsOfCell:cell], equalToSize(NewSize(3 * sizeOfIcon + 2 * interIconDist, sizeOfIcon)));
}

- (void)testIconSizeNoIcons {
    assertThatSize([manager sizeOfIconsOfCell:cell], equalToSize(NewSize(0, 0)));
}

- (void)testTextSize {
    [given([textLayoutManager sizeOfAttributedString:cell.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(1, 2)];
    assertThatSize([manager sizeOfTextOfCell:cell], equalToSize(NewSize(1, 2)));
}

- (void)testTextRootCell {
    [given([textLayoutManager sizeOfAttributedString:rootCell.attributedString maxWidth:rootCellMaxWidth]) willReturnSize:NewSize(1, 2)];
    assertThatSize([manager sizeOfTextOfCell:rootCell], equalToSize(NewSize(1, 2)));
}

- (void)testChildrenFamilySize {
    [cell addObjectInChildren:childCell1];
    [cell addObjectInChildren:childCell2];

    [given([textLayoutManager sizeOfAttributedString:childCell1.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(100, 10)];
    [given([textLayoutManager sizeOfAttributedString:childCell2.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(10, 20)];

    assertThatSize([manager sizeOfChildrenFamily:cell.children], equalToSize(NewSize(childCell1.size.width, vertCellDist + childCell1.size.height + childCell2.size.height)));
}

- (void)testChildrenFamilySizeOfLeaf {
    assertThatSize([manager sizeOfChildrenFamily:@[]], equalToSize(NewSize(0, 0)));
}

#pragma mark See Meta/Cell Test Cases.graffle
- (void)testSize1 {
    [given([textLayoutManager sizeOfAttributedString:cell.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(10, 10)];
    assertThatSize([manager sizeOfCell:cell], equalToSize(NewSize(10 + 2 * horPadding, 10 + 2 * vertPadding)));
}

- (void)testSize2 {
    cell.stringValue = @"";
    [cell addObjectInIcons:@"1"];

    assertThatSize([manager sizeOfCell:cell], equalToSize(NewSize(sizeOfIcon + 2 * horPadding, sizeOfIcon + 2 * vertPadding)));
}

- (void)testSize3 {
    [given([textLayoutManager sizeOfAttributedString:cell.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(5, 5)];
    [cell addObjectInIcons:@"1"];
    [cell addObjectInIcons:@"2"];
    [cell addObjectInIcons:@"3"];
    [cell addObjectInIcons:@"4"];
    
    assertThatSize([manager sizeOfCell:cell], equalToSize(NewSize(4 * sizeOfIcon + 3 * interIconDist + iconTextDist + 2 * horPadding + 5, sizeOfIcon + 2 * vertPadding)));
}

- (void)testSize4 {
    [given([textLayoutManager sizeOfAttributedString:cell.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(5, 50)];
    [cell addObjectInIcons:@"1"];
    [cell addObjectInIcons:@"2"];
    [cell addObjectInIcons:@"3"];
    [cell addObjectInIcons:@"4"];

    assertThatSize([manager sizeOfCell:cell], equalToSize(NewSize(4 * sizeOfIcon + 3 * interIconDist + iconTextDist + 2 * horPadding + 5, 50 + 2 * vertPadding)));
}

- (void)testSize5 {
    cell.size;
    // all the job is done by text layout manager
    [verify(textLayoutManager) sizeOfAttributedString:cell.attributedString maxWidth:maxWidth];
}

- (void)testSize6 {
    [rootCell addObjectInIcons:@"1"];
    [rootCell addObjectInIcons:@"2"];
    [rootCell addObjectInIcons:@"3"];

    [given([textLayoutManager sizeOfAttributedString:rootCell.attributedString maxWidth:rootCellMaxWidth]) willReturnSize:NewSize(10, 10)];
    assertThatSize([manager sizeOfCell:rootCell], biggerThanSize(NewSize(3 * sizeOfIcon + 2 * interIconDist + iconTextDist + 2 * horPadding + 10, sizeOfIcon + 2 * vertPadding)));
}

- (void)testSize7 {
    [rootCell addObjectInIcons:@"1"];
    [rootCell addObjectInIcons:@"2"];
    [rootCell addObjectInIcons:@"3"];

    rootCell.size;
    // all the job is done by text layout manager
    [verify(textLayoutManager) sizeOfAttributedString:rootCell.attributedString maxWidth:rootCellMaxWidth];
}

- (void)testSize8 {
    [given([textLayoutManager sizeOfAttributedString:cell.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(5, 50)];

    [cell addObjectInIcons:@"1"];
    [cell addObjectInIcons:@"2"];
    [cell addObjectInIcons:@"3"];
    [cell addObjectInIcons:@"4"];

    cell.link = [NSURL URLWithString:@"http://qvacua.com"];

    assertThatSize([manager sizeOfCell:cell], equalToSize(NewSize(1 * sizeOfLinkIcon + 1 * linkIconMargin + 4 * sizeOfIcon + 3 * interIconDist + iconTextDist + 2 * horPadding + 5, MAX(sizeOfIcon, sizeOfLinkIcon) + 2 * vertPadding)));
}

- (void)testSize9 {
    [given([textLayoutManager sizeOfAttributedString:cell.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(5, 5)];

    cell.link = [NSURL URLWithString:@"http://qvacua.com"];

    assertThatSize([manager sizeOfCell:cell], equalToSize(NewSize(1 * sizeOfLinkIcon + 1 * linkIconMargin + 2 * horPadding + 5, sizeOfLinkIcon + 2 * vertPadding)));
}

- (void)testFamilySize1 {
    [cell addObjectInChildren:childCell1];
    [cell addObjectInChildren:childCell2];

    [given([textLayoutManager sizeOfAttributedString:cell.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(10, 100)];
    [given([textLayoutManager sizeOfAttributedString:childCell1.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(100, 10)];
    [given([textLayoutManager sizeOfAttributedString:childCell2.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(10, 10)];

    assertThatSize([manager sizeOfFamilyOfCell:cell], equalToSize(NewSize(horCellDist + cell.size.width + childCell1.size.width, cell.size.height)));
}

- (void)testFamilySize2 {
    [cell addObjectInChildren:childCell1];
    [cell addObjectInChildren:childCell2];

    [given([textLayoutManager sizeOfAttributedString:cell.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(10, 10)];
    [given([textLayoutManager sizeOfAttributedString:childCell1.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(10, 10)];
    [given([textLayoutManager sizeOfAttributedString:childCell2.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(100, 100)];

    assertThatSize([manager sizeOfFamilyOfCell:cell], equalToSize(NewSize(horCellDist + cell.size.width + childCell2.size.width, vertCellDist + childCell1.size.height + childCell2.size.height)));
}

- (void)testFamilySize3 {
    [given([textLayoutManager sizeOfAttributedString:cell.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(10, 10)];
    assertThatSize([manager sizeOfFamilyOfCell:cell], equalToSize([manager sizeOfCell:cell]));
}

- (void)testFamilySize3Root {
    [given([textLayoutManager sizeOfAttributedString:rootCell.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(10, 10)];
    assertThatSize([manager sizeOfFamilyOfCell:rootCell], equalToSize([manager sizeOfCell:rootCell]));
}

- (void)testFamilySize4 {
    [rootCell addObjectInChildren:childCell1];
    [rootCell addObjectInChildren:childCell2];

    [rootCell addObjectInLeftChildren:leftChildCell1];
    [rootCell addObjectInLeftChildren:leftChildCell2];

    [given([textLayoutManager sizeOfAttributedString:rootCell.attributedString maxWidth:rootCellMaxWidth]) willReturnSize:NewSize(10, 10)];

    [given([textLayoutManager sizeOfAttributedString:childCell1.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(10, 10)];
    [given([textLayoutManager sizeOfAttributedString:childCell2.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(100, 100)];

    [given([textLayoutManager sizeOfAttributedString:leftChildCell1.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(10, 10)];
    [given([textLayoutManager sizeOfAttributedString:leftChildCell2.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(100, 10)];

    assertThatSize([manager sizeOfFamilyOfCell:rootCell], equalToSize(NewSize(2 * horCellDist + rootCell.size.width + childCell2.size.width + leftChildCell2.size.width, vertCellDist + childCell1.size.height + childCell2.size.height)));
}

- (void)testFamilySize5 {
    [rootCell addObjectInChildren:childCell1];
    [rootCell addObjectInChildren:childCell2];

    [rootCell addObjectInLeftChildren:leftChildCell1];
    [rootCell addObjectInLeftChildren:leftChildCell2];

    [given([textLayoutManager sizeOfAttributedString:rootCell.attributedString maxWidth:rootCellMaxWidth]) willReturnSize:NewSize(10, 10)];

    [given([textLayoutManager sizeOfAttributedString:childCell1.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(10, 10)];
    [given([textLayoutManager sizeOfAttributedString:childCell2.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(100, 10)];

    [given([textLayoutManager sizeOfAttributedString:leftChildCell1.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(10, 200)];
    [given([textLayoutManager sizeOfAttributedString:leftChildCell2.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(100, 10)];

    assertThatSize([manager sizeOfFamilyOfCell:rootCell], equalToSize(NewSize(2 * horCellDist + rootCell.size.width + childCell2.size.width + leftChildCell2.size.width, vertCellDist + leftChildCell1.size.height + leftChildCell2.size.height)));
}

- (void)testFamilySize6 {
    [rootCell addObjectInChildren:childCell1];
    [rootCell addObjectInChildren:childCell2];

    [rootCell addObjectInLeftChildren:leftChildCell1];
    [rootCell addObjectInLeftChildren:leftChildCell2];

    [given([textLayoutManager sizeOfAttributedString:rootCell.attributedString maxWidth:rootCellMaxWidth]) willReturnSize:NewSize(10, 300)];

    [given([textLayoutManager sizeOfAttributedString:childCell1.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(10, 10)];
    [given([textLayoutManager sizeOfAttributedString:childCell2.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(100, 10)];

    [given([textLayoutManager sizeOfAttributedString:leftChildCell1.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(10, 10)];
    [given([textLayoutManager sizeOfAttributedString:leftChildCell2.attributedString maxWidth:maxWidth]) willReturnSize:NewSize(100, 10)];

    assertThatSize([manager sizeOfFamilyOfCell:rootCell], equalToSize(NewSize(2 * horCellDist + rootCell.size.width + childCell2.size.width + leftChildCell2.size.width, rootCell.size.height)));
}

#pragma mark Private
- (void)prepareCell:(QMCell *)aCell stringValue:(NSString *)stringValue {
    aCell.stringValue = stringValue;
    aCell.cellSizeManager = manager;
    aCell.textLayoutManager = textLayoutManager;
}

@end
