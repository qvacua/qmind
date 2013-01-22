/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMMindmapView.h"
#import "QMBaseTestCase.h"
#import "QMAppSettings.h"
#import <Qkit/Qkit.h>
#import "QMCellLayoutManager.h"
#import "QMRootCell.h"
#import "QMCellSizeManager.h"
#import "QMTextLayoutManager.h"
#import "QMIcon.h"

@interface CellLayoutManagerTest : QMBaseTestCase @end

@implementation CellLayoutManagerTest {
    QMCellLayoutManager *manager;
    QMCellSizeManager *cellSizeManager;
    QMTextLayoutManager *textLayoutManager;
    QMMindmapView *view;
    QMAppSettings *settings;

    QMRootCell *rootCell;
    QMCell *cell;
    QMCell *childCell1, *childCell2;
    QMCell *leftChildCell2, *leftChildCell1;
    QMCell *grandChild;

    CGFloat horDist, vertDist;
    CGFloat horPadding, vertPadding;
    CGFloat iconDrawSize;
    CGFloat interIconDist;
    CGFloat iconTextDist;
    QMIcon *icon1;
    QMIcon *icon2;
    QMIcon *icon3;
}

- (void)setUp {
    [super setUp];

    manager = [[QMCellLayoutManager alloc] init];
    cellSizeManager = mock(QMCellSizeManager.class);
    textLayoutManager = mock([QMTextLayoutManager class]);
    view = mock([QMMindmapView class]);
    settings = [[QMAppSettings alloc] init];
    manager.settings = settings;

    horDist = [settings floatForKey:qSettingInternodeHorizontalDistance];
    vertDist = [settings floatForKey:qSettingInternodeVerticalDistance];
    horPadding = [settings floatForKey:qSettingCellHorizontalPadding];
    vertPadding = [settings floatForKey:qSettingCellVerticalPadding];
    iconDrawSize = [settings floatForKey:qSettingIconDrawSize];
    interIconDist = [settings floatForKey:qSettingInterIconDistance];
    iconTextDist = [settings floatForKey:qSettingIconTextDistance];

    rootCell = [[QMRootCell alloc] initWithView:view];
    cell = [[QMCell alloc] initWithView:view];
    childCell1 = [[QMCell alloc] initWithView:view];
    childCell2 = [[QMCell alloc] initWithView:view];
    leftChildCell1 = [[QMCell alloc] initWithView:view];
    leftChildCell2 = [[QMCell alloc] initWithView:view];
    grandChild = [[QMCell alloc] initWithView:view];

    [self wireCell:rootCell stringValue:@"RootCell"];
    [self wireCell:cell stringValue:@"Cell"];
    [self wireCell:childCell1 stringValue:@"ChildCell1"];
    [self wireCell:childCell2 stringValue:@"ChildCell2"];
    [self wireCell:leftChildCell1 stringValue:@"LeftChildCell1"];
    [self wireCell:leftChildCell2 stringValue:@"LeftChildCell2"];
    [self wireCell:grandChild stringValue:@"GrandChild"];

    icon1 = [[QMIcon alloc] initWithCode:@"1"];
    icon2 = [[QMIcon alloc] initWithCode:@"2"];
    icon3 = [[QMIcon alloc] initWithCode:@"3"];
    icon1.settings = settings;
    icon2.settings = settings;
    icon3.settings = settings;
    icon1.size = NewSize(iconDrawSize, iconDrawSize);
    icon2.size = NewSize(iconDrawSize, iconDrawSize);
    icon3.size = NewSize(iconDrawSize, iconDrawSize);
}

- (void)testRegionRightNode {
    cell.origin = NewPoint(100, 100);
    cell.left = NO;
    [given([cellSizeManager sizeOfCell:cell]) willReturnSize:NewSize(100, 100)];

    assertThat(@([manager regionOfCell:cell atPoint:NewPoint(110, 110)]), is(@(QMCellRegionNorth)));
    assertThat(@([manager regionOfCell:cell atPoint:NewPoint(110, 190)]), is(@(QMCellRegionSouth)));
    assertThat(@([manager regionOfCell:cell atPoint:NewPoint(175, 130)]), is(@(QMCellRegionEast)));
    assertThat(@([manager regionOfCell:cell atPoint:NewPoint(175, 190)]), is(@(QMCellRegionEast)));
}

- (void)testRegionLeftNode {
    cell.origin = NewPoint(100, 100);
    cell.left = YES;
    [given([cellSizeManager sizeOfCell:cell]) willReturnSize:NewSize(100, 100)];

    assertThat(@([manager regionOfCell:cell atPoint:NewPoint(110, 110)]), is(@(QMCellRegionWest)));
    assertThat(@([manager regionOfCell:cell atPoint:NewPoint(110, 190)]), is(@(QMCellRegionWest)));
    assertThat(@([manager regionOfCell:cell atPoint:NewPoint(175, 130)]), is(@(QMCellRegionNorth)));
    assertThat(@([manager regionOfCell:cell atPoint:NewPoint(175, 190)]), is(@(QMCellRegionSouth)));
}

