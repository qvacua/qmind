#import "QMBaseTestCase.h"
#import "QMIconManager.h"
#import "QMCacaoTestCase.h"

@interface IconManagerTest : QMCacaoTestCase
@end

@implementation IconManagerTest {
    QMIconManager *manager;
}

- (void)setUp {
    [super setUp];

    manager = [self.context beanWithClass:[QMIconManager class]];
}

- (void)testIconRep {
    assertThat([manager iconRepresentationForCode:@"full-1"], instanceOf(NSString.class));
    assertThat([manager iconRepresentationForCode:@"kmail"], instanceOf(NSImage.class));
    assertThat([manager iconRepresentationForCode:@"jjjjj"], instanceOf(NSImage.class));
}

- (void)testIconKind {
    assertThat(@([manager kindForCode:@"closed"]), is(@(QMIconKindImage)));
    assertThat(@([manager kindForCode:@"list"]), is(@(QMIconKindString)));
}

- (void)testIconCodes {
    NSArray *iconCodes = manager.iconCodes;

    assertThat(iconCodes, isNot(hasItem(@"closed")));
    assertThat(iconCodes, hasItem(@"desktop_new"));

    assertThat(@([iconCodes indexOfObject:@"full-1"]), lessThan(@([iconCodes indexOfObject:@"full-4"])));
}

@end
