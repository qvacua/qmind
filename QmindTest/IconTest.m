/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import <Qkit/Qkit.h>
#import "QMBaseTestCase.h"
#import "QMIcon.h"
#import "QMCacaoTestCase.h"
#import "QMAppSettings.h"
#import "QMIconManager.h"
#import "QMTextDrawer.h"
#import "QMTextLayoutManager.h"

@interface IconTest : QMCacaoTestCase
@end

@implementation IconTest {
    QMAppSettings *settings;
}

- (void)setUp {
    [super setUp];

    settings = [self.context beanWithClass:[QMAppSettings class]];
}

- (void)testInit {
    QMIcon *stringIcon = [[QMIcon alloc] initWithCode:@"list"];
    QMIcon *imageIcon = [[QMIcon alloc] initWithCode:@"closed"];

    assertThat(@(stringIcon.kind), is(@(QMIconKindString)));
    assertThat(stringIcon.code, is(@"list"));

    assertThat(@(imageIcon.kind), is(@(QMIconKindImage)));
    assertThat(imageIcon.code, is(@"closed"));

    assertThat(stringIcon.settings, is([self.context beanWithClass:[QMAppSettings class]]));
    assertThat(stringIcon.iconManager, is([self.context beanWithClass:[QMIconManager class]]));
    assertThat(stringIcon.textDrawer, is([self.context beanWithClass:[QMTextDrawer class]]));
    assertThat(stringIcon.textLayoutManager, is([self.context beanWithClass:[QMTextLayoutManager class]]));
}

- (void)testCopy {
    QMIcon *original = [[QMIcon alloc] initWithCode:@"list"];
    original.origin = NewPoint(1, 2);
    original.size = NewSize(3, 4);

    QMIcon *copy = [original copy];

    assertThat(copy.code, is(original.code));
    assertThat(@(copy.kind), is(@(original.kind)));
    assertThatPoint(copy.origin, equalToPoint(original.origin));
    assertThatSize(copy.size, equalToSize(original.size));
}

- (void)testIconSize {
    QMIcon *icon = [[QMIcon alloc] initWithCode:@"list"];

    assertThatSize(icon.size, equalToSize(NewSize([settings floatForKey:qSettingIconDrawSize], [settings floatForKey:qSettingIconDrawSize])));
}

@end