- (void)testRegionRootCell {
    rootCell.origin = NewPoint(100, 100);
    [given([cellSizeManager sizeOfCell:rootCell]) willReturnSize:NewSize(100, 100)];

    assertThat(@([manager regionOfCell:rootCell atPoint:NewPoint(110, 110)]), is(@(QMCellRegionWest)));
    assertThat(@([manager regionOfCell:rootCell atPoint:NewPoint(110, 190)]), is(@(QMCellRegionWest)));
    assertThat(@([manager regionOfCell:rootCell atPoint:NewPoint(175, 130)]), is(@(QMCellRegionEast)));
    assertThat(@([manager regionOfCell:rootCell atPoint:NewPoint(175, 190)]), is(@(QMCellRegionEast)));
}

- (void)testRegionFrameRightNode {
    cell.origin = NewPoint(100, 100);
    cell.left = NO;
    [given([cellSizeManager sizeOfCell:cell]) willReturnSize:NewSize(100, 100)];

    assertThatRect([manager regionFrameOfCell:cell ofRegion:QMCellRegionNorth], equalToRect(NewRect(100, 100, 50, 50)));
    assertThatRect([manager regionFrameOfCell:cell ofRegion:QMCellRegionSouth], equalToRect(NewRect(100, 150, 50, 50)));
    assertThatRect([manager regionFrameOfCell:cell ofRegion:QMCellRegionEast], equalToRect(NewRect(150, 100, 50, 100)));
    assertThatRect([manager regionFrameOfCell:cell ofRegion:QMCellRegionWest], equalToRect(NSZeroRect));
}

- (void)testRegionFrameLeftNode {
    cell.origin = NewPoint(100, 100);
    cell.left = YES;
    [given([cellSizeManager sizeOfCell:cell]) willReturnSize:NewSize(100, 100)];

    assertThatRect([manager regionFrameOfCell:cell ofRegion:QMCellRegionNorth], equalToRect(NewRect(150, 100, 50, 50)));
    assertThatRect([manager regionFrameOfCell:cell ofRegion:QMCellRegionSouth], equalToRect(NewRect(150, 150, 50, 50)));
    assertThatRect([manager regionFrameOfCell:cell ofRegion:QMCellRegionEast], equalToRect(NSZeroRect));
    assertThatRect([manager regionFrameOfCell:cell ofRegion:QMCellRegionWest], equalToRect(NewRect(100, 100, 50, 100)));
}

- (void)testRegionFrameRootCell {
    rootCell.origin = NewPoint(100, 100);
    [given([cellSizeManager sizeOfCell:rootCell]) willReturnSize:NewSize(100, 100)];

    assertThatRect([manager regionFrameOfCell:rootCell ofRegion:QMCellRegionWest], equalToRect(NewRect(100, 100, 50, 100)));
    assertThatRect([manager regionFrameOfCell:rootCell ofRegion:QMCellRegionEast], equalToRect(NewRect(150, 100, 50, 100)));
    assertThatRect([manager regionFrameOfCell:rootCell ofRegion:QMCellRegionNorth], equalToRect(NSZeroRect));
    assertThatRect([manager regionFrameOfCell:rootCell ofRegion:QMCellRegionSouth], equalToRect(NSZeroRect));
}

- (void)testComputeGeometryLinesAreThere {
    [manager computeGeometryAndLinesOfCell:cell];

    // check whether lines are there
    assertThat(cell.line, notNilValue());
}

- (void)testComputeTextOriginWoIcons {
    [given([cellSizeManager sizeOfTextOfCell:cell]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfIconsOfCell:cell]) willReturnSize:NewSize(0, 0)];
    [given([cellSizeManager sizeOfCell:cell]) willReturnSize:NewSize(10 + 2 * horPadding, 10 + 2 * vertPadding)];
    cell.familyOrigin = NewPoint(10, 10);

    [manager computeGeometryAndLinesOfCell:cell];

    assertThatPoint(cell.textOrigin, equalToPoint(NewPoint(10 + horPadding, 10 + vertPadding)));
}

- (void)testComputeTextOriginWithIcons {
    NSSize iconSize = NewSize(3 * iconDrawSize + 2 * interIconDist, iconDrawSize);
    NSSize cellSize = NewSize(10 + 2 * horPadding + iconSize.width + iconTextDist, iconSize.height + 2 * vertPadding);

    [cell addObjectInIcons:icon1];
    [cell addObjectInIcons:icon2];
    [cell addObjectInIcons:icon3];
    
    [given([cellSizeManager sizeOfTextOfCell:cell]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfIconsOfCell:cell]) willReturnSize:iconSize];
    [given([cellSizeManager sizeOfCell:cell]) willReturnSize:cellSize];

    cell.familyOrigin = NewPoint(10, 10);
    [manager computeGeometryAndLinesOfCell:cell];

    assertThatPoint(cell.textOrigin, equalToPoint(NewPoint(10 + horPadding + iconSize.width + iconTextDist, 10 + cellSize.height / 2 - 5)));
}

- (void)testComputeTextOriginWithIconsLeft {
    NSSize iconSize = NewSize(3 * iconDrawSize + 2 * interIconDist, iconDrawSize);
    NSSize cellSize = NewSize(10 + 2 * horPadding + iconSize.width + iconTextDist, iconSize.height + 2 * vertPadding);

    [cell addObjectInIcons:icon1];
    [cell addObjectInIcons:icon2];
    [cell addObjectInIcons:icon3];

    [given([cellSizeManager sizeOfTextOfCell:cell]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfIconsOfCell:cell]) willReturnSize:iconSize];
    [given([cellSizeManager sizeOfCell:cell]) willReturnSize:cellSize];

    cell.left = YES;
    cell.familyOrigin = NewPoint(10, 10);
    [manager computeGeometryAndLinesOfCell:cell];

    assertThatPoint(cell.textOrigin, equalToPoint(NewPoint(cell.origin.x + horPadding, 10 + cellSize.height / 2 - 5)));
}

