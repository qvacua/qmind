/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Qkit/Qkit.h>
#import "QMBaseTestCase.h"
#import "QMIconGridView.h"
#import "QMMindmapView.h"
#import "QMIconCollectionViewItem.h"

@interface IconGridViewTest : QMBaseTestCase
@property (strong) NSWindow *window;
@end

@implementation IconGridViewTest {
    QMIconGridView *iconGridView;

    QMIconCollectionViewItem *viewController;
    NSEvent *event;
    NSEvent *nextEvent;
    NSWindow *window;
}

@synthesize window;

- (void)setUp {
    [super setUp];

    viewController = mock([QMIconCollectionViewItem class]);
    iconGridView = [[QMIconGridView alloc] initWithFrame:NewRect(0, 0, 50, 50)];
    iconGridView.viewController = viewController;

    window = mock([NSWindow class]);
    [iconGridView setInstanceVarTo:window];

    event = mock([NSEvent class]);
    nextEvent = mock([NSEvent class]);
}

- (void)testMouseUp {
    [given([viewController canSetIcon]) willReturnBool:YES];
    [given([window nextEventMatchingMask:NSLeftMouseUpMask]) willReturn:nextEvent];
    [given([nextEvent type]) willReturnUnsignedInteger:NSLeftMouseUp];

    [iconGridView mouseDown:event];

    [verify(viewController) setIcon];
}

@end
