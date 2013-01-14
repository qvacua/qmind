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

@interface IconGridViewTest : QMBaseTestCase
@end

@implementation IconGridViewTest {
    QMIconGridView *iconGridView;

    QMIconCollectionViewItem *viewController;
}

- (void)setUp {
    [super setUp];

    viewController = mock([QMIconCollectionViewItem class]);
    iconGridView = [[QMIconGridView alloc] initWithFrame:NewRect(0, 0, 50, 50)];
    iconGridView.viewController = viewController;
}

- (void)testMouseUp {
    [given([viewController canSetIcon]) willReturnBool:YES];
    [iconGridView mouseUp:self];
    [verify(viewController) setIcon];
}

@end