- (void)testComputeTextOriginRootWoIcons {
    [given([cellSizeManager sizeOfTextOfCell:rootCell]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfIconsOfCell:rootCell]) willReturnSize:NewSize(0, 0)];
    [given([cellSizeManager sizeOfCell:rootCell]) willReturnSize:NewSize(50, 100)];
    rootCell.familyOrigin = NewPoint(10, 10);

    [manager computeGeometryAndLinesOfCell:rootCell];

    assertThatPoint(rootCell.textOrigin, equalToPoint(NewPoint(10 + 25 - 5, 10 + 50 - 5)));
}

- (void)testComputeTextOriginRootWithIcons {
    NSSize iconSize = NewSize(50, 20);
    NSSize cellSize = NewSize(200, 400);

    [rootCell addObjectInIcons:icon1];
    [rootCell addObjectInIcons:icon2];
    [rootCell addObjectInIcons:icon3];
    [given([cellSizeManager sizeOfTextOfCell:rootCell]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfIconsOfCell:rootCell]) willReturnSize:iconSize];
    [given([cellSizeManager sizeOfCell:rootCell]) willReturnSize:cellSize];
    rootCell.familyOrigin = NewPoint(10, 10);

    [manager computeGeometryAndLinesOfCell:rootCell];

    assertThatPoint(rootCell.textOrigin, equalToPoint(NewPoint(rootCell.middlePoint.x - (iconSize.width + iconTextDist + 10) / 2 + iconSize.width + iconTextDist, 10 + 200 - 5)));
}

- (void)testIconsOriginNonRoot {
    [cell addObjectInIcons:icon1];
    [cell addObjectInIcons:icon2];
    [cell addObjectInIcons:icon3];
    
    NSSize iconSize = NewSize(3 * iconDrawSize + 2 * interIconDist, iconDrawSize);
    NSSize cellSize = NewSize(2 * horPadding + 3 * iconDrawSize + iconTextDist + 10, 2 * vertPadding + 50);

    [given([cellSizeManager sizeOfTextOfCell:cell]) willReturnSize:NewSize(10, 50)];
    [given([cellSizeManager sizeOfIconsOfCell:cell]) willReturnSize:iconSize];
    [given([cellSizeManager sizeOfCell:cell]) willReturnSize:cellSize];

    cell.familyOrigin = NewPoint(10, 10);
    [manager computeGeometryAndLinesOfCell:cell];

    assertThatPoint(icon1.origin, equalToPoint(NewPoint(10 + horPadding, 10 + cellSize.height / 2 - iconDrawSize / 2)));
    assertThatPoint(icon2.origin, equalToPoint(NewPoint(icon1.origin.x + icon1.size.width + interIconDist, icon1.origin.y)));
    assertThatPoint(icon3.origin, equalToPoint(NewPoint(icon2.origin.x + icon2.size.width + interIconDist, icon1.origin.y)));
}

- (void)testIconsOriginRoot {
    [rootCell addObjectInIcons:icon1];
    [rootCell addObjectInIcons:icon2];
    [rootCell addObjectInIcons:icon3];

    NSSize iconSize = NewSize(3 * iconDrawSize + 2 * interIconDist, iconDrawSize);

    [given([cellSizeManager sizeOfTextOfCell:rootCell]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfIconsOfCell:rootCell]) willReturnSize:iconSize];
    [given([cellSizeManager sizeOfCell:rootCell]) willReturnSize:NewSize(400, 200)];

    rootCell.familyOrigin = NewPoint(10, 10);
    [manager computeGeometryAndLinesOfCell:rootCell];

    assertThatPoint(icon1.origin, equalToPoint(NewPoint(10 + 200 - (iconSize.width + iconTextDist + 10) / 2, 10 + 100 - iconDrawSize / 2)));
    assertThatPoint(icon2.origin, equalToPoint(NewPoint(icon1.origin.x + icon1.size.width + interIconDist, icon1.origin.y)));
    assertThatPoint(icon3.origin, equalToPoint(NewPoint(icon2.origin.x + icon2.size.width + interIconDist, icon1.origin.y)));
}

- (void)testIconsOfChildren {
    [cell addObjectInIcons:icon1];
    [cell addObjectInIcons:icon2];
    [cell addObjectInIcons:icon3];

    NSSize iconSize = NewSize(3 * iconDrawSize + 2 * interIconDist, iconDrawSize);
    NSSize cellSize = NewSize(2 * horPadding + 3 * iconDrawSize + iconTextDist + 10, 2 * vertPadding + 50);

    [given([cellSizeManager sizeOfTextOfCell:cell]) willReturnSize:NewSize(10, 50)];
    [given([cellSizeManager sizeOfIconsOfCell:cell]) willReturnSize:iconSize];
    [given([cellSizeManager sizeOfCell:cell]) willReturnSize:cellSize];

    [rootCell addObjectInChildren:cell];

    [given([cellSizeManager sizeOfTextOfCell:rootCell]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfIconsOfCell:rootCell]) willReturnSize:NewSize(0, 0)];
    [given([cellSizeManager sizeOfCell:rootCell]) willReturnSize:NewSize(400, 200)];

    rootCell.familyOrigin = NewPoint(10, 10);
    [manager computeGeometryAndLinesOfCell:rootCell];

    assertThatPoint(icon1.origin, isNot(equalToPoint(NSZeroPoint)));
    assertThatPoint(icon2.origin, isNot(equalToPoint(NSZeroPoint)));
    assertThatPoint(icon3.origin, isNot(equalToPoint(NSZeroPoint)));
}

