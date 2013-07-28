/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
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
#import "QMFontManager.h"


@interface QMIconTest : QMCacaoTestCase
@end

@implementation QMIconTest {
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
    assertThat(stringIcon.fontManager, is([self.context beanWithClass:[QMFontManager class]]));
    assertThat(stringIcon.systemFontManager, is([self.context beanWithClass:[NSFontManager class]]));
}

- (void)testInitAsLink {
    QMIcon *linkIcon = [[QMIcon alloc] initAsLink];

    assertThat(@(linkIcon.kind), is(@(QMIconKindFontawesome)));
    assertThat(linkIcon.code, is(nilValue()));
    assertThat(linkIcon.unicode, is(@"\\u%f023"));

    assertThat(linkIcon.settings, is([self.context beanWithClass:[QMAppSettings class]]));
    assertThat(linkIcon.iconManager, is([self.context beanWithClass:[QMIconManager class]]));
    assertThat(linkIcon.textDrawer, is([self.context beanWithClass:[QMTextDrawer class]]));
    assertThat(linkIcon.textLayoutManager, is([self.context beanWithClass:[QMTextLayoutManager class]]));
    assertThat(linkIcon.fontManager, is([self.context beanWithClass:[QMFontManager class]]));
    assertThat(linkIcon.systemFontManager, is([self.context beanWithClass:[NSFontManager class]]));
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

- (void)testFrame {
    QMIcon *icon = [[QMIcon alloc] initWithCode:@"list"];
    icon.origin = NewPoint(1, 2);
    assertThatRect(icon.frame, equalToRect(NewRect(1, 2, [settings floatForKey:qSettingIconDrawSize], [settings floatForKey:qSettingIconDrawSize])));
}

@end