- (void)testIconsOfLeftChildrenOfRoot {
    [cell addObjectInIcons:icon1];
    [cell addObjectInIcons:icon2];
    [cell addObjectInIcons:icon3];

    NSSize iconSize = NewSize(3 * iconDrawSize + 2 * interIconDist, iconDrawSize);
    NSSize cellSize = NewSize(2 * horPadding + 3 * iconDrawSize + iconTextDist + 10, 2 * vertPadding + 50);

    [given([cellSizeManager sizeOfTextOfCell:cell]) willReturnSize:NewSize(10, 50)];
    [given([cellSizeManager sizeOfIconsOfCell:cell]) willReturnSize:iconSize];
    [given([cellSizeManager sizeOfCell:cell]) willReturnSize:cellSize];

    [rootCell addObjectInLeftChildren:cell];

    [given([cellSizeManager sizeOfTextOfCell:rootCell]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfIconsOfCell:rootCell]) willReturnSize:NewSize(0, 0)];
    [given([cellSizeManager sizeOfCell:rootCell]) willReturnSize:NewSize(400, 200)];

    rootCell.familyOrigin = NewPoint(10, 10);
    [manager computeGeometryAndLinesOfCell:rootCell];

    assertThatPoint(icon1.origin, isNot(equalToPoint(NSZeroPoint)));
    assertThatPoint(icon2.origin, isNot(equalToPoint(NSZeroPoint)));
    assertThatPoint(icon3.origin, isNot(equalToPoint(NSZeroPoint)));
}

- (void)testIconsOfLeftCell {
    [cell addObjectInIcons:icon1];
    [cell addObjectInIcons:icon2];
    [cell addObjectInIcons:icon3];

    NSSize iconSize = NewSize(3 * iconDrawSize + 2 * interIconDist, iconDrawSize);
    NSSize cellSize = NewSize(2 * horPadding + 3 * iconDrawSize + 2 * interIconDist + iconTextDist + 10, 2 * vertPadding + 50);

    [given([cellSizeManager sizeOfTextOfCell:cell]) willReturnSize:NewSize(10, 50)];
    [given([cellSizeManager sizeOfIconsOfCell:cell]) willReturnSize:iconSize];
    [given([cellSizeManager sizeOfCell:cell]) willReturnSize:cellSize];

    cell.left = YES;

    cell.familyOrigin = NewPoint(10, 10);
    [manager computeGeometryAndLinesOfCell:cell];

    assertThatPoint(icon3.origin, equalToPoint(NewPoint(cell.origin.x + cellSize.width - horPadding - icon3.size.width, 10 + cellSize.height / 2 - iconDrawSize / 2)));
    assertThatPoint(icon2.origin, equalToPoint(NewPoint(icon3.origin.x - icon2.size.width - interIconDist, icon3.origin.y)));
    assertThatPoint(icon1.origin, equalToPoint(NewPoint(icon2.origin.x - icon1.size.width - interIconDist, icon3.origin.y)));
}

#pragma mark See Meta/Cell Test Cases.graffle
- (void)testCellLayout1 {
    [cell addObjectInChildren:childCell1];
    [childCell1 addObjectInChildren:grandChild];

    [given([cellSizeManager sizeOfCell:cell]) willReturnSize:NewSize(10, 100)];
    [given([cellSizeManager sizeOfChildrenFamily:cell.children]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfFamilyOfCell:cell]) willReturnSize:NewSize(10 + horDist + 10 + horDist + 10, 100)];

    [given([cellSizeManager sizeOfCell:childCell1]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfChildrenFamily:childCell1.children]) willReturnSize:NewSize(10, 50)];
    [given([cellSizeManager sizeOfFamilyOfCell:childCell1]) willReturnSize:NewSize(10 + horDist + 10, 50)];
    
    [given([cellSizeManager sizeOfCell:grandChild]) willReturnSize:NewSize(10, 50)];
    [given([cellSizeManager sizeOfChildrenFamily:grandChild.children]) willReturnSize:NewSize(0, 0)];
    [given([cellSizeManager sizeOfFamilyOfCell:grandChild]) willReturnSize:NewSize(10, 50)];

    cell.familyOrigin = NewPoint(10, 10);
    [manager computeGeometryAndLinesOfCell:cell];

    assertThatPoint(cell.origin, equalToPoint(cell.familyOrigin));
    assertThatPoint(childCell1.origin, equalToPoint(NewPoint(10 + 10 + horDist, 10 + 45)));
    assertThatPoint(childCell1.familyOrigin, equalToPoint(NewPoint(10 + horDist + 10, 10 + 50 - 25)));
}

- (void)testCellLayout2 {
    [cell addObjectInChildren:childCell1];
    [childCell1 addObjectInChildren:grandChild];

    [given([cellSizeManager sizeOfCell:cell]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfChildrenFamily:cell.children]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfFamilyOfCell:cell]) willReturnSize:NewSize(10 + horDist + 10, 100)];

    [given([cellSizeManager sizeOfCell:childCell1]) willReturnSize:NewSize(10, 100)];
    [given([cellSizeManager sizeOfChildrenFamily:childCell1.children]) willReturnSize:NewSize(10, 50)];
    [given([cellSizeManager sizeOfFamilyOfCell:childCell1]) willReturnSize:NewSize(10 + horDist + 10, 100)];

    [given([cellSizeManager sizeOfCell:grandChild]) willReturnSize:NewSize(10, 50)];
    [given([cellSizeManager sizeOfChildrenFamily:grandChild.children]) willReturnSize:NewSize(0, 0)];
    [given([cellSizeManager sizeOfFamilyOfCell:grandChild]) willReturnSize:NewSize(10, 50)];

    cell.familyOrigin = NewPoint(10, 10);
    [manager computeGeometryAndLinesOfCell:cell];

    assertThatPoint(cell.origin, equalToPoint(NewPoint(10, 10 + 45)));
    assertThatPoint(childCell1.origin, equalToPoint(NewPoint(10 + 10 + horDist, 10)));
    assertThatPoint(childCell1.familyOrigin, equalToPoint(childCell1.origin));
}

- (void)testCellLayout3 {
    [cell addObjectInChildren:childCell1];
    [cell addObjectInChildren:childCell2];

    [given([cellSizeManager sizeOfCell:cell]) willReturnSize:NewSize(10, 100)];
    [given([cellSizeManager sizeOfChildrenFamily:cell.children]) willReturnSize:NewSize(10, 10 + vertDist + 10)];
    [given([cellSizeManager sizeOfFamilyOfCell:cell]) willReturnSize:NewSize(10 + horDist + 10, 100)];

    [given([cellSizeManager sizeOfCell:childCell1]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfChildrenFamily:childCell1.children]) willReturnSize:NewSize(0, 0)];
    [given([cellSizeManager sizeOfFamilyOfCell:childCell1]) willReturnSize:NewSize(10, 10)];

    [given([cellSizeManager sizeOfCell:childCell2]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfChildrenFamily:childCell2.children]) willReturnSize:NewSize(0, 0)];
    [given([cellSizeManager sizeOfFamilyOfCell:childCell2]) willReturnSize:NewSize(10, 10)];

    cell.familyOrigin = NewPoint(10, 10);
    [manager computeGeometryAndLinesOfCell:cell];

    assertThatPoint(cell.origin, equalToPoint(cell.familyOrigin));
    assertThatPoint(childCell1.origin, equalToPoint(NewPoint(10 + 10 + horDist, 10 + 50 - vertDist / 2 - 10)));
    assertThatPoint(childCell1.familyOrigin, equalToPoint(childCell1.origin));
    assertThatPoint(childCell2.origin, equalToPoint(NewPoint(10 + 10 + horDist, 10 + 50 + vertDist / 2)));
    assertThatPoint(childCell2.familyOrigin, equalToPoint(childCell2.origin));
}

- (void)testCellLayout4 {
    [cell addObjectInChildren:childCell1];
    [cell addObjectInChildren:childCell2];

    [given([cellSizeManager sizeOfCell:cell]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfChildrenFamily:cell.children]) willReturnSize:NewSize(10, 100 + vertDist + 100)];
    [given([cellSizeManager sizeOfFamilyOfCell:cell]) willReturnSize:NewSize(10 + horDist + 10, 100 + vertDist + 100)];

    [given([cellSizeManager sizeOfCell:childCell1]) willReturnSize:NewSize(10, 100)];
    [given([cellSizeManager sizeOfChildrenFamily:childCell1.children]) willReturnSize:NewSize(0, 0)];
    [given([cellSizeManager sizeOfFamilyOfCell:childCell1]) willReturnSize:NewSize(10, 100)];

    [given([cellSizeManager sizeOfCell:childCell2]) willReturnSize:NewSize(10, 100)];
    [given([cellSizeManager sizeOfChildrenFamily:childCell2.children]) willReturnSize:NewSize(0, 0)];
    [given([cellSizeManager sizeOfFamilyOfCell:childCell2]) willReturnSize:NewSize(10, 100)];

    cell.familyOrigin = NewPoint(10, 10);
    [manager computeGeometryAndLinesOfCell:cell];

    assertThatPoint(cell.origin, equalToPoint(NewPoint(10, 10 + (200 + vertDist - 10) / 2)));
    assertThatPoint(childCell1.origin, equalToPoint(NewPoint(10 + 10 + horDist, 10)));
    assertThatPoint(childCell1.familyOrigin, equalToPoint(childCell1.origin));
    assertThatPoint(childCell2.origin, equalToPoint(NewPoint(10 + 10 + horDist, 10 + vertDist + 100)));
    assertThatPoint(childCell2.familyOrigin, equalToPoint(childCell2.origin));
}

- (void)testCellLayout5 {
    [given([cellSizeManager sizeOfCell:cell]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfChildrenFamily:cell.children]) willReturnSize:NewSize(0, 0)];
    [given([cellSizeManager sizeOfFamilyOfCell:cell]) willReturnSize:NewSize(10, 10)];

    cell.familyOrigin = NewPoint(10, 10);
    [manager computeGeometryAndLinesOfCell:cell];

    assertThatPoint(cell.origin, equalToPoint(NewPoint(10, 10)));
}

- (void)testCellLayout6 {
    [rootCell addObjectInChildren:childCell1];
    [rootCell addObjectInLeftChildren:leftChildCell1];

    [given([cellSizeManager sizeOfCell:rootCell]) willReturnSize:NewSize(10, 100)];
    [given([cellSizeManager sizeOfChildrenFamily:rootCell.children]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfChildrenFamily:rootCell.leftChildren]) willReturnSize:NewSize(10, 10)];

    [given([cellSizeManager sizeOfFamilyOfCell:rootCell]) willReturnSize:NewSize(10 + horDist + 10 + horDist + 10, 100)];

    [given([cellSizeManager sizeOfCell:childCell1]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfChildrenFamily:childCell1.children]) willReturnSize:NewSize(0, 0)];
    [given([cellSizeManager sizeOfFamilyOfCell:childCell1]) willReturnSize:NewSize(10, 10)];

    [given([cellSizeManager sizeOfCell:leftChildCell1]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfChildrenFamily:leftChildCell1.children]) willReturnSize:NewSize(0, 0)];
    [given([cellSizeManager sizeOfFamilyOfCell:leftChildCell1]) willReturnSize:NewSize(10, 10)];

    rootCell.familyOrigin = NewPoint(10, 10);
    [manager computeGeometryAndLinesOfCell:rootCell];

    assertThatPoint(rootCell.origin, equalToPoint(NewPoint(10 + 10 + horDist, 10)));
    assertThatPoint(leftChildCell1.origin, equalToPoint(NewPoint(10, 10 + 50 - 5)));
    assertThatPoint(leftChildCell1.familyOrigin, equalToPoint(leftChildCell1.origin));
    assertThatPoint(childCell1.origin, equalToPoint(NewPoint(10 + 10 + horDist + 10 + horDist, 10 + 50 - 5)));
    assertThatPoint(childCell1.familyOrigin, equalToPoint(childCell1.origin));
}

- (void)testCellLayout7 {
    [rootCell addObjectInChildren:childCell1];
    [rootCell addObjectInLeftChildren:leftChildCell1];

    [given([cellSizeManager sizeOfCell:rootCell]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfChildrenFamily:rootCell.children]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfChildrenFamily:rootCell.leftChildren]) willReturnSize:NewSize(10, 100)];

    [given([cellSizeManager sizeOfFamilyOfCell:rootCell]) willReturnSize:NewSize(10 + horDist + 10 + horDist + 10, 100)];

    [given([cellSizeManager sizeOfCell:childCell1]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfChildrenFamily:childCell1.children]) willReturnSize:NewSize(0, 0)];
    [given([cellSizeManager sizeOfFamilyOfCell:childCell1]) willReturnSize:NewSize(10, 10)];

    [given([cellSizeManager sizeOfCell:leftChildCell1]) willReturnSize:NewSize(10, 100)];
    [given([cellSizeManager sizeOfChildrenFamily:leftChildCell1.children]) willReturnSize:NewSize(0, 0)];
    [given([cellSizeManager sizeOfFamilyOfCell:leftChildCell1]) willReturnSize:NewSize(10, 100)];

    rootCell.familyOrigin = NewPoint(10, 10);
    [manager computeGeometryAndLinesOfCell:rootCell];

    assertThatPoint(rootCell.origin, equalToPoint(NewPoint(10 + 10 + horDist, 10 + 50 - 5)));
    assertThatPoint(leftChildCell1.origin, equalToPoint(NewPoint(10, 10)));
    assertThatPoint(leftChildCell1.familyOrigin, equalToPoint(leftChildCell1.origin));
    assertThatPoint(childCell1.origin, equalToPoint(NewPoint(10 + 10 + horDist + 10 + horDist, 10 + 50 - 5)));
    assertThatPoint(childCell1.familyOrigin, equalToPoint(childCell1.origin));
}

- (void)testCellLayout8 {
    [rootCell addObjectInChildren:childCell1];
    [rootCell addObjectInLeftChildren:leftChildCell1];
    [rootCell addObjectInLeftChildren:leftChildCell2];

    [given([cellSizeManager sizeOfCell:rootCell]) willReturnSize:NewSize(10, 100)];
    [given([cellSizeManager sizeOfChildrenFamily:rootCell.children]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfChildrenFamily:rootCell.leftChildren]) willReturnSize:NewSize(10, 10)];

    [given([cellSizeManager sizeOfFamilyOfCell:rootCell]) willReturnSize:NewSize(10 + horDist + 10 + horDist + 10, 100)];

    [given([cellSizeManager sizeOfCell:childCell1]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfChildrenFamily:childCell1.children]) willReturnSize:NewSize(0, 0)];
    [given([cellSizeManager sizeOfFamilyOfCell:childCell1]) willReturnSize:NewSize(10, 10)];

    [given([cellSizeManager sizeOfCell:leftChildCell1]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfChildrenFamily:leftChildCell1.children]) willReturnSize:NewSize(0, 0)];
    [given([cellSizeManager sizeOfFamilyOfCell:leftChildCell1]) willReturnSize:NewSize(10, 10)];

    [given([cellSizeManager sizeOfCell:leftChildCell2]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfChildrenFamily:leftChildCell2.children]) willReturnSize:NewSize(0, 0)];
    [given([cellSizeManager sizeOfFamilyOfCell:leftChildCell2]) willReturnSize:NewSize(10, 10)];

    rootCell.familyOrigin = NewPoint(10, 10);
    [manager computeGeometryAndLinesOfCell:rootCell];

    assertThatPoint(rootCell.origin, equalToPoint(NewPoint(10 + 10 + horDist, 10)));
    assertThatPoint(leftChildCell1.origin, equalToPoint(NewPoint(10, 10 + 50 - 5)));
    assertThatPoint(leftChildCell1.familyOrigin, equalToPoint(leftChildCell1.origin));
    assertThatPoint(leftChildCell2.origin, equalToPoint(NewPoint(10, 10 + 50 - 5 + vertDist + 10)));
    assertThatPoint(leftChildCell2.familyOrigin, equalToPoint(leftChildCell2.origin));
    assertThatPoint(childCell1.origin, equalToPoint(NewPoint(10 + 10 + horDist + 10 + horDist, 10 + 50 - 5)));
    assertThatPoint(childCell1.familyOrigin, equalToPoint(childCell1.origin));
}

- (void)testCellLayout9 {
    [rootCell addObjectInChildren:childCell1];
    [rootCell addObjectInLeftChildren:leftChildCell1];
    [rootCell addObjectInLeftChildren:leftChildCell2];

    [given([cellSizeManager sizeOfCell:rootCell]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfChildrenFamily:rootCell.children]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfChildrenFamily:rootCell.leftChildren]) willReturnSize:NewSize(10, 100 + vertDist + 100)];

    [given([cellSizeManager sizeOfFamilyOfCell:rootCell]) willReturnSize:NewSize(10 + horDist + 10 + horDist + 10, 100 + vertDist + 100)];

    [given([cellSizeManager sizeOfCell:childCell1]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfChildrenFamily:childCell1.children]) willReturnSize:NewSize(0, 0)];
    [given([cellSizeManager sizeOfFamilyOfCell:childCell1]) willReturnSize:NewSize(10, 10)];

    [given([cellSizeManager sizeOfCell:leftChildCell1]) willReturnSize:NewSize(10, 100)];
    [given([cellSizeManager sizeOfChildrenFamily:leftChildCell1.children]) willReturnSize:NewSize(0, 0)];
    [given([cellSizeManager sizeOfFamilyOfCell:leftChildCell1]) willReturnSize:NewSize(10, 100)];

    [given([cellSizeManager sizeOfCell:leftChildCell2]) willReturnSize:NewSize(10, 100)];
    [given([cellSizeManager sizeOfChildrenFamily:leftChildCell2.children]) willReturnSize:NewSize(0, 0)];
    [given([cellSizeManager sizeOfFamilyOfCell:leftChildCell2]) willReturnSize:NewSize(10, 100)];

    rootCell.familyOrigin = NewPoint(10, 10);
    [manager computeGeometryAndLinesOfCell:rootCell];

    assertThatPoint(rootCell.origin, equalToPoint(NewPoint(10 + 10 + horDist, 10 + (200 + vertDist) / 2 - 5)));
    assertThatPoint(leftChildCell1.origin, equalToPoint(NewPoint(10, 10)));
    assertThatPoint(leftChildCell1.familyOrigin, equalToPoint(leftChildCell1.origin));
    assertThatPoint(leftChildCell2.origin, equalToPoint(NewPoint(10, 10 + 100 + vertDist)));
    assertThatPoint(leftChildCell2.familyOrigin, equalToPoint(leftChildCell2.origin));
    assertThatPoint(childCell1.origin, equalToPoint(NewPoint(10 + 10 + horDist + 10 + horDist, 10 + (200 + vertDist) / 2 - 5)));
    assertThatPoint(childCell1.familyOrigin, equalToPoint(childCell1.origin));
}

- (void)testCellLayout10 {
    [rootCell addObjectInLeftChildren:leftChildCell1];
    [leftChildCell1 addObjectInChildren:grandChild];

    [given([cellSizeManager sizeOfCell:rootCell]) willReturnSize:NewSize(10, 100)];
    [given([cellSizeManager sizeOfChildrenFamily:rootCell.leftChildren]) willReturnSize:NewSize(10 + horDist + 10, 50)];

    [given([cellSizeManager sizeOfFamilyOfCell:rootCell]) willReturnSize:NewSize(10 + horDist + 10 + horDist + 10, 100)];

    [given([cellSizeManager sizeOfCell:leftChildCell1]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfChildrenFamily:leftChildCell1.children]) willReturnSize:NewSize(10, 50)];
    [given([cellSizeManager sizeOfFamilyOfCell:leftChildCell1]) willReturnSize:NewSize(10 + horDist + 10, 50)];

    [given([cellSizeManager sizeOfCell:grandChild]) willReturnSize:NewSize(10, 50)];
    [given([cellSizeManager sizeOfChildrenFamily:grandChild.children]) willReturnSize:NewSize(0, 0)];
    [given([cellSizeManager sizeOfFamilyOfCell:grandChild]) willReturnSize:NewSize(10, 50)];

    rootCell.familyOrigin = NewPoint(10, 10);
    [manager computeGeometryAndLinesOfCell:rootCell];

    assertThatPoint(rootCell.origin, equalToPoint(NewPoint(10 + 10 + horDist + 10 + horDist, 10)));
    assertThatPoint(leftChildCell1.origin, equalToPoint(NewPoint(10 + 10 + horDist, 10 + 50 - 5)));
    assertThatPoint(leftChildCell1.familyOrigin, equalToPoint(NewPoint(10, 10 + 50 - 25)));
}

- (void)testCellLayout11 {
    [rootCell addObjectInLeftChildren:leftChildCell1];
    [leftChildCell1 addObjectInChildren:grandChild];

    [given([cellSizeManager sizeOfCell:rootCell]) willReturnSize:NewSize(10, 100)];
    [given([cellSizeManager sizeOfChildrenFamily:rootCell.leftChildren]) willReturnSize:NewSize(10 + horDist + 10, 50)];

    [given([cellSizeManager sizeOfFamilyOfCell:rootCell]) willReturnSize:NewSize(10 + horDist + 10 + horDist + 10, 100)];

    [given([cellSizeManager sizeOfCell:leftChildCell1]) willReturnSize:NewSize(10, 50)];
    [given([cellSizeManager sizeOfChildrenFamily:leftChildCell1.children]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfFamilyOfCell:leftChildCell1]) willReturnSize:NewSize(10 + horDist + 10, 50)];

    [given([cellSizeManager sizeOfCell:grandChild]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfChildrenFamily:grandChild.children]) willReturnSize:NewSize(0, 0)];
    [given([cellSizeManager sizeOfFamilyOfCell:grandChild]) willReturnSize:NewSize(10, 10)];

    rootCell.familyOrigin = NewPoint(10, 10);
    [manager computeGeometryAndLinesOfCell:rootCell];

    assertThatPoint(rootCell.origin, equalToPoint(NewPoint(10 + 10 + horDist + 10 + horDist, 10)));
    assertThatPoint(leftChildCell1.origin, equalToPoint(NewPoint(10 + 10 + horDist, 10 + 50 - 25)));
    assertThatPoint(leftChildCell1.familyOrigin, equalToPoint(NewPoint(10, 10 + 50 - 25)));
}

- (void)testCellLayout12 {
    [rootCell addObjectInLeftChildren:leftChildCell1];
    [rootCell addObjectInLeftChildren:leftChildCell2];
    [leftChildCell1 addObjectInChildren:grandChild];

    [given([cellSizeManager sizeOfCell:rootCell]) willReturnSize:NewSize(10, 100)];
    [given([cellSizeManager sizeOfChildrenFamily:rootCell.leftChildren]) willReturnSize:NewSize(10 + horDist + 10, 10 + vertDist + 10)];

    [given([cellSizeManager sizeOfFamilyOfCell:rootCell]) willReturnSize:NewSize(10 + horDist + 10 + horDist + 10, 100)];

    [given([cellSizeManager sizeOfCell:leftChildCell1]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfChildrenFamily:leftChildCell1.children]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfFamilyOfCell:leftChildCell1]) willReturnSize:NewSize(10 + horDist + 10, 10)];

    [given([cellSizeManager sizeOfCell:leftChildCell2]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfChildrenFamily:leftChildCell2.children]) willReturnSize:NewSize(0, 0)];
    [given([cellSizeManager sizeOfFamilyOfCell:leftChildCell2]) willReturnSize:NewSize(10, 10)];

    [given([cellSizeManager sizeOfCell:grandChild]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfChildrenFamily:grandChild.children]) willReturnSize:NewSize(0, 0)];
    [given([cellSizeManager sizeOfFamilyOfCell:grandChild]) willReturnSize:NewSize(10, 10)];

    rootCell.familyOrigin = NewPoint(10, 10);
    [manager computeGeometryAndLinesOfCell:rootCell];

    assertThatPoint(rootCell.origin, equalToPoint(NewPoint(10 + 10 + horDist + 10 + horDist, 10)));

    assertThatPoint(leftChildCell1.origin, equalToPoint(NewPoint(10 + 10 + horDist, 10 + 50 - vertDist / 2 - 10)));
    assertThatPoint(leftChildCell1.familyOrigin, equalToPoint(NewPoint(10, 10 + 50 - vertDist / 2 - 10)));

    assertThatPoint(leftChildCell2.origin, equalToPoint(NewPoint(10 + 10 + horDist, 10 + 50 + vertDist / 2)));
    assertThatPoint(leftChildCell2.familyOrigin, equalToPoint(NewPoint(10, 10 + 50 + vertDist / 2)));

    assertThatPoint(grandChild.origin, equalToPoint(NewPoint(10, 10 + 50 - vertDist / 2 - 10)));
    assertThatPoint(grandChild.familyOrigin, equalToPoint(NewPoint(10, 10 + 50 - vertDist / 2 - 10)));
}

#pragma mark Private
- (void)wireCell:(QMCell *)aCell stringValue:(NSString *)sValue {
    aCell.cellLayoutManager = manager;
    aCell.cellDrawer = nil;
    aCell.textLayoutManager = textLayoutManager;
    aCell.cellSizeManager = cellSizeManager;
    aCell.stringValue = sValue;
}

@end
